---
title: Clarifications / Script Modal by-id endpoints — clinic-scope hardening (PHI IDOR)
slug: clarifications-clinic-scope
status: Completed in Production
project: emed_app
branches:
  - emed_app: feat/clarifications-clinic-scope
developers:
  - nicholas-cardell
prs:
  - "emed_app#508 (feat->main)"
tags: ["1.0.239"]
created: 2026-08-29
updated: 2026-08-29
related: ["[[externalrep-blaze-orders]]", "[[rxpdf-idor-followup]]"]
---

# Clarifications / Script Modal by-id endpoints — clinic-scope hardening

## Status & history
- 2026-08-29 — Not Started → Completed in Production (nicholas-cardell), shipped 1.0.239.

## Summary
Closed a pre-existing **cross-clinic PHI IDOR**. The shared Script Modal's by-id endpoints in
`server/routes/route_clarifications.js` fetched a prescription/patient by a caller-supplied id with
**no clinic-ownership check**. They are reachable by the clinic-scoped **ExternalRep** role (holds
`View_Menu_Clarifications` + `View_Script_Search`), so a rep could read (and via `PUT patient`, write)
**any clinic's PHI** by supplying an arbitrary id. This is the same class fixed earlier for
`/rx-pdf` ([[rxpdf-idor-followup]]) but never extended to its siblings. Found via an audit workflow;
two of the endpoints (`/verify`, `PUT patient`) were caught by the adversarial **pre-ship review**
after the first pass missed them.

## Design / approach
- Two helpers in `route_clarifications.js`: `deny_script_out_of_clinic(req, pharmacyCode, scriptNumber)`
  and `deny_patient_out_of_clinic(req, pharmacyCode, patientId)` — fire **only** for
  `auth.is_clinic_scoped(req)` (internal/global roles unchanged), resolve the row's clinic from the
  pharmacy mirror (`{prefix}_rxqFullOrder.Dr_ClinicName` by `ScriptNumber`; `PatientId` for patient),
  and reuse `auth.filter_by_clinic`. Mirrors the shipped `/rx-pdf` pattern.
- Guarded **9** endpoints: `escript`, `hardcopy`, `hardcopy-tag-log`, `GET patient`,
  `GET /:pharmacy/:scriptNumber/:fillNumber` (detail — filters the mirror row it already fetched, no
  extra query), `notes`, `metadata`, `GET .../verify`, and `PUT patient`. Each denies with its own
  genuine not-found shape so ids can't be enumerated.

## Rollout / remaining
- Code-only, no migration. Shipped 1.0.239 (PR #508). Behavior-neutral for every non-clinic-scoped
  role (Admin/MOCT/Billing/Shipping/Clarifications/Script-Search/API).
- Tests: `tests/unit/server/route_clarifications_script_scope.test.js` (25) — each guarded endpoint
  proves the downstream PHI fetch/write never runs on an out-of-clinic id.
- **Known follow-up (pre-existing, NOT a regression, out of scope):** cross-clinic **write**-scope
  endpoints reachable by ExternalRep but not PHI-read leaks and not exposed in the rep UI
  (Write_Liberty-gated client-side): `POST /clear`, `POST /change-location`, note writes
  (`POST /notes`, `PUT/DELETE /notes/:id`), working-locks. Recommend a fast-follow to scope these
  with the same helper (or gate the Liberty-write ones on `Write_Liberty`).
