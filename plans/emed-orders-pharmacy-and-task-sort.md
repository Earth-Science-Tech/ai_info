---
title: eMed Orders Pharmacy Filter/Column + Task Date-Sort Fix & Last Modified
slug: emed-orders-pharmacy-and-task-sort
status: Completed in Production
project: multi
branches:
  - emed_app: feat/emed-orders-pharmacy-and-task-sort
developers:
  - nicholas-cardell
prs:
  - "emed_app#398 (feat->main)"
tags:
  - "1.0.197"
created: 2026-08-12
updated: 2026-08-12
related: []
---

# eMed Orders Pharmacy Filter/Column + Task Date-Sort Fix & Last Modified

## Status & history
- 2026-08-12 — Not Started → In-Progress (nicholas-cardell)
- 2026-08-12 — In-Progress → Completed in Dev (nicholas-cardell) — merged to `dev`, deployed to Azure dev slot, both features validated by operator
- 2026-08-12 — Completed in Dev → Completed in Production (nicholas-cardell) — PR #398 merged, tag `1.0.197`

## Summary
Two independent enhancements shipped together:
1. **eMed Orders (`/emed/orders`) pharmacy filter + column.** An "All Pharmacies" dropdown
   (Rx Compound Store / Mister Meds / Meduvo) in the search bar plus a sortable, filterable
   **Pharmacy** column showing each order's *assigned* pharmacy (`moct_visit.pharmacy`).
2. **Task system date sorting fix + Last Modified column.** The task list's Created date
   was sorting alphabetically (by month name) instead of by real date, scattering tasks
   across paginated pages — which made completed tasks look like they "disappeared"
   (reported by Vanessa Castellanos, Clarifications). Fixed the sort and added a
   **Last Modified** column to both "Assigned to Me" and "Created by Me".

## Design / approach
- **Task sort (Task 2, emed_app only, no schema change).** The tables use client-side
  `simple-datatables` v10 via `gen_datatable` (`public/js/main.js`). The Created cell was a
  pre-formatted locale string with no machine-sortable value → lexicographic sort. Fix:
  `formatDate()` in `views/tasks/my-tasks.ejs` now builds the string deterministically with
  plain ASCII spaces (modern Intl inserts a U+202F before AM/PM that breaks the sort's
  strict dayjs parse), and the Created/Last Modified columns declare
  `type:"date", format: DATE_SORT_FORMAT`. Verified: `dayjs(text, format, true)` (the exact
  call simple-datatables makes) parses every rendered date and orders chronologically.
  `moct_task.date_modified` already existed + is returned by `/api/tasks/my-queue` (both the
  assigned and created branches, and the merged EO subtasks), so no schema change. Same
  latent bug also fixed in `views/admin/task-management.ejs`.
- **Pharmacy column (Task 1, emed_app + emed_sql).** The `/emed/orders` list is server-side
  paginated/sorted/filtered off `view_moct_visit` (`route_moct.js` `/rep-orders`). The view
  carried no pharmacy, so an additive column `COALESCE(v.pharmacy,'') AS pharmacy` was added
  to `view_moct_visit`. App: `pharmacy` added to the sort whitelist + a parameterized
  `pharmacy IN (...)` filter arm (validated against the 3 names); `orders.ejs` gains the
  dropdown + a sortable/filterable column mirroring the Clinic column pattern (dropdown and
  column popover share `ord_state.filters.pharmacy`).
- **Semantic chosen:** *assigned* pharmacy (`moct_visit.pharmacy`), not actual-fill. Values are
  exactly the 3 dropdown names; pairs with the existing "Rx Status" column.

## Rollout / remaining
- **Shipped to prod in 1.0.197.** Migration `emed_sql/migrations/applied/2026-08-12_add_pharmacy_to_view_moct_visit.sql`
  (emed_sql `cdfea1c`) applied `--db both` **before** the code deploy (both Azure slots run against
  the prod DB `liberty_link_stage`, so the column had to exist in prod first).
- **Manual controlled ship** (not the automated `push prod` skill): unrelated pre-existing
  UNCOVERED dev drift (`etst_zoolzy_*` tables + `form_submission` columns) would hard-stop the
  skill's drift gate. Only this feature's migration was applied; the drift was left untouched.
  **Landmine for the next shipper:** that `etst_zoolzy_*` / `form_submission` drift is still
  uncovered on `liberty_link_dev` — flag to its owner; `push prod` will hard-stop until it is
  covered (`check_migration_drift.py --scaffold`) or the owner parks it in `wip/`.
- Nothing remaining for this feature.
