# CRM Scheduling — self-hosted booking pages

**Status:** built 2026-08-07, schema **not yet applied**. Replaces the lapsed Calendly subscription.

## Why we built instead of renewing

Calendly can't touch the CRM. A booking on our own page becomes a real lead touch:
match/create an `emed_crm_lead`, write an `emed_crm_contact` row (`contact_type='Meeting'`),
and point `next_contact` at the meeting. That single contact row is what drives
`last_contact`, the Follow-ups queue and every CRM KPI.

## Surfaces

| URL | Auth | Purpose |
|-----|------|---------|
| `/book/:slug` | anonymous | The booking page. Shareable link + iframe-embeddable. |
| `/book/manage/:token` | token | Invitee cancel / reschedule. |
| `/crm/scheduling` | `View_Menu_CRM` | Hosts, Event Types, Bookings admin. |
| `/api/public/booking/*` | anonymous | Public API (`public_router`). |
| `/api/crm/booking/*` | `View_Menu_CRM` / `Manage_CRM_Scheduling` | Admin CRUD. |

Embed snippet: `public/js/booking-embed.js` + any element with `data-emed-booking="<slug>"`.

## Tables (`emed_sql/migrations/pending/2026-08-07_create_crm_scheduling.sql`)

- **`emed_crm_booking_host`** — the bridge that makes this possible.
  `emed_crm_lead.agent` is a free-text `emed_crm_config` string, **not** an FK to
  `emed_user`, so a rep has no mailbox until mapped here. Carries `mailbox_upn`,
  IANA `timezone`, and `hours_json` (weekly template in the host's own zone).
- **`emed_crm_event_type`** — slug, duration, buffers, min-notice, max-days-out,
  `mode` (phone/teams/in_person), `host_strategy` (fixed/round_robin).
- **`emed_crm_event_type_host`** — M:N pool.
- **`emed_crm_booking`** — UTC instants, SHA-256 `manage_token_hash`,
  `graph_event_id`, `rescheduled_from_id`.

## Gotchas worth remembering

- **The unique index is scoped to `status='booked'` only.** It is what settles two
  simultaneous bookings (loser gets a duplicate-key error → 409). Including
  `'rescheduled'` would pin the vacated slot shut forever.
- **Reschedule never mutates in place** — new `booked` row + old row flipped to
  `rescheduled`, so history survives and the old slot frees up.
- **`emed_crm_booking` is in the lead-merge fan-out** (`route_crm.js`). Any new
  lead child table must be, or merging duplicates orphans its rows.
- **`luxon` is the repo's first date library**, confined to `server/booking.js` and
  `server/graph_calendar.js`. The house idiom
  `new Date(new Date().toLocaleString('en-US',{timeZone}))` is lossy and wrong on
  DST transition days — never use it for anything a customer books against.
- **`express.urlencoded` is commented out app-wide** (`app.js`), so public forms
  must POST JSON with `X-Requested-With: eMed`.
- **`public_cors` sets `credentials:false`**, so the session-gate pattern used by
  payment-capture cannot work inside a cross-origin iframe. Booking is stateless;
  abuse control is rate limiting + a honeypot.
- **Embedding needs BOTH headers rewritten** — helmet sends `frame-ancestors 'self'`
  *and* `X-Frame-Options`. A route-scoped middleware on `/book` handles it from the
  `BOOKING_FRAME_ANCESTORS` allowlist. Never relax it globally.
- **Insert the booking row before calling Graph.** A Graph failure leaves
  `graph_event_id IS NULL` (repairable); the reverse orphans a calendar event.

## Azure consent — a tenant-admin action, not a code change

`BOOKING_GRAPH_SYNC=1` turns on real Outlook free/busy and calendar write-back.
It needs, as **Application** permissions on the existing `AZURE_CLIENT_ID`:

- `Calendars.ReadWrite` — subsumes the `Calendars.Read` that app-only
  `getSchedule` needs, so no separate `Schedule.Read.All`.
- `OnlineMeetings.ReadWrite.All` — only for Teams-mode event types.

⚠ Application permissions are **tenant-wide by default**. The grant must be paired
with an Exchange **Application Access Policy** scoping the app to a sales-reps-only
mail group, or eMed can read every mailbox in the tenant:

```powershell
New-ApplicationAccessPolicy -AppId <AZURE_CLIENT_ID> `
  -PolicyScopeGroupId emed-scheduling-hosts@rxcs.net `
  -AccessRight RestrictAccess
```

Verify it bites: `get_schedule()` against a non-sales mailbox must fail with
`ErrorAccessDenied`. If it succeeds, the policy is not applied — release blocker.

Until consent lands the feature runs on database-only availability, which is fully
usable; it just can't see meetings living only in Outlook.
