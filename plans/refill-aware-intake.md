---
title: Refill-aware intake forms + any-origin refill candidates (Peaks / PeakNow)
slug: refill-aware-intake
status: In-Progress
project: emed_app
branches:
  - emed_app: feat/refill-aware-intake
developers:
  - nicholas-cardell
prs: ["emed_app#640 (feat->main)"]
tags: []
created: 2026-09-03
updated: 2026-09-03
related: [peaknow-portal-golive]
---

# Refill-aware intake forms + any-origin refill candidates

## Status & history
- 2026-09-03 — Not Started → In-Progress (nicholas-cardell): code + tests on `feat/refill-aware-intake`, both flags default OFF.

## Summary
A Peaks staff member noticed PeakNow orders were being held in **Missing Forms** for patients who already
hold a valid prescription with fills remaining. Two gaps: (1) the intake-form gate never looked at whether
the order's drugs were detected as refills, and (2) refill detection only saw scripts eMed itself wrote
(`RxTag`), so the Blaze-era and hardcopy prescriptions that make up ~25% of Peaks' refillable scripts
were invisible. Decisions (Nick, 2026-09-03): a refill needs no new intake form and no re-attestation; the
quick-add quantity must match the dispensed quantity exactly; every script for the Peaks/PeakNow clinic
family counts regardless of origin (Blaze, eMed, eScript, phone order, hardcopy).

## Design / approach
All in `emed_app/server/product_required_form.js`, behind two env flags (both default off):

- **`INTAKE_FORMS_SKIP_FOR_REFILLS`** — `resolve_required_forms_for_visit(facility_id, visit_id, line_items)`
  returns `{ required, waived }`. A line is *refill-covered* when every non-OTC quick-add drug it maps to
  has a `moct_drug_rx` row on the visit with `script_number + fill_number` (`refill_covered_lines`).
  Only uncovered lines contribute required forms; a bundle with one refill and one new drug still
  requires the form. Used by the order webhook (`wc_ingest`), `advance_ready_visit`, the Missing Forms
  refresh, the portal's due-forms list and the visit page panel (waived rows render "Not required
  (refill on file)"). **Demotion re-check:** when the live Liberty check demotes a refill, the gate is
  re-run over the now-plain drafts; forms due → `Missing Forms` + patient notice (`wc_ingest.notify_forms_due`,
  now exported) instead of the prescriber queue. Any coverage lookup error fails closed (forms required).
- **`REFILL_CANDIDATES_INCLUDE_LINKED`** — `_linked_refill_candidates` adds candidates from every script the
  pharmacy holds for the patient, matched by three explicit bridges: patient = `emed_portal_patient_link`
  (person ↔ pharmacy PatientId, written by the facility Sync Links tool on exact name+DOB), drug =
  `emed_drug_liberty_xref` via `drug_liberty_xref.lookup(name, {pharmacy, exact_only:true})` (possible
  mis-tags excluded), size = quick-add `quantity` == mirror `QuantityDispensed` (fail closed when either
  side has no number — a DrugId does not distinguish 1 mL from 0.5 mL). Clinic scope = the facility's
  `emed_facility_name` variants plus its `portal_family` group siblings (1161 Peaks Curative ↔ 1923 PeakNow).
  Same validity rules as the RxTag path; eMed-origin matches keep precedence. Downstream is unchanged:
  `advance_ready_visit` live-verifies by script number and the refill goes out through `POST /refill`.

Tests: `tests/unit/server/product_refill_intake.test.js` (18) + existing `product_required_form`,
`product_autorefill`, `wc_ingest` suites (one expectation gained `origin:'emed'`).

## Rollout / remaining
1. **Phase 0 (data, no deploy):** run *Sync Facility Prescriptions* (links) for Peaks Curative (1161) and
   PeakNow (1923) in `/admin/facilities`; add crosswalk rows for the two quick-adds with none
   (`PKS NAD+ NASAL SPRAY…`, `Semaglutide (no sodium) 5mg/mL 1 mL`) via `/admin/drug-map`.
2. **Phase 1:** deploy with both flags off (no behavior change), then set `INTAKE_FORMS_SKIP_FOR_REFILLS=1`
   on the dev slot → prod.
3. **Phase 2:** set `REFILL_CANDIDATES_INCLUDE_LINKED=1`; re-evaluate the PeakNow visits sitting in
   Missing Forms (any patient submission triggers `refresh_missing_forms_for_person`; a one-off script
   can call it per held visit).
4. Landmines: never fall back to name `LIKE` for clinic or patient matching; keep the quantity check
   strict; the refill of a non-eMed script reuses the original prescriber's authority (pharmacy validates
   `RefillsAuthorized`).
