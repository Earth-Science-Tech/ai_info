---
title: Facility merge carries every facility_id reference (portal key, mappings, settings, scopes)
slug: facility-merge-complete
status: Completed in Production
project: emed_app
branches:
  - emed_app: feat/facility-merge-complete
developers:
  - nicholas-cardell
prs: ["emed_app#646 (feat->main, merged 2026-09-04)"]
tags: ["1.0.303"]
created: 2026-09-04
updated: 2026-09-04
related: [peaknow-portal-golive, legacy-intake-forms]
---

# Facility merge carries every facility_id reference

## Status & history
- 2026-09-04 — Not Started → In-Progress (nicholas-cardell): Nick decided Peaks Curative (1161, legal name "PEAKS Curative, LLC") is the surviving facility and PeakNow (1923) folds into it; the merge tool had to carry everything first.
- 2026-09-04 — In-Progress → Completed in Production (nicholas-cardell): PR #646 merged, tag 1.0.303. **The Peaks merge itself (1923 → 1161) is a separate operator step** — run after the adversarial review with `DB_NAME=liberty_link_stage node scripts/merge_facility.js 1923 1161 --apply` (preview first).

## Summary
`facilities.merge_facility` moved names, addresses, payment records, billing strings, leads, pricing
and group memberships, then retired the source — leaving the source's portal embed key, Clinic
Products mappings, portal page settings, allowed iframe origins, quick-add assignments, memberships,
order sets, signups, threads, drafts, holds and `emed_user.scope_facility_id` pointing at a RETIRED
facility. For a live portal clinic that silently cuts the site's eMed connection and empties the API
users' scope.

## Design / approach
- `FACILITY_ID_REPOINT` (exported): declarative list of every remaining facility_id table with the SQL
  `match` of its filtered-unique key (target wins on collision → source row retired, rest re-pointed).
  Generated statements touch only `facility_id` / `is_invalid`. Keep in step with
  `INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='facility_id'`.
- Step 4e moves directly-scoped users; 4f merges portal switches (OR) and fills the target's EMPTY
  contact/portal fields (COALESCE — never overwrites); after the retire every user scoped to the target
  is recomputed and the portal-config cache is cleared. Abort-before-retire contract unchanged.
- `merge_preview(source, target)` (read-only) + `GET /api/facilities/:id/merge-preview/:target`; the
  admin merge confirm lists what moves; `scripts/merge_facility.js` runs preview/apply from the CLI.

## Rollout / remaining
1. Prod preview (2026-09-04, 1923 → 1161): portal key 1 + product mappings 76 move; 4 patient + 14
   prescriber page configs and 3 origins are exact duplicates (retired); 1 portal_family membership
   deduped; 0 billing rows; 0 users scoped to 1923 (the 3 API users are on 1161).
2. Apply after review; verify: `emed_facility_portal_key.facility_id = 1161`, `/admin/clinic-products`
   lists the 76 mappings under PEAKS Curative, LLC, peaknow.com embed still authenticates, API users'
   `clinics` regenerated (5 variants), facility 1923 `is_invalid = 1`.
3. Landmines: the merge is one-directional; the retired source keeps its rows (nothing deleted) so a
   mistaken merge is reconstructable but not one-click reversible.
