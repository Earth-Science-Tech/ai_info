# eMed Webhook System

**Status:** built and verified end-to-end on `liberty_link_dev`, 2026-05-05. Pending push to prod.

## What it does

Self-service HMAC-signed POST notifications for clinics with API access, replacing polling against `/api/public/moct/visit/:VisitId`. Four event types:

| Event | Source | Trigger |
|---|---|---|
| `moct.visit.created` | Node | `POST /api/public/moct-visit` insert path in `route_public.js` |
| `moct.visit.status_changed` | Node | `POST /api/moct/set-status` in `route_moct.js:418` (after audit log) |
| `moct.script.status_changed` | ETL | `usp_etl_emed_script_webhook_events` diff on `view_emed_full_order.OrderStatus` |
| `moct.script.tracking_added` | ETL | same proc, when `TrackingNumber` goes from empty to non-empty |

Subscribers register endpoints at **API Portal → Webhooks** (`/moct/api-webhooks`). Permission: `Write_Webhooks` (granted to `API`, `Admin`, `SuperUser`).

## Payload shape

The body mirrors `GET /api/public/moct/visit/:VisitId` so subscribers can drop polling without changing parsers.

```json
{
  "event_id":   "<uuid>",
  "event_type": "moct.visit.status_changed",
  "occurred_at":"<ISO 8601>",
  "clinic":     "Peaks Curative",
  "change":     { "kind": "status", "previous_status": "...", "new_status": "..." },
  "data":       { /* exact emed.visit_status(visit_id, clinic) output, including Prescriptions[] */ }
}
```

The `data` block is built **at delivery time** by the worker calling `emed.visit_status()` so it stays in sync with the polling endpoint forever. The `change` block is event-specific and is the only thing the emitter / detection-proc actually stores in the queue.

**PHI is in the payload** (DrugName, ShippingAddress, ShippedPhone — same as polling). Each delivery is logged via `audit_logger.log_phi_access`.

## Headers

- `X-eMed-Signature: t=<unix>, v1=<hex>` — HMAC-SHA256 over `t + "." + body`. Reject if `|now - t| > 300s`.
- `X-eMed-Event-Id: <uuid>` — same UUID across retries; subscribers should dedupe.
- `X-eMed-Event-Type: <event_name>`

## Architecture

```
   Node /api/moct/set-status      ┐
   Node /api/public/moct-visit    ├─→ webhook_emitter.emit_event() ─┐
   ETL usp_etl_emed_script_*      ┘                                 │
                                                                    ▼
                                              INSERT emed_webhook_delivery (status='pending')
                                                                    │
                                          webhook_worker tick (5s) + kick() ◀── emitter pokes for sub-second
                                                                    │
                                            claim → build envelope (calls emed.visit_status())
                                            → HMAC sign → POST (10s timeout, 10 in parallel)
                                                                    │
                                                  delivered / pending+backoff / dead
```

### Tables

- `emed_webhook_config` — subscription registry (`url`, `event_types` pipe list, `signing_secret_hash` NVARCHAR(64), `signing_secret_encrypted` AES-256-GCM, `is_active`, `consecutive_failures`)
- `emed_webhook_delivery` — queue + history (`config_id`, `event_id`, `event_type`, `clinic`, `visit_id`, `payload` = the small `change` block, `status`, `attempt_count`, `scheduled_at`, response fields)
- `emed_script_status_snapshot` — last-emitted state per MOCT-linked script (drives ETL diff)
- `emed_user_clinic` — normalized mirror of `emed_user.clinics` pipe field, kept in sync by `trg_emed_user_clinic_sync` trigger on `emed_user`. Drop-in replacement for any code that needs to query "users at clinic X" without parsing pipe strings.

### Key code paths (emed_app)

- `server/webhook_crypto.js` — `generate_secret`, `hash_secret` (hex SHA-256), `encrypt_secret`/`decrypt_secret` (AES-256-GCM with `WEBHOOK_SECRET_KEY` env var), `sign_payload`
- `server/webhook_emitter.js` — `emit_event(event_type, visit_id, clinic, change)`. Subscriber join on `emed_user_clinic`. Calls `webhook_worker.kick()` after enqueue.
- `server/webhook_worker.js` — `start()` / `stop()` / `kick()` / `invalidate_secret_cache()`. Single in-process worker, conditional UPDATE claim, exponential backoff (60s → 6h capped, 8 attempts), auto-disable at 20 consecutive failures.
- `server/routes/route_webhooks.js` — full CRUD + rotate-secret + test + redeliver, all gated on `Write_Webhooks`.
- `views/moct/api-webhooks.ejs` — UI (Bootstrap 5 + jQuery + datatables + Toastr), one-time-show secret modal, recent deliveries panel.

### Key code paths (emed_etl)

- `flows/run_all_etl_flow.py` calls `usp_etl_emed_script_webhook_events` after `usp_etl_moct_order_tracking` on every cycle (15-min cadence). The proc filters to MOCT-linked scripts at clinics with active subscribers, diffs against the snapshot, enqueues delivery rows, MERGEs the snapshot. First run silently seeds.

## Operational notes

- **`WEBHOOK_SECRET_KEY` env var** must be set on Azure App Service. Generate with `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`. Rotating it requires re-encrypting all `signing_secret_encrypted` rows — undocumented runbook for now, treat as long-lived.
- **Auto-disable**: a webhook flips to `is_active=0` after 20 consecutive `dead` deliveries. Surfaces as a red badge in the UI. Re-enable via Edit modal.
- **Worker scope**: single Azure App Service instance assumed. The conditional UPDATE in `_claim_one()` is safe under future scale-out (loser hits `rowsAffected=0` and skips).
- **Latency**: Node-emitted events deliver in <500ms (verified) thanks to `kick()`. ETL events arrive within ~5s of the proc completing.
- **Non-MOCT scripts**: deliberately excluded from v1. They have no visit, so no polling-parity payload exists. v2 could add `moct.rx.status_changed` with a different shape if clinics ask.

## Verification

End-to-end smoke test confirmed:
1. config + delivery row INSERT → claim → emed.visit_status fetch → HMAC sign → POST → 200 OK → status='delivered'
2. HMAC verifies against the displayed secret
3. `X-eMed-Event-Id` matches between insert and delivery
4. Envelope shape: `{event_id, event_type, occurred_at, change, data}`

The trigger `trg_emed_user_clinic_sync` was independently verified for add/remove/reactivate semantics with no duplicate rows.
