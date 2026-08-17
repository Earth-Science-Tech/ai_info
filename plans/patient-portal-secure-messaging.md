---
title: Patient Portal + Secure Messaging (Phase 1)
slug: patient-portal-secure-messaging
status: Completed in Production
project: multi
branches:
  - emed_app: feat/patient-portal-secure-messaging (shipped 1.0.205)
  - emed_sql: migrations/applied/2026-08-14_add_patient_portal_and_secure_messaging.sql (prod+dev)
developers:
  - nicholas-cardell
prs: []
tags: ["1.0.205"]
created: 2026-08-14
updated: 2026-08-17
related: [[facility-scope-groups]]
---

# Patient Portal + Secure Messaging (Phase 1)

## Summary

HIPAA-safe replacement for texting PHI: staff write a **Secure Message** to a patient, the patient gets
a **PHI-free SMS magic link**, authenticates (SMS link + DOB step-up), and reads it in a chrome-less
**Patient Portal** isolated from staff auth. Ships with per-facility × per-page portal config
(default-deny). Full design in the local plan-mode doc; this is the shared status record.

## SHIPPED TO PRODUCTION 1.0.205 — but **DARK** (kill-switch off)

The whole feature is gated behind **`SECURE_MESSAGING_ENABLED`** (default **off**), so in prod today:
- Staff send endpoint `POST /api/secure-messages` returns **403**.
- Returning-login SMS (`/api/portal/public/request-link`) is a **no-op**.
- The "Send Secure Message" button + modal on `views/moct/visit.ejs` are **omitted server-side**.
- With no message ever sent, **no magic-link token is minted → no patient can log in.** The `/portal/*`
  pages are reachable but inert (need a token that can't be obtained).

So the code + 6 tables are live and inert. Shipped alongside the facility-scope work because they share
`views/admin/facilities.ejs`. See [[facility-scope-groups]].

## Deploy facts / gotchas

- **Migration:** `2026-08-14_add_patient_portal_and_secure_messaging.sql` — 6 tables
  (`patient_portal_user/person/token`, `moct_secure_message`, `patient_portal_page_config`,
  `patient_portal_facility_origin`), additive, applied to prod+dev, now in `migrations/applied/`.
- **⚠ Required prod env var: `PATIENT_PORTAL_SESSION_SECRET`** — `app.js` **fail-fasts on boot in prod**
  if unset (dedicated Patient Portal session `eMed.pportal`, isolated from the staff `SESSION_SECRET`).
  Set in the App Service config at go-live. (Renamed from the original `PORTAL_SESSION_SECRET` before
  ship — it's Patient-Portal-specific, not shared with the PO/Inventory portals.)
- `SECURE_MESSAGING_ENABLED` left **unset** on prod (dark). Also `PORTAL_LINK_EXPIRY_HOURS` (default 72),
  `DEV_SMS_PHONE` (dev only).
- New permission flag `Send_Secure_Message` + `PERM_SCHEMA_VERSION` 2→3 (transparent session upgrade).

## TO ENABLE (later phase — product-owner, not code)

1. Signed **BAA with RingCentral** + confirm App Insights redaction doesn't capture the number/link.
2. **Patient consent** to electronic/SMS comms (TCPA + HIPAA) before first send.
3. Per-facility enable the Messages page in Facilities → Patient Portal (default-deny).
4. Tick `Send_Secure_Message` on the MOCT/Prescriber custom-role rows.
5. Set `SECURE_MESSAGING_ENABLED=1` in the prod App Service config.
6. **Phase 2** (deferred): cross-origin iframe embedding (`eMed.pportal` → `SameSite=None; Partitioned`;
   per-facility `patient_portal_facility_origin` allowlist drives frame-ancestors/CORS).

## Status & history
- 2026-08-14 — Built on `feat/patient-portal-secure-messaging` (emed_app + emed_sql), dev-applied, 29
  unit tests green. Isolated passwordless patient identity, SMS magic-link + DOB, PHI-free notification
  via `emed_sms` queue, per-facility×per-page config (default-deny).
- 2026-08-17 — **SHIPPED TO PRODUCTION 1.0.205, DARK.** Added `SECURE_MESSAGING_ENABLED` kill-switch,
  renamed the session secret → `PATIENT_PORTAL_SESSION_SECRET`, promoted `feat/* → main`, migration to
  prod. Verified prod boots healthy with the secret set and no send path reachable. Enable via the
  checklist above once BAA/consent are in place.
