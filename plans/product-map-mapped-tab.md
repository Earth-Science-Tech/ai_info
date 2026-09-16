---
title: Product Map "Mapped" view + Liberty-master drug names + seed mis-map fix
slug: product-map-mapped-tab
status: Completed in Dev
project: multi
branches:
  - emed_app: feat/product-map-mapped-tab
  - emed_sql: feat/fix-seed-drug-map-mismaps
developers:
  - nicholas-cardell
prs:
  - "emed_app#842 (feat->main)"
  - "emed_sql#94 (feat->main, data migration)"
tags: []
created: 2026-09-16
updated: 2026-09-16
related: ["[[peaknow-portal-integration]]"]
---

# Product Map "Mapped" view + Liberty-master drug names + seed mis-map fix

## Status & history
- 2026-09-16 — Not Started → In-Progress (nicholas-cardell): Mario asked why "TIRZEPATIDE 10MG/ML SOLUTION" was not on Product Map.
- 2026-09-16 — In-Progress → Completed in Dev (nicholas-cardell): migration applied to `liberty_link_dev`; verified live in the browser against dev; PRs open.

## Summary
Mario's "missing" drug was mapped — to the WRONG catalog product — by the 2026-07-18 hand-review seed,
13 hours before the Product Map queue received its first row. Product Map only ever listed drugs that had
passed through the queue (`emed_price_drug_unmatched`), so the 182 seeded links were visible nowhere and
editable nowhere. The seed's own error came from naming each DrugId with `MAX(drug_name)` over invoice
lines: a string MAX returns the alphabetically-last of every name a DrugId ever carried, so 3 stray
"20MG/ML" lines outvoted 14,509 "10MG/ML" lines. The same `MAX()` lived in the daily scan.

Two pages, two tables, one spine: EMED → Drug Name Map reads `emed_drug_liberty_xref` (eMed/PDF name →
Liberty DrugId, derived from tagged Rx history); Pricing → Product Map reads the unmatched queue fed by
the 60-day invoice-line scan; both join `emed_price_drug_map` (pharmacy display name, DrugId) →
`emed_price_catalog`. Auto Pricing is shadow/audit-only, so no invoice total was ever affected.

## Design / approach
- **Mapped pill** on `/billing/unmatched-drugs` lists the map table itself (every live link, any origin):
  current Liberty name, source badge (seeded / queue / re-mapped / corrected, read off `app_name`),
  "mapped as" drift line, **Re-map** (`POST /api/billing/v2/drug-maps/:id/remap`) and **Unlink**
  (`POST /drug-maps/:id/unlink` → soft-delete `is_invalid = 1`, never `match_status='inactive'`, because
  the (pharmacy, drug_id) unique index is filtered on live rows; reopens or CREATES the queue row with the
  drug's whole invoice history). `GET /drug-maps`, `GET /drug-maps/count`. WRITE_ROUTES under
  `UnmatchedDrugs`, guard `['Write_Liberty','Write_Pricing']`. Every change → `emed_price_audit`
  (`entity_type 'drug_map'`, REMAP / UNLINK).
- **Names**: `drug_catalog_map.liberty_master_sql()` — UNION ALL over `{rxcs,mmed,mdvo}_rxqDrug` keyed on
  the display name — is the name source for the scan (fallback = most frequent line name, ROW_NUMBER by
  COUNT DESC) and for `drug_liberty_xref._fetch_evidence`. `PHARMACIES` is one frozen list shared by both.
- **Per-pharmacy keying**: a DrugId is unique only within a Liberty instance (26 ids already differ between
  RXCS and Mister Meds; Meduvo's newest id is below RXCS's, so collisions grow). The one unscoped lookup —
  the prescriber-portal refill re-link in `route_prescriber.js` — is now scoped via
  `pharmacy_display_for_prefix(ph)`.
- **Data fix** `emed_sql/migrations/pending/2026-09-16_fix_seed_drug_map_mismaps.sql`: re-points 8 RXCS
  rows (AFAA→29, AWJQ→47, ADPW→3, ABEM→765, ACTD→600, AYPO→591, ACES→239, ATKF→296), retires 3 with no
  matching catalog product (BFRO, AXLD, ATJI) onto the Pending queue. Idempotent, business-keyed,
  `app_user='seed_drug_map'` only; Mario's / Jonathan's hand-made rows untouched.

## Rollout / remaining
- [x] Dev: migration applied (8 re-pointed / 3 retired / 3 queued), app verified live (Mapped 498;
      Unlink → Pending → Map back → Resolved; Re-map 3→10→3 with audit rows).
- [ ] Prod: merge emed_sql#94 + eMed#842, apply the migration with `push prod` (it is the only file in
      `pending/`), tag. Then Product Map → Mapped, search "TIRZ": RXCS AFAA = Tirzepatide 10 mg/mL.
- [ ] Mario: place BFRO (Metformin 500 ER), AXLD (Pyridoxine 85 mg/mL), ATJI (Glow Blend, now BPC/TB4 3 mg)
      from the Pending queue — or add catalog rows for them.
- Landmines: never `MAX(drug_name)`; never look a DrugId up without its pharmacy; the browser preview tool
  spawns `node app.js` from the ORIGINAL checkout (verify a worktree on another port).
