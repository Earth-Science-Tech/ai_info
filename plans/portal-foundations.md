---
title: Prescriber & Clinic Portals + Rep Tools — Program (Facilities-Hub model)
slug: portal-foundations
status: In-Progress
project: multi
branches:
  - emed_app: feat/portal-foundations
  - emed_sql: feat/portal-foundations-schema
developers:
  - mario-tabraue
prs: []
tags: []
created: 2026-08-26
updated: 2026-08-26
related:
  - "[[facility-scope-groups]]"
  - "[[patient-portal-secure-messaging]]"
  - "[[per-page-permissions]]"
---

# Prescriber & Clinic Portals + Rep Tools — Program (Facilities-Hub model)

## Status & history
- 2026-08-26 — **Phase 2 built** (Facilities-hub management + in-portal delegation) on
  `feat/portal-foundations` @ 7d7b0a0b; **awaiting Mario's Phase-2 review**. The Facilities page
  now carries the Prescriber Portal Settings panel (master/type/channel/enforcement + default-deny
  page toggles, saved with the facility) and a tier-aware Users card: ExternalPrescriber accounts
  create/edit through the structured-scope path (`POST /api-users` extended), portal capability
  tiers + licensed states (moct_prescriber_license reuse via new set_state_list) + staff-side
  attestation record/revoke. New `/prescriber/team` delegation page + `/api/prescriber/team` API:
  can:manage_users tier gate, enforcement-aware attestation gate (ships dark), last-admin guard,
  colleague creation via new `users.create_portal_account`. Group edits re-sync group-materialized
  memberships. Page fully registered (page_catalog/REQUIRES/nav/sidebar; registry check green,
  118 pages). +10 delegation-authz tests; suite 3,968 green. No schema change (rides Phase 1).
- 2026-08-26 (later) — **Phase-1 review round 1** (Mario): four directives folded in, commits
  eMed 0ca5c29c + emed_sql df5cb1d (both dev-applied).
  (1) **Patient model DECIDED**: each facility owns its patient records; the same human exists
  as separate rows per facility BY DESIGN (already structural via clinic-namespaced
  external_id); within one facility the clinic + prescriber portals share the same rows via the
  A5 seam; cross-facility visibility NEVER surfaces provider-side; an INTERNAL-ONLY identity
  link (Nick's patient_portal_person junction) serves pharmacy safety + the patient portal —
  confirm junction privacy in the D14 conversation. Intra-facility dedup/merge (two channels
  minting two rows for one person) lands in Phase 3 patient management.
  (2) **Group memberships**: external prescribers may be granted facility GROUPS —
  emed_portal_membership.source_group_id + assign_group_membership/recompute_group_memberships
  (materialized per-facility rows, provenance-tagged, re-synced on group edits).
  (3) **Licensed states**: REUSE the existing moct_prescriber_license store +
  /admin/prescriber-licenses (works for external prescribers as-is — no new table). Onboarding
  (Phase 6) and the Facilities hub (Phase 2) must capture states into it. New
  portal_channel_suggest.js: patient state outside the prescriber's active unexpired Medical
  states -> RECOMMEND the Clinic Portal (advisory, never a block; no rows yet -> no redirect).
  (4) **Phase-5 scope change**: the email-the-patient questionnaire dispatch (+ patient-portal
  link) is ON HOLD per Nick. INTERIM RULE: every clinic-portal submission REQUIRES a manually
  uploaded Medical Questionnaire (MQ) attachment at creation until the dispatch feature rolls
  out. D18 -> HELD.
  Also: session re-anchored into the eMed project; both worktrees re-verified current with prod
  (origin/main = 1.0.228, 0 behind, both repos). Suite: 3,957 green.
- 2026-08-26 — Phase 1 (Foundations A1–A9) built on `feat/portal-foundations` @ 924df669 +
  `emed_sql feat/portal-foundations-schema` @ 136e15e; **awaiting Mario's Phase-1 review**.
  Decisions locked with Mario: D21 = NEW `emed_portal_thread`/`_message` (not
  moct_secure_message); backfill tiers = ExternalPrescriber->primary_prescriber,
  ClinicUser->medical_assistant; A4 enforcement = per-facility flag, DEFAULT OFF (ships dark).
  Shipped: migration `2026-08-26_add_portal_foundations.sql` (wip/, **dev-applied**, drift-clean:
  5 tables + 4 emed_facility columns) · `portal_membership.js` (tier catalog +
  require_portal_role) · `prescriber_portal_config.js` (patient-portal config clone +
  portal_type/submission_channel + GET/PUT on route_facilities) · `portal_attestation.js`
  (HMAC artifacts; create_external_prescription now persists the submission attestation) ·
  `portal_status.js` (derived 7-status mapper) · `portal_patients.js` (resolver seam) ·
  `portal_masking.js` (tiered projection) · `portal_threads.js` (the one primitive) ·
  `Write_Portal_Memberships` flag + PERM_SCHEMA_VERSION 4 · `scripts/portal_membership_backfill.js`
  (dry-run default; NOT yet run with --apply). 133 new unit tests; full suite 3,947 green.
  **A9 conventions** (standing rules for every later phase): store code WITH text
  (RxNorm/SNOMED/NDC) on new clinical fields · identity split practitioner/role/organization
  when identity tables land · structured per-state expiring credentials · append-only clinical
  records (amend, never mutate) · tenant key (facility_id) on every new row · PHI audit on reads
  AND writes via log_phi_access.
  Notable: an abandoned May wip draft (`2026-05-12_add_emed_messaging.sql`, `emed_message_*`)
  exists parked — no collision with `emed_portal_thread`; flag to Nick before anyone revives it.
- 2026-08-26 — Not Started → In-Progress (mario-tabraue) — Plan v4 approved (Mario's consolidated
  v3 revised per Nick's Facilities-Hub directive, received 08-26). **Phase 0 (corrections &
  de-risking) executed** on `feat/portal-foundations` @ 1.0.228 base: stale "parked in wip"
  header fixed on the applied facility-groups migration; routing path verified (`emed.select_pharmacy`
  IS `pharmacy_routing.select_pharmacy` — re-exported at `emed.js:15`, so the external flow already
  uses the DB-driven module; no code change needed); **signature dual-spelling normalized** behind
  shared accessors `emed.get_user_signature` / `emed.get_visit_signature` + `SIG_INFO_USER`/`SIG_INFO_VISIT`
  constants (read sites consolidated in `emed.js`, `external_order_worker.js` — which previously
  checked only one spelling — `route_prescriber.js`, `route_moct.js`); CLAUDE.md #44 (facility
  groups) + #16 signature-accessor note added. Full suite green (3878 passed; only the
  pre-existing environmental `webhook_crypto` failures). Awaiting Mario's Phase-0 review before
  Phase 1.

## Summary

One coherent, staff-controllable portal program: the **Facilities registry is the source of truth**
for who belongs to a facility, what capability tier they hold, and which portal features that
facility has. Prescriber Portal (three `portal_type`s: human/clinic · vet · pharmacy-transfer),
Clinic Portal (MOC-serviced: manual entry + JSON-payload intake, Form-Builder questionnaires
emailed to patients), universal rep-gated onboarding, Rep Tools completion, vet pricing line
(+ Zoolzy price-list share toggle), collections/cart/MOC-cutover later. Never rebuilds what
shipped: facility groups, per-user scope, the preclar gate, the per-facility config pattern, the
working prescriber portal.

## Phases (dependency-ordered; each ships dark/default-deny)

| Phase | Content | State |
|---|---|---|
| 0 | Corrections & de-risking (migration header, routing verify, signature accessor, docs) | **done, in review** |
| 1 | **built, in review** — Foundations A1–A9: migrations (`emed_portal_membership`, `prescriber_portal_page_config`, `emed_portal_attestation`, facility columns) · `portal_role` tiers · per-facility config clone · attestation persistence · patient resolver seam · status mapper · messaging primitive (D21) · masking + `external_patient_ref` · EMR-ready conventions | in review |
| 2 | ★ Facilities-hub user/prescriber management + in-portal delegation (Nick's core ask) | built, in review |
| 3 | Prescriber Portal to parity (order flow through preclar gate, clone/refill, patient mgmt, dedicated views, eScript equal-service) | |
| 4 | Vet + Pharmacy-Transfer types + vet pricing line (catalog discriminator, Product-Map matching, Zoolzy toggle) | |
| 5 | Clinic Portal (MOC pipeline; reuse Patient Portal magic-link for questionnaires) | |
| 6 | Universal Onboarding (rep-gated; payment-before-activation; send-to-us patients; drug selection → questionnaire + alias map) | |
| 7 | Rep Tools (consolidation, `Resubmit_Rx` for SalesRep, resubmit defect trio, preclar follow-up consumers, lead-side territory, order sets, intelligence) | |
| 8 | Collections · Cart · MOC integration + MyScriptOrders cutover · EMR activation | |

Authoritative plan text: Mario's approved v4 (plan mode,
`~/.claude/plans/check-all-the-pre-clarification-logical-fox.md`) — Nick's revision
(“Facilities-Hub model”, 08-26 email) is its spine. Open decisions tracked there
(D-A2 membership table · D14 patient contract · D17 portal_type ownership · D18–D20
clinic-portal fill-ins · D21 messaging · D22 EPCS/regulatory).

## Known defects/debt carried (not this program's causing, tracked here)
Resubmit reject-clone landmine · `release_hold` lacks pharmacy-eligibility re-check on resubmit
clones · override-on-unconfirmed unreachable from ResubmitModal · preclar aging-escalation +
threshold-breach consumers unbuilt · `/api/clarifications/:pharmacy/patient/:id` GET/PUT
ownership gap · `python/Patients.csv` PHI in repo.
