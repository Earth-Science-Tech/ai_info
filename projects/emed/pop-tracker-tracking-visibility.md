# POP Tracker tracking visibility (API + webhook)

**TL;DR:** Tracking numbers captured by the **POP Tracker** desktop app live only in
`pop_order` and never round-trip to Liberty, so they were invisible to the
customer-facing Script API and the tracking webhook. Two fixes now surface them.
Shipped 2026-07-21 (eMed `1.0.127` + emed_sql `main` `b1375bd`).

## The gap

The public Script API and the `moct.script.tracking_added` webhook both source
tracking from **`view_emed_full_order.TrackingNumber`** — i.e. Liberty's own
mirror (`{rxcs,mmed}_rxqFullOrder`, populated by the Liberty ETL). But:

- **Rx Compound Store (rxcs)** packs+ships via the **POP Tracker** app, which writes
  the tracking number to `pop_order.tracking_number` and calls `liberty.mark_picked_up`
  (marks the script picked-up, **sends no tracking**). So the number never reaches
  Liberty → the view shows `OrderStatus='Picked Up'` with **NULL tracking**.
- Contrast the **facility Shipping Module** (`shipping_helpers.sync_rx_to_liberty`),
  which DOES push tracking to Liberty (`post_shipment`) **and** writes `moct_order_tracking`.
  POP Tracker does neither. Only rxcs uses POP Tracker; **Mister Meds (mmed) uses
  neither POP Tracker nor the Shipping Module.**

## Cross-pharmacy fulfillment (key operational fact)

**Mister Meds is not licensed to compound some drugs (e.g. Pentadeca / Pentadeca
Arginate).** Those visits are *routed/billed* to `moct_visit.pharmacy='Mister Meds'`
but are physically **compounded + shipped by Rx Compound Store**, which POP-scans
them. So a "Mister Meds" (Texas) order's tracking legitimately lives in `pop_order`
under `pharmacy='rxcs'`, and its fill mirror is `rxcs_rxqFullOrder` (Pharmacy =
'Rx Compound Store'), not mmed. This is why "Texas orders have no tracking" was
really "RXCS POP tracking isn't surfaced."

## Fix 1 — public Script API fallback (eMed 1.0.127)

`emed.enrich_tracking_from_pop(rows)`: when a row's `TrackingNumber` is empty,
recover it from `pop_order`/`pop_order_rx` by `script_number`+`fill` (also fills
`ShipDate` from the POP submit date). Wired into `get_scripts`, `get_escript`
(`route_public.js`) and `emed.visit_status`, `emed.rx_status` (`emed.js`) — so
`GET /api/public/{scripts,escript,emed/order/:id,moct/visit/:id,emed/rx/:id}` and
the **webhook payload** (the worker builds `data` via `visit_status`) all inherit it.

## Fix 2 — `moct.script.tracking_added` webhook (emed_sql b1375bd)

`usp_etl_emed_script_webhook_events` now diffs an **effective tracking** =
`COALESCE(view.TrackingNumber, RXCS pop_order tracking)` against
`emed_script_status_snapshot`. So the webhook fires for POP tracking too — once,
and only if the Liberty path hadn't already fired (existing snapshot dedup).
**Recency gate (`fire_ok`):** POP-sourced tracking only *fires* when
`pop_order.date_created` is ≤ 7 days old (don't spam a backlog of old shipments);
older POP tracking is still recorded/baselined in the snapshot (never fires) and
stays visible via the API. Liberty-sourced tracking is unchanged. No app/ETL
deploy needed — the proc lives in the DB; the ETL runs it next cycle; `emed_etl`
was granted SELECT on the POP tables.

## Gotchas (bit us / worth knowing)

- **`misc.fmt_pharmacy()` is a closed set that silently defaults unknown names
  (incl. `'Mister Meds'`) to `'rxcs'`.** Do NOT use it to scope POP enrichment.
  Both fixes gate strictly on the exact view literal `Pharmacy = 'Rx Compound Store'`.
- **Liberty `ScriptNumber`s are per-pharmacy sequences** — the same number can exist
  under rxcs AND mmed. An unscoped POP join would staple rxcs tracking onto an mmed
  order. Hence the RXCS-only scope + `po.pharmacy='rxcs'` in the lookup.
- **`moct_order_tracking` is a dual-writer, Peaks-centric table.** The ETL
  (`usp_etl_moct_order_tracking`) only writes rows with a `clinic_order_id`
  (in practice only Peaks); the facility Shipping Module writes the rest with
  `clinic = ship_to_name`. Its only automated notifier (`peaks_update_ast.py`) is
  Peaks/`MOC TELEDOC`-scoped AND keyed on `clinic_order_id`. So writing POP rows
  there would notify no one — that's why Fix 1 reads `pop_order` directly and the
  original "durable write to moct_order_tracking on POP submit" idea was dropped.
- **Webhook detector fires only for scripts already in the snapshot** (new ones seed
  silently). Before changing what feeds the diff, measure the first-run backfill
  ("would_fire") to avoid flooding subscribers.

## Does NOT fix

- **Genuine Mister-Meds-filled orders** — no POP data at all; needs mmed to enter
  tracking in their PharmacyOne (the ETL already mirrors it for ~59% of mmed orders)
  or adopt POP Tracker.
- **Bypassed POP scans** — if the packer bypasses verification without scanning a
  label, tracking is captured nowhere (nothing to recover).

## Key files

- `emed_app/server/emed.js` — `enrich_tracking_from_pop`, `visit_status`, `rx_status`
- `emed_app/server/routes/route_public.js` — `get_scripts`, `get_escript`, POP ingest (`post_pop_order`)
- `emed_sql/migrations/applied/2026-07-21_pop_tracking_added_webhook.sql` — the proc change
- `emed_sql/.../procedure_usp_etl_emed_script_webhook_events.sql` — the detector proc
- See also [webhook_system.md](webhook_system.md) (event list) and the POP API spec in `pop-tracker/docs/`.
