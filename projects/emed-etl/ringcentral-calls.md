# RingCentral Call Recordings (emed_etl)

**Status (2026-07-25):** metadata sync is **live in prod** (9,944 rows in
`liberty_link_stage.dbo.emed_call_recording`, all from the `etst` account). The audio
**archive** flow is new as of 2026-07-25 — migration in `emed_sql/migrations/pending/`,
applied to dev, **not yet in prod**, and it needs an Azure Storage account provisioned
before it can run anywhere.

## Two flows, two jobs

| Flow | Deployment | What it does |
|------|-----------|--------------|
| `flows/calls/calls_fetch_recordings.py` | `Calls-Fetch-Recordings`, every 30 min | Call-log **metadata** → `dbo.emed_call_recording` (MERGE on `recording_id`) |
| `flows/calls/calls_archive_recordings.py` | `Calls-Archive-Recordings`, every 30 min (offset 15 min) | Recording **audio** → Azure Blob before RingCentral purges it |

Both share RingCentral JWT auth + the `ringcentral-token-cache` Prefect Variable via
`flows/utilities/ringcentral.py`. (The SMS flows still carry their own copies of that
logic — future refactor.) The 15-minute schedule offset is deliberate: the two flows draw
on the same account's rate-limit budget and shouldn't fire simultaneously.

## The ~90-day cliff (the thing to understand)

RingCentral purges recording **audio** on a rolling ~90-day basis but keeps the
**call-log records** far longer. Consequences:

- Every `content_uri` is a link with an expiry date. After the purge, the metadata row
  survives and the URL 404s forever. **Audio not copied out inside the window is gone.**
- A `dateFrom` older than the window just pages through years of calls whose audio no
  longer exists — hence `RECORDING_RETENTION_DAYS = 92` in the fetch flow.
- RingCentral never keeps recordings under ~30 seconds. 592 of the 9,944 prod rows are
  under 30s, so those always 404 — the archive flow marks them `unavailable`, not `failed`.

## Where the audio goes: Azure Blob, not SQL

Container `call-recordings`, path `rc/{account}/{yyyy}/{MM}/{dd}/{recording_id}.{ext}`.
Only the container-relative path is stored in SQL (`archive_blob_path`) — not a full URL, so
the storage account can change without rewriting every row.

**Do not extend the base64-in-`NVARCHAR(MAX)` pattern to audio.** Measured on prod
2026-07-25: `pop_order_jpg` 29.5 GB + `moct_pdf` 10.2 GB + `moct_jpg` 8.0 GB ≈ **48 GB**, on
a database that is 91 GB allocated / 69 GB used / **22 GB free**. Call audio runs ~669 hours
per 90-day window (~2,800 h/yr) ≈ 40–80 GB/yr of binary, and base64 in `NVARCHAR` costs
×1.33 for base64 then ×2 for UTF-16 = **~110–215 GB/yr in SQL** — it would fill the database
in weeks, and drag through every backup and every nightly dev clone. Blob Cool storage is
roughly an order of magnitude cheaper per GB before that inflation, and blobs support range
requests so a player can seek (you cannot range-read an `NVARCHAR(MAX)` column).

Recommended lifecycle: Hot → Cool at 30 days → **Cold** at 180 days. Not Archive tier —
rehydration takes hours, and a call pulled for a patient complaint is needed immediately.

## PHI

Call recordings between patients and the pharmacy are PHI, and the archive is a **new place
PHI lives**. Requirements:

- Container **private**; anonymous public access disabled at the storage-account level.
- Confirm the Microsoft BAA covers the storage account (Azure Storage is HIPAA-eligible).
- `blob_storage.get_container_client` **refuses to auto-create** the container — an
  implicitly created one silently skips whatever access policy, diagnostic logging and
  lifecycle rules the real one carries. A missing container is an operator error.
- `emed_app` has **no grant** on `emed_call_recording`. When the app surfaces playback it
  needs `SELECT` plus a short-lived user-delegation SAS — a separate migration, deliberately
  not pre-granted.

## RingCentral permission model (the non-obvious part)

1. **App permission `ReadCallLog` / `ReadCallRecording`** (Developer Console, per app):
   enabled only for the `+13053955423` app, whose JWT is the `etst` calls account. The other
   four accounts in `ringcentral-account-creds` are SMS-only (scopes
   `ReadMessages Contacts SMS SubscriptionWebhook EditMessages`) and 403 on call endpoints.
   Accounts opt in by listing `"calls"` in their `"purposes"` array.
2. **User permission "Company Call Log"** (admin portal, per JWT user): NOT granted, so
   account-wide `/account/~/call-log` returns 403 CMN-408 and the flow auto-falls back to the
   extension-level call log (that JWT user's own calls only). Grant it for account-wide coverage.
3. **RingSense / AI Conversation Expert:** not licensed. The insights stage was **removed
   2026-07-24** — it only ever returned 404. The `ai_status` / `ai_summary` / `ai_transcript`
   columns are retained deliberately for a future RingSense license or in-house AI parsing.

## Gotchas

- **Call Log API is in the "Heavy" rate-limit group (~10 req/min)** — much stricter than
  message-store. The fetch flow sleeps 6.5 s between pages.
- **Media (recording content) is a different, less strict group.** The archive flow defaults
  to 1.5 s between downloads (~40/min) and logs the actual `X-Rate-Limit-Group` /
  `-Limit` / `-Remaining` / `-Window` headers on its first response — **tune from that log
  line, not from guesswork.**
- **`content_uri` is not a public URL.** It needs a Bearer token; opening it in a browser 401s.
- **Buffer downloads into a seekable stream** (`SpooledTemporaryFile`), not a raw socket: the
  blob SDK retries a failed chunk by seeking backwards, which an HTTP socket can't do.
- **`requests` strips the `Authorization` header across a cross-host redirect** (`rebuild_auth`).
  That's correct — a pre-signed storage URL carries its own auth — so leave `allow_redirects` alone.
- Every helper in `ringcentral.py` calls `get_run_logger()`, so ad-hoc scripts must run
  **inside a `@flow`** or they raise `MissingContextError`.

## Table

`dbo.emed_call_recording` — `recording_id` (unique), `call_id`, `telephony_session_id`,
`rc_account_phone`, `recording_type`, `direction`, from/to phone + name, `start_time`
(Eastern, naive), `duration_seconds`, `call_result`, `content_uri`, the unused `ai_*`
trio, the `archive_*` bookkeeping columns, + the 5 mandatory fields.

`archive_status` lifecycle: `pending` → `archived` | `unavailable` (purged / never recorded,
terminal) | `failed` (retried until `MAX_ARCHIVE_ATTEMPTS = 5`, then parked).
Work queue is **oldest-first** so budget goes to whatever is closest to the purge cliff,
served by the filtered covering index `ix_emed_call_recording_archive_pending`
(adding `duration_seconds` to its INCLUDE list dropped the query's estimated cost from
0.876 to 0.011 by eliminating a per-row key lookup).

Grants: `emed_etl` SELECT/INSERT/UPDATE only. No DELETE, no `emed_app` access.
