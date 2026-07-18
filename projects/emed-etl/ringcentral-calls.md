# RingCentral Call Recordings + AI Insights (emed_etl)

**Status (2026-07-17):** built and verified against dev; **not yet in prod**. Flow code
on Carlos Cueto's machine (emed_etl PR pending). Schema on `liberty_link_dev` only —
migration parked at `emed_sql/migrations/wip/2026-07-17_add_emed_call_recording.sql`.

## What it is

`flows/calls/calls_fetch_recordings.py` (flow `calls_fetch_recordings`) syncs
call-recording metadata from the RingCentral call log into `dbo.emed_call_recording`,
then fetches RingSense AI insights (summary + transcript JSON) for each recording.

- Shares RingCentral JWT auth + the `ringcentral-token-cache` Prefect Variable with the
  SMS flows via the new shared module `flows/utilities/ringcentral.py`. (The SMS flows
  still carry their own copies of that logic — future refactor.)
- Upsert pattern mirrors `emed_sms`: temp table + MERGE on `recording_id`
  (fast_executemany + pinned `setinputsizes` to dodge the HY090 temp-table gotcha).
- AI insights lifecycle: rows start `ai_status='pending'` → `available` (insights
  stored) or `unavailable` (no insights after 7 days). RingSense 403 aborts the stage
  gracefully, leaving rows pending.
- Deployment `Calls-Fetch-Recordings` defined in `prefect.yaml` (every 30 min,
  rxcs queue) but **not yet `prefect deploy`ed**.

## RingCentral permission model (the non-obvious part)

Three separate gates, all verified empirically 2026-07-17:

1. **App permission `ReadCallLog`** (RingCentral Developer Console, per app):
   enabled for the **+13053955423** account's app only. The other four accounts in the
   `ringcentral-account-creds` secret block (+13057865825 default, +13057865021,
   +13053954764, +17543152607) are SMS-only — their scopes are
   `ReadMessages Contacts SMS SubscriptionWebhook EditMessages`, and call-log calls 403.
   Hence `DEFAULT_CALL_ACCOUNTS = ["+13053955423"]` in the flow.
2. **User permission "Company Call Log"** (RingCentral admin portal, per JWT user):
   NOT granted for +13053955423's JWT user → account-wide `/account/~/call-log` returns
   403 CMN-408. The flow auto-falls back to the extension-level call log (JWT user's own
   calls only). Grant this user permission for account-wide coverage.
3. **RingSense / AI Conversation Expert** (license + app permission): insights endpoint
   `/ai/ringsense/v1/public/accounts/~/domains/pbx/records/{recordingId}/insights`
   returns **403** today → not licensed or app permission missing. AI summaries won't
   populate until this is resolved; recordings sync regardless.

## Gotchas

- **Call Log API is in the "Heavy" rate-limit group (~10 req/min)** — much stricter than
  message-store. Flow sleeps 6.5 s between pages and honors 429 Retry-After.
- **RingCentral purges recordings** on a rolling basis and never keeps recordings
  < 30 seconds. `content_uri` links die when the recording is purged — if a permanent
  audio archive is ever needed, download to Azure Blob (phase 2; not implemented).
- **RingSense insights lag the call** by minutes; the flow re-checks pending rows each
  run and gives up (marks `unavailable`) after 7 days.
- Recording playback via `content_uri` requires a bearer token — it is not a public URL.

## Table

`dbo.emed_call_recording` — recording_id (unique), call_id, telephony_session_id,
rc_account_phone, recording_type, direction, from/to phone + name, start_time (Eastern,
naive), duration_seconds, call_result, content_uri, ai_status, ai_summary,
ai_transcript (raw insights JSON), + the 5 mandatory fields.
Grants: `emed_etl` SELECT/INSERT/UPDATE only (no DELETE; no `emed_app` access yet).
