---
title: MFA phone — self-service page, IT Support set/clear, first-login offer
slug: mfa-phone-self-service
status: Completed in Production
project: emed_app
branches:
  - emed_app: feat/mfa-phone-self-service
developers:
  - nicholas-cardell
prs: ["emed_app#810 (feat->main)"]
tags: ["1.0.347"]
created: 2026-09-15
updated: 2026-09-16
related: []
---

# MFA phone — self-service page, IT Support set/clear, first-login offer

## Status & history
- 2026-09-15 — Not Started → In-Progress (nicholas-cardell): investigation of a prescriber whose SMS
  login never worked (no `mfa_phone`), then all three fixes built on `feat/mfa-phone-self-service`
  with unit tests. PR emed_app#810 opened against `main`.
- 2026-09-15 — 10-angle review of #810 folded into a second commit (549d169f): every user-facing writer
  now passes `only_if_empty` (change-password + TOTP setup/verify included), failed DB writes are
  failures, NANP-only numbers, the session-grace mechanism was dropped in favor of re-sending the
  typed password. 50 tests.
- 2026-09-16 — In-Progress → Completed in Production (nicholas-cardell): #810 merged (fb1c137d), released as 1.0.347 (83a8c8a0), Azure deploy green, login page verified serving the new build.

## Summary
`emed_user.mfa_phone` is where SMS magic links go. Until now it could only be captured on the
authenticator-app setup form (added 2026-05-01) and on the forced change-password page — so anyone who
enrolled before May, or who picked "magic link" at first login, or who was created with an admin-typed
password, was **email-only for good**, and the only way to fix it was a SQL UPDATE (no admin/helpdesk
UI, no self-service, no link to change-password anywhere). On 2026-09-15: 130 active MFA users, **52
without a phone** (32 of them on magic link = email-only).

Three fixes, one helper:
1. **Self-service page** `GET /mfa-phone` (user menu → "MFA Phone (SMS login)"; the menu also gained
   "Change Password"). Requires the current password; can only **add** a number while none is on file.
2. **IT Support**: masked "MFA Phone" column on `/it-support` + a "Phone" action (set / replace / remove)
   → `POST /api/it-support/mfa-phone`. Changing a saved number is deliberately helpdesk-only.
3. **First-login offer**: after a user's FIRST magic-link (email) login completes, the login page offers
   the optional phone once; Save re-sends the password still in the login form to the same endpoint.
   Returning users are not interrupted.

## Design / approach
- **Single writer.** `server/mfa.js` `set_mfa_phone(user_id, raw, {via, actor, only_if_empty, req})`,
  `clear_mfa_phone`, `mask_phone`. Normalizes via `sms.normalize_phone` and REFUSES anything but `+1` + a
  NANP number (`/^\+1[2-9]\d{2}[2-9]\d{6}$/` — the normalizer passes `+44…`, `'+'` and a dropped-digit
  `+1 305 490 588` → `+11305490588` through verbatim); upserts by id with `ext_where '1=1'` (never falls
  through to INSERT); treats `upsert()`'s `{rows_modified:0, error}` and `select()`'s `null` as FAILURE
  (sql.js never throws — a false "saved" on an MFA destination is the Liberty-timeout lesson); audits
  `MFA_PHONE_SET` / `MFA_PHONE_CLEARED` with `via`, actor, last4, replaced (failures with `success=0`).
- **Security posture kept from 2026-05-01 and now enforced everywhere a user acts on their own row:** no
  phone is ever accepted while MFA is pending (`/mfa/magic-link/send` still refuses; the "SMS not
  available" screen is still info-only — its copy points at the user menu / IT Support). **Users add
  once (`only_if_empty` → 409 `ALREADY_SET`); IT Support changes.** A stolen password + live session
  therefore cannot re-point MFA at another handset — including via change-password (which previously
  overwrote with a valid password) and TOTP re-enrollment (the setup form hides the field when a number
  is on file; the API tolerates already-set / DB errors after the code verified via `phone_note`).
- **`POST /api/auth/mfa/phone`** (route_auth; `mfa_rate_limiter` in app.js): needs `req.session.user`
  and the current password (verified with `users.get_user`; wrong → 401 + `MFA_PHONE_REJECTED`;
  disabled → audited + session destroyed). Always `only_if_empty`. DB failure → 500 "try again".
- **First-login offer:** the login page already holds `loginData.mfa_setup_required` / `has_phone` and
  the typed password (`#inputPassword` is never cleared), so the offer is a client-side decision after the
  poll reports `verified` and Save posts `{mfa_phone, current_password}` — no server flag, no session
  grace, no extra read in the 3-second poll loop. (A first cut used a 10-minute session grace; the
  review showed it duplicated the password proof and was removed.)
- **Helpdesk:** `POST /api/it-support/mfa-phone` `{user_id, mfa_phone}` set/replace or
  `{user_id, clear:true}` (strict `=== true`), `auth.perm('Manage_User_Auth')` + `load_helpdesk_target`
  (ITSupport actors still cannot touch Admin/SuperUser/ITSupport). A clear with nothing on file answers
  "nothing changed" and audits nothing; the admin audit row carries a persisted `description`.
  `GET /api/it-support/users` adds `has_mfa_phone`, `mfa_phone_masked` (last 4 only), `mfa_method`.
- **IT Support table** brought up to the house table standard while touched: sortable headers + funnel
  filters with sibling-narrowed per-value counts. Deliberate, commented exception to `gen_datatable`
  (hand-rendered rows carry the helpdesk action buttons).
- **Page:** `views/auth/mfa-phone.ejs` (main layout) reads `ext.has_mfa_phone` / `ext.mfa_phone_masked`
  / `ext.mfa_method` / `ext.lookup_failed`, THROWS if `ext` is missing, and shows a retry notice on a
  lookup failure instead of defaulting to the add form. Not a sidebar page → not in `page_catalog`
  (same class as `/change-password`; `auth.login` only; page_gate passes unmatched paths).
- Tests: `tests/unit/server/mfa_phone_capture.test.js` (37) and
  `tests/unit/server/it_support_mfa_phone.test.js` (13).
- Code-only: no schema change, no migration, no env var.

## Rollout / remaining
- Ship: gatekeeper merge of #810 (merge commit) + `push prod` tag; `data/changelog.json` entry at ship time.
  Nothing dark — the pages are live on deploy.
- Validate in prod: (1) user menu shows "Change Password" + "MFA Phone"; (2) `/mfa-phone` add with
  password → `MFA_PHONE_SET via=self_service` in `moct_audit_log`; (3) IT Support "Phone" set + remove;
  (4) a fresh test user picking "Send Login Link" → email → sees the offer once, not on the next login.
- Follow-ups (pre-existing, NOT in this PR): `GET /api/auth/mfa/setup` lets a fully signed-in session
  re-enroll TOTP without a password (the phone can no longer ride along); `change-password` verifies a
  password but has no rate limiter; the client-side "SMS unavailable" short-circuit writes no
  `MFA_SMS_UNAVAILABLE` row; `GET /mfa-phone` reads the REAL admin's row during "view as"; a notification
  email/SMS when a user's MFA phone is set or changed; extract the column-filter popup into a shared module.
