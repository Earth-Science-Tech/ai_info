---
title: Legacy intake forms for held Peaks visits (drug fallback, staff assignment, no-mapping guard)
slug: legacy-intake-forms
status: Completed in Production
project: multi
branches:
  - emed_app: feat/legacy-intake-forms
  - emed_sql: main (migrations/pending/2026-09-04_add_emed_visit_required_form.sql)
developers:
  - nicholas-cardell
prs: ["emed_app#648 (feat->main, merged 2026-09-04)"]
tags: ["1.0.304", "1.0.305", "1.0.307"]
created: 2026-09-04
updated: 2026-09-04
related: [refill-aware-intake, facility-merge-complete, peaknow-portal-golive]
---

# Legacy intake forms for held Peaks visits

## Status & history
- 2026-09-04 — Not Started → In-Progress (nicholas-cardell): code + 22 tests on `feat/legacy-intake-forms`, PR #648 open; migration dev-applied and promoted to `pending/`; adversarial review in progress.
- 2026-09-04 — In-Progress → Completed in Production (nicholas-cardell): adversarial review → 11 fixes (header alignment of the Select column, fail-closed advance on a configured facility with no covering rule, staff action releases to review without auto-advance, exact bundle/OTC drug matching, 24h notice throttle, recency clamp, IF EXISTS revive; merge tool: target-group recompute, provisioned_facility_id, all portal switches); PR #648 merged, migration applied dev+prod, tag **1.0.304**.
- 2026-09-04 — follow-ups shipped: **1.0.305** Assign-form picker limited to form-builder category 'Intake Form' (PR #652); **1.0.307** **Re-process order** staff action (PR #657) — `wc_ingest.reprocess_visit` re-runs the webhook's auto-prescribe → forms gate → advance ON THE SERVER for Received / Missing Forms visits (bulk button on Peaks Visits, per-visit button on the visit page). Built because nothing revisited a visit ingested before its product mappings existed (5 PeakNow orders from the 01:50–03:26 UTC merge window). Never re-run the gate from a laptop (Azure switches + live Liberty).

## Summary
~225 legacy Peaks Curative visits (Dec-2025 .. Sep-2026, all patients with phone + DOB) sit in
**Missing Forms** because their questionnaires lived in WPForms on the old site and some patients never
filled them. The intake gate only knew the Clinic Products mapping. Nick asked for staff to be able to
assign the new eMed intake forms to old orders, or to have held visits use them automatically.

## Design / approach
`product_required_form._order_required` resolves a visit's required forms from three sources:
1. **products** — order line → mapping (unchanged, + refill waiver). The site migration kept WooCommerce
   product ids: 185/185 legacy order lines match by `wc_product_id`; names carry `<br>` HTML, stripped
   by `_clean_name` before name matching.
2. **drugs** — only when NO order line matched: `moct_drug_request` / `moct_drug_rx` names → exact
   quick-add name → the mappings carrying that quick-add (224/225 held visits carry drafts).
3. **manual** — rows staff assigned to THIS visit in `emed_visit_required_form` (ships dark behind a
   table probe).
`matched` = at least one rule COVERED the order (a "No Form" mapping row counts). **No rule = gap, not
"no forms needed"**: `refresh_missing_forms_for_person` never releases on `!matched` (before this, a
legacy visit whose facility had 0 mappings would have been released and auto-advanced by the patient's
first portal submission). `intake_status_for_order` → `{ rows, matched, sources }`.

Staff actions: `request_intake_forms` (Peaks Visits Select column + "Request intake forms (n)";
per visit `requested` / `complete` / `no_mapping` / `out_of_scope` / `skipped_status`; clinic-scoped
like GET /visits) and `assign_visit_form` / `unassign_visit_form` on the visit page's Intake Forms
card (renders even with nothing mapped). `wc_ingest.notify_forms_due(..., {clinic, app_user})`;
`secure_messaging._from_phone` uses `peaks_sites.is_peaks_family` (PeakNow was texted from the RXCS
number).

## Rollout / remaining
1. Review findings → fixes → merge PR #648 → push prod (applies the pending migration first).
2. Run the Peaks facility merge (see `facility-merge-complete`) so legacy visits resolve to the merged
   facility's 76 mappings (source 1 covers 144 of the 225; drugs cover the rest).
3. Staff: on Peaks Visits filter Missing Forms → tick the orders still wanted → Request intake forms.
   **The 'complete' path advances the order like a fresh submission** (refill detection / prescriber
   queue) — only tick orders the customer still wants.
4. Landmines: exact quick-add name matching only (never fuzzy); the guard can only make the gate hold
   MORE; `_manual_table_ready` is cached per process — the migration must land before the deploy (push
   prod applies pending/ first) or manual assignment answers 503 until restart.
