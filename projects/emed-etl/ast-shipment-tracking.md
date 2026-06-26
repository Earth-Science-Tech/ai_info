# Peaks AST Shipment Tracking — pipeline, gotchas, and manual backfill

How FedEx/UPS tracking numbers get from the pharmacy onto the Peaks Curative
WordPress site, why it silently broke for weeks in 2026-05/06, and the ops tool
to recover a backlog.

## What it does

```
Liberty pharmacy fills Rx + adds tracking #
        │  (Liberty ETL)
moct_order_tracking  (usp_etl_moct_order_tracking inserts rows, tracking_sent=0)
        │  (peaks_update_ast subflow)
POST {AST_API_BASE}/orders/{clinic_order_id}/shipment-trackings   (Basic auth)
        │  on HTTP 2xx
UPDATE moct_order_tracking SET tracking_sent=1, tracking_sent_date=GETDATE()
```

- **AST** = "Advanced Shipment Tracking (Pro)", a WooCommerce/WordPress plugin on
  `peakscurative.com`. `AST_API_BASE` = `https://peakscurative.com/wp-json/wc-shipment-tracking/v3`.
- The send is **idempotent by design**: a failed POST leaves `tracking_sent=0`, so
  the next run retries it. No date filter — any unsent row, however old, is eligible.
- **404 → auto-retire (PR #28):** if AST returns 404 (`woocommerce_rest_order_invalid_id`,
  i.e. the WP order was deleted), the record is marked `is_invalid=1` so it stops being
  retried forever. Safe because the WP order exists before tracking is pushed.
- Selection: `tracking_sent=0 AND tracking_number IS NOT NULL AND tracking_provider
  NOT LIKE '%Picked Up%' AND clinic IN ('PEAKS Curative, LLC','PEAKS CURATIVE','MOC TELEDOC')`,
  filtered per-pharmacy (`pharmacy = 'Rx Compound Store'` / `'Mister Meds'`).

## Where it runs

It is **not** a standalone deployment. It's step 6 (a subflow) of
`run_all_etl` (`flows/emed_etl/run_all_etl_flow.py`), which is deployed as
**Run-All-ETL-RXCS** (hourly) and **Run-All-ETL-MMED** (every 15 min). The
subflow `peaks_update_ast` does 3 things in order: ready-for-pickup emails →
mark picked-up orders complete → **push tracking** (the last step).

**Why an email step here (two fulfillment paths):** steps 1–2 handle **in-store
pickup** orders (`OrderStatus='Ready'`, no shipping address, `shipping_total=0`).
WordPress/AST emails the customer the *shipping-tracking* email when tracking is
added via the API (step 3) — but pickup orders have no shipment, so the Python
**"Your prescription is ready for pickup"** email (step 1) is the only thing that
notifies those customers. The two paths don't overlap; no double-emailing.
The pickup email uses `scripts/shared_email_azure.py:peak_send` (MS Graph). Its
Azure creds must come from Prefect Secret blocks **`azure-tenant-id` /
`azure-email-client-id` / `azure-email-client-secret`** — reading `os.getenv` on
the worker yielded `None` and silently broke every pickup email (fixed PR #29).

## The 2026-05/06 outage (root cause + the coupling gotcha)

Tracking stopped reaching the site for ~weeks. Root cause chain:

1. `usp_etl_emed_script_webhook_events` (step 5.5, the webhook-diff proc) crashed
   with **MERGE error 8672** — `view_emed_full_order` returned >1 row per
   `(Pharmacy, ScriptNumber, Fill)` (eScript + transaction rows collapsing via
   `ISNULL(Fill,0)`), and the MERGE into `emed_script_status_snapshot` keys on
   exactly those 3 columns. Fixed in `emed_sql` `d0e3fb6` by deduping the source
   with `ROW_NUMBER()` (keep richest shipping signal).
2. **The trap:** `peaks_update_ast` was wired `wait_for=[order_tracking, webhook_events]`.
   So the webhook crash *skipped* the unrelated tracking push every run.
3. **Why nobody noticed:** `send_tracking_updates` swallowed all errors and the
   flow reported green even when 100% of sends failed; `sql_log` had also frozen
   (see below). Silent failure for weeks.

**Lesson:** never couple an outward-facing delivery step to an unrelated ETL step
via `wait_for`. Hardened in emed_etl PR #26 (2026-06):
- `peaks_update_ast` waits only on `order_tracking`.
- The 3 subflow steps are isolated (a pickup/email failure can't abort the push).
- `_build_wcapi()` moved inside the `try` in `process_picked_up_orders`.
- `send_tracking_updates` **raises** on a DB error or an all-**systemic**-failure
  run (zero successes + ≥1 non-404 failure), so a real outage shows red. Per-order
  **404s** (order deleted on WP) are logged `WARN` and never fail the run.
  (PR #26's first cut raised on *any* all-failed run; once the backlog drained, the
  one chronic 404 per pharmacy made every run fail red — corrected in **PR #28** to
  be systemic-aware.)

A second guard already exists at the table: unique filtered index
`UX_emed_script_status_snapshot_key (pharmacy, script_number, fill_number) WHERE is_invalid=0`.

## Manual backfill tool

`emed_etl/scripts/backfill_ast_tracking.py` — standalone, **stdlib-only**
(`urllib` + `pyodbc` + `dotenv`; no Prefect, no `requests`). Use it when Prefect
is unreachable (e.g. job-server IP not whitelisted) or to flush a backlog now.

```bash
cd emed_etl/scripts
python backfill_ast_tracking.py --pharmacy "Rx Compound Store" --mode dry-run   # read-only preview
python backfill_ast_tracking.py --pharmacy "Rx Compound Store" --mode test      # POST exactly 1 record
python backfill_ast_tracking.py --pharmacy "Rx Compound Store" --mode run        # full backlog
python backfill_ast_tracking.py --pharmacy "Mister Meds"       --mode run --limit 50
```

Always `dry-run` then `test` (confirms the plugin returns 201) before `run`. Run
**both** pharmacies — each only sends its own. It reads creds from
`emed_etl/.env` (`TGT_*` = prod `liberty_link_stage`, `AST_*` = plugin creds) and
mirrors the production send logic exactly, so marking happens in the same DB the
scheduled flow reads (no double-send risk).

## Diagnosing stalled tracking (read-only)

Prod is `liberty_link_stage`. **On dev machines the Node `emed_app/.env` points at
`liberty_link_dev`** — use the Python `TGT_*` connection (or check `SELECT DB_NAME()`)
for prod.

```sql
-- Backlog that should be ~0 (plus a couple chronic 404s) when healthy:
SELECT pharmacy, COUNT(*) pending FROM moct_order_tracking
WHERE tracking_sent=0 AND is_invalid=0 AND tracking_number IS NOT NULL
  AND tracking_provider NOT LIKE '%Picked Up%'
  AND clinic IN ('PEAKS Curative, LLC','PEAKS CURATIVE','MOC TELEDOC')
GROUP BY pharmacy;
```
A rebuilding backlog + a flow that "completes" = the classic silent-failure shape.

**Known chronic failures:** a small number of orders 404 ("Invalid order ID")
because they no longer exist on the WP site (e.g. order numbers far below the
current range). These never succeed via the API and need a human, not a retry.

## Observability gaps (open)

- **`sql_log` frozen since 2026-04-30** — nothing writes to it despite `emed_etl`
  having INSERT/SELECT (so NOT a grant issue). The flow's `_sql_log` swallows
  insert failures and only warns to the Prefect logger — check **worker logs** for
  "Failed to write to sql_log". Until fixed, `sql_log` is not a reliable signal.
- **No Prefect failure automation** on `run-all-etl` / `peaks-update-ast`. PR #26
  makes the run go red on a real outage, but without an automation nobody is
  paged — add one (Prefect UI → Automations) so red runs actually alert.
