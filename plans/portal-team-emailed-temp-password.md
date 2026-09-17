---
title: Portal-user add forms email the temporary password (My Facilities · portal My Team)
slug: portal-team-emailed-temp-password
status: Completed in Production
project: emed_app
branches:
  - emed_app: feat/portal-team-emailed-temp-password
developers:
  - nicholas-cardell
prs: ["emed_app#848 (feat->main)"]
tags: ["1.0.358"]
created: 2026-09-17
updated: 2026-09-17
related: [rep-team-and-facility-api-credentials]
---

# Portal-user add forms email the temporary password

## Status & history
- 2026-09-17 — Not Started → In-Progress (nicholas-cardell): built, unit suite green (330 files / 7,370
  tests), both forms exercised live on the dev DB (facility 1924 "Test Victoria": user 222 via My Facilities
  as staff, user 223 via the portal's My Team impersonating the Primary Prescriber; both emailed, both rosters
  refreshed, test memberships removed afterwards).
- 2026-09-17 — In-Progress → Completed in Production (nicholas-cardell): PR emed_app#848 merged to main
  (merge commit c38ae44a, all 4 CI checks green), changelog entry 1.0.358 curated, tag `1.0.358` pushed,
  Azure deploy run 35180081820 succeeded. No schema change, no data step.

## Summary
Nick, after 1.0.357 shipped: the "My Team · portal users" add form on My Facilities (Mario's #832, 1.0.352)
and the prescriber portal's own "Add Team Member" asked the admin to TYPE a temporary password, while the new
Rep Team form generates one and emails it. Both now behave and look like Rep Team: **name / phone / email
(becomes the login) / capability**, no password field, the temporary password generated server-side and
emailed through the existing welcome path.

## Design / approach
- **One writer for the password rule — `server/portal_team.js add_member`** (the shared core both surfaces
  already call): `user_login` defaults to the lower-cased email; when the caller sends no `password`, the
  server generates one via the new **`users.generate_temp_password()`** (14 url-safe chars; `rep_team.js` now
  delegates to it, so Rep Team and portal users share the generator). A supplied `user_login`/`password` is
  still honoured for API callers.
- **Show-once fallback, never an echo:** `add_member` returns `temp_password` ONLY when the welcome email
  failed AND the server generated the password. A caller-supplied password is never echoed. Both route
  wrappers (`route_facilities POST /:id/team`, `route_prescriber POST /team`) pass `user_login` +
  `temp_password` through; both modals render the once-only block ("Account created, but the welcome email
  could not be sent…") in place of the form, with Cancel → Close — the same shape as Rep Team.
- **Forms** (`views/reptools/facilities.ejs` `#rfTeamModal`, `views/prescriber/team.ejs` `#tmModal`): Full
  name*, Phone, Email* (hint: becomes their login; sign-in details are emailed here), Capability* (tier
  select; DEA/NPI/Licensed States appear for signing tiers as before), helper "eMed emails a temporary
  password; they choose their own at first sign-in and set up two-factor authentication.", button "Create
  account" (Save in edit mode). Identity fields still hide in edit mode (`.rft-new-only` / `.tm-new-only`).
- No schema change. `password_change_required=1` is unchanged (the temp password is single-use by design).

## Rollout / remaining
- Ship: PR `feat/portal-team-emailed-temp-password → main`, changelog entry, tag.
- Suites: `portal_team` (+4: generated password + email-as-login, once-only fallback, never echo a supplied
  password, generator shape), `route_facility_team` (+1 pass-through, and the success pin now asserts no
  password when it emailed), `rep_team` (seeded users mock gains `generate_temp_password`).
- Known: an admin who wants to hand-type a password can no longer do so from either UI (deliberate — nobody
  types a password for someone else); the staff Users card on Facilities and API & Clinic User Management
  still take a typed password (staff surfaces, out of scope).
