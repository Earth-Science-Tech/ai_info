# Peaks WooCommerce order-status sync — the creation-window gotcha + backfill

Why eMed's Peaks Orders page could show `processing` for an order WooCommerce
had long since marked `completed`, the fix, and the ops tool to recover the
backlog. (Fixed 2026-07-30, emed_etl main `3c02617`.)

## What it does

```
WooCommerce (peakscurative.com)
        │  peaks_etl_woo_orders_flow.py  (subflow of the Peaks orchestrator, every 15 min)
        │  REST GET /orders  → upsert into woo_orders (status, dates, billing, line_items, ...)
        ▼
woo_orders.status  ──►  view_woo_orders  ──►  /api/peaks/orders  ──►  Peaks Orders page
```

- The upsert **preserves eMed-managed fields** (`processed_to_moct`,
  `processing_error`, `moct_visit_id`, `note`) — WooCommerce never overwrites them.
- `woo_orders.date_modified` = WooCommerce's own modified timestamp (GMT);
  `date_modified_local` = when the ETL last touched the row.

## The gotcha: it fetched by date_CREATED, not date_modified

The fetch used the WooCommerce REST **`after`** filter, which matches on
**date_created** (`days_back=30`). So an order was only ever re-fetched for ~30
days after it was created. Any status change that landed later — the common
`processing → completed` transition weeks after purchase — happened **outside the
window**, was never re-fetched, and its status was **frozen in eMed forever**.

There is a second, tighter gate downstream (`days_back_modified`, the
"only update if modified in the last N days" check in `_upsert_orders_chunk`), but
the creation-date window is the hard wall: if the order isn't fetched at all,
that gate never even runs.

Diagnosed via order **#74906**: created 2026-06-05, completed 2026-07-16 (day 41),
still `processing` in eMed. WooCommerce's REST API has a **`modified_after`**
parameter designed for exactly this (change-data-capture); the ETL wasn't using it.

## The fix

`peaks_etl_woo_orders_flow.py` now does **two** paginated pulls, merged/deduped by id:

1. `after` = now − `days_back` (30) — orders created recently (unchanged).
2. `modified_after` = now − `modified_days_back` (**new param, default 7**) —
   orders *modified* recently, regardless of how old they are. This catches late
   status changes after an order ages out of the creation window.

The upsert skip-gate is auto-widened to `max(days_back_modified, modified_days_back)`
so a modified-pull order (older `date_modified` than `days_back_modified`) is never
dropped. `modified_days_back=0` disables the pull. Threaded through the orchestrator
as `days_back_woo_orders_modified_fetch`. The legacy `scripts/peaks_etl_woo_orders.py`
mirrors the change.

**Deploy:** `prefect.yaml` does **not** pin the woo params, so the new default
auto-deploys on the next scheduled Prefect run — **no `prefect deploy` needed**
(a flow-code change, per the emed_etl autodeploy behavior).

## Backfill tool (one-off, re-runnable)

`emed_etl/scripts/backfill_woo_order_status.py` — dry-run by default, `--apply`
to write. Reads `emed_etl/.env` (urllib for WooCommerce, pyodbc for SQL).

- Selects eMed `woo_orders` in a non-terminal status (default
  `processing,on-hold,pending`) created > `--min-age-days` (30) ago — i.e. the
  ones outside the fetch window that can't self-heal. Newer ones self-correct on
  the next ETL run, and the ongoing `modified_after` fix only looks back 7 days,
  so it won't retroactively pull a completion that happened weeks ago — hence the
  one-off.
- Fetches each order's current WooCommerce status (batched via `include=`),
  updates **only** `status` + `date_modified` (+ `date_modified_local`) for orders
  that actually changed. Writes an audit CSV of every from→to.
- **Applied to prod 2026-07-30: 3,898 stale statuses corrected** (3,261
  processing→completed, 544→shipped, 45→refunded, rest on-hold/pending). Backlog
  of `processing`>30d fell 3,940 → 90.

## Residual: hard-deleted WooCommerce orders

~350 candidates (90 of them `processing`) return **HTTP 404** — hard-deleted in
WooCommerce, so there's no source of truth to resync. They keep their last-known
eMed status. That's a separate "deleted-in-WooCommerce" hygiene question; the
`modified_after` fix can't help since the source records are gone. Note also that
a WooCommerce `status=any` query excludes `trash`, so trashed (not deleted) orders
would also read as "not found" by the backfill.

## Related

- Shipment tracking (the reverse direction — tracking numbers back to WordPress)
  is a different pipeline: [ast-shipment-tracking.md](ast-shipment-tracking.md).
- `emed_etl/.env` DB creds target **prod** (`liberty_link_stage`) — always confirm
  `SELECT DB_NAME()` before writing.
