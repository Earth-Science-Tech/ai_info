# eMed Webhook System

**Status:** built and verified end-to-end on `liberty_link_dev`, 2026-05-05. Pending push to prod.

## What it does

Self-service HMAC-signed POST notifications for clinics with API access, replacing polling against `/api/public/moct/visit/:VisitId` (and, for the `pharmacy.script.*` family, `/api/public/scripts`). Ten event types:

| Event | Source | Trigger |
|---|---|---|
| `moct.visit.created` | Node | `POST /api/public/moct-visit` insert path in `route_public.js`. **Also fired by `POST /api/public/script-refill`** (rewritten 2026-05-29) when a refill MOCT visit is created — refills flow through the same subscriber pipeline as new orders. **Also fires for External Prescription API orders** (`POST /emed/order` → `emed.create_external_prescription` → `emit_event('moct.visit.created')`, status "Externally Prescribed") — an external order IS a MOCT visit, so the whole `moct.*` family covers it. |
| `moct.visit.status_changed` | Node | `POST /api/moct/set-status` in `route_moct.js:418` (after audit log) |
| `moct.script.status_changed` | ETL | `usp_etl_emed_script_webhook_events` diff on `view_emed_full_order.OrderStatus`. MOCT-linked scripts only (`MocTag IS NOT NULL`, exact clinic match) — includes externally-prescribed orders' scripts. |
| `moct.script.tracking_added` | ETL | same proc, when `TrackingNumber` goes from empty to non-empty (MOCT-linked only) |
| `moct.prescription.signed` | Node | `POST /api/moct/sign-prescriptions` in `route_moct.js`, **only for `pharmacy='Prescription Only'` visits**. Prescription-Only feature (2026-06-29): clinic gets the signed Rx back to route to its own / a 3rd-party pharmacy instead of our Liberty pharmacies. **Distinct `data` shape** — see below. |
| `moct.prescription.held` | Node | Pre-Clarification gate in `emed.sign_prescriptions` (via `preclar_gate`) when a rule stops a script **before it reaches the pharmacy**. `change`: `{kind:'prescription_held', drug_rx_id, rule_id, rule_name, reason, channel}`. `data` is the standard visit object, annotated with a `PreClarification` block while anything is held. Lets a subscriber tell a held order from a merely-slow one (partner `POST /emed/order` returns "Processing" before the gate runs). |
| `moct.prescription.released` | Node | `preclar.release_hold` when a held script is reviewed and released (or overridden) and submitted to the pharmacy. `change`: `{kind:'prescription_released', drug_rx_id, rule_id, overridden, released_by}`. |
| `pharmacy.script.created` | ETL | **NEW 2026-08-04.** Same proc `usp_etl_emed_script_webhook_events`, second enqueue. Fires for **EVERY** script at a subscribed clinic (eMed + external Blaze/eScripts), when a `(pharmacy, script_number, fill)` key first appears **and** is recent (recency guard, see below). `change` kind `script_created`. **Distinct `data` shape** — script-centric, mirrors `GET /api/public/escript` (built by `emed.script_payload()`), NOT the visit object. |
| `pharmacy.script.status_changed` | ETL | same proc, `OrderStatus` diff, for ALL scripts at the clinic (not just MOCT-linked). `change` kind `script_status`. |
| `pharmacy.script.tracking_added` | ETL | same proc, tracking first-appears, for ALL scripts. `change` kind `tracking`. |

**The `pharmacy.script.*` family (2026-08-04)** is polling-parity for `GET /api/public/scripts` (which already returns eMed + non-eMed scripts by `Clinic LIKE`), so it exposes no new data — poll → push. Clinic scoping mirrors that pull API's **substring** match (`e.Clinic COLLATE ... LIKE '%'+emed_user_clinic.clinic+'%'`, `LEN>=4` floor), NOT the exact match the `moct.*` path uses. `moct.script.*` semantics are unchanged (the enqueue is a separate INSERT). Subscribing to both families means eMed scripts notify twice — docs tell clinics to pick one.

> **held/released documented + subscribable as of 2026-07-31** (emed_app PR #298, tag 1.0.170). Both were *emitted in code* since the Pre-Clarification Gate shipped (1.0.168) and accepted by the subscription validator, but were missing from the API docs and the **Add Webhook** UI checkboxes until #298 — so no integrator could actually subscribe. Existing subscribers must edit their webhook and tick the new boxes (new webhooks get all seven checked by default).

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

### `moct.prescription.signed` (different `data` shape)

For this one event the worker builds `data` via `emed.signed_prescription_payload(visit_id, clinic)` instead of `visit_status()`. It carries full prescriber details + the **signed Rx PDF(s) as base64** so the clinic can hand the prescription to its own / a 3rd-party pharmacy:

```json
{ "VisitId": 42, "Clinic": "Helimeds", "Pharmacy": "Prescription Only",
  "Prescriber": { "Name": "...", "NPI": "...", "DEA": "...", "Address": "...", "City": "...", "State": "...", "Zip": "..." },
  "Patient":    { "FirstName": "...", "LastName": "...", "DateOfBirth": "...", ... },
  "Prescriptions": [ { "RxId": 100, "DrugName": "...", "Sig": "...", "Quantity": "...", "Refills": 2,
                       "Filename": "Rx[42-100].pdf", "SignedPdfBase64": "JVBERi0x..." } ] }
```

The same object is available via pull at `GET /api/public/moct/visit/:VisitId/prescriptions` (clinic-scoped, Prescription-Only visits only) for clinics that poll instead of receiving webhooks. Intake: `POST /api/public/moct/visit` with `"PrescriptionOnly": true` sets `moct_visit.pharmacy='Prescription Only'` + `pharmacy_locked=1` (staff can't reassign it to one of our pharmacies; `set-pharmacy` enforces). On sign, `emed.sign_prescriptions` skips Liberty for `Prescription Only` (and legacy `Other`) and still persists the PDF to `moct_pdf`.

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
- **Non-MOCT scripts** were excluded from v1 (no visit → no visit-parity payload). **Shipped 2026-08-04 as the `pharmacy.script.*` family** instead: a script-centric `data` payload (mirrors `GET /api/public/escript`, built by `emed.script_payload()`), so no visit is needed. The detection proc `usp_etl_emed_script_webhook_events` was widened (one migration, no new tables) — see below.
- **`pharmacy.script.*` rollout / blast control** (`emed_sql/migrations/.../2026-08-04_pharmacy_script_webhook_events.sql`):
  - Proc gained `@created_lookback_days INT = 2` (default keeps ETL's arg-less `EXEC` working). `created` fires only for keys absent from the snapshot AND recent — anchor is `COALESCE(EffectiveDate, LastModified)`; **`EffectiveDate` is ~95% NULL on external rows** (measured on dev), so in practice the guard is "recently modified".
  - **Onboarding a subscriber**: after they enable a `pharmacy.script.*` type, run once with `EXEC dbo.usp_etl_emed_script_webhook_events @created_lookback_days = 0` to baseline their clinic's existing scripts into `emed_script_status_snapshot` firing **zero** `created`. Normal cadence then takes over. "created" ⇒ "written since you subscribed."
  - **R1 regression guard**: the `ROW_NUMBER()` dedup now prefers `MocTag IS NOT NULL` first, so a newly-in-scope MocTag-NULL sibling can never displace the `moct.*` winner (keeps `moct.script.*` byte-identical).
  - **Clinic-name leak note**: substring match reaches multi-clinic on short/generic registered names (same as the `/scripts` pull API today — e.g. `test`→"Testosterone…", `Kendall`→5 practices, `Envy`→RENVY). These are staff-assigned `emed_user_clinic` values that already govern that account's `/scripts` pull reach, so webhooks grant no new access — but review such names before enabling `pharmacy.*` for the account. Audit query: any `emed_user_clinic.clinic` (LEN<6) that substring-matches >1 distinct `view_emed_full_order.Clinic`.
  - Worker branch: `webhook_worker._deliver_one` routes `event_type` starting `pharmacy.script.` to `emed.script_payload(change.pharmacy, change.script_number, change.fill_number, row.clinic)` (defense-in-depth `can_view_rx` re-check inside). `visit_id` is NULL for these — the PHI audit line carries a `script=<pharmacy>/<num>:<fill>` ref instead.

## Verification

End-to-end smoke test confirmed:
1. config + delivery row INSERT → claim → emed.visit_status fetch → HMAC sign → POST → 200 OK → status='delivered'
2. HMAC verifies against the displayed secret
3. `X-eMed-Event-Id` matches between insert and delivery
4. Envelope shape: `{event_id, event_type, occurred_at, change, data}`

The trigger `trg_emed_user_clinic_sync` was independently verified for add/remove/reactivate semantics with no duplicate rows.
