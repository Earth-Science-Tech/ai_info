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
| 1 | Foundations A1–A9: migrations (`emed_portal_membership`, `prescriber_portal_page_config`, `emed_portal_attestation`, facility columns) · `portal_role` tiers · per-facility config clone · attestation persistence · patient resolver seam · status mapper · messaging primitive (D21) · masking + `external_patient_ref` · EMR-ready conventions | next |
| 2 | ★ Facilities-hub user/prescriber management + in-portal delegation (Nick's core ask) | |
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
