---
title: Sync Pharmacy Facilities
slug: pharmacy-facility-sync
status: Completed in Production
project: emed_app
branches:
  - emed_app: feat/pharmacy-facility-sync
developers:
  - nicholas-cardell
prs: []
tags: ["1.0.224"]
created: 2026-08-22
updated: 2026-08-22
related: [[facility-scope-groups]]
---

# Sync Pharmacy Facilities

## Status & history
- 2026-08-22 — Not Started → In-Progress → Completed in Dev → **Completed in Production (1.0.224)** (nicholas-cardell)

## Summary
A **"Sync Pharmacy Facilities"** action on the Facilities admin page (`/admin/facilities`) that keeps the
`emed_facility` registry — eMed's source-of-truth catalog of every clinic label a script can carry — in
step with the clinic names actually appearing in the three pharmacies' order data. On demand it finds
clinic-of-record names not yet registered and lets an admin **create** a new facility, **attach** the name
as a variant of a suggested existing facility, or **ignore** it. Replaces the one-off seed migrations
(`2026-06-08`, `2026-07-04`) with a routine, repeatable reconciliation. **Code-only — no schema/migration.**

## Design / approach
- **Source:** clinic-of-record is `{rxcs,mmed,mdvo}_rxqFullOrder.Dr_ClinicName` (VARCHAR(50), indexed).
  Scanned per pharmacy with an indexed `GROUP BY` + `MAX(LastModified)` for last-seen (mirrors
  `server/missing_scripts.js`'s NOLOCK read); pharmacy attribution is free, an empty/missing `mdvo` can't
  fail the scan.
- **Matching (JS, not a SQL JOIN — deliberately avoids the VARCHAR↔NVARCHAR collation conflict, error 468):**
  load all active `emed_facility_name` variants once; exclude exact (trimmed, case-insensitive) matches;
  for the rest, suggest a facility when `normalize_clinic_name()` matches an existing variant, OR when an
  existing facility's normalized name is a **leading prefix** of the clinic (the annotation-suffix case:
  `X, LLC "PATIENT PAY"` → attach to `X, LLC`). Dedupe across pharmacies into one row per clinic string.
- **Backend** (`server/facilities.js`): `normalize_clinic_name` (pure — lowercase, strip punctuation, peel
  trailing legal/credential suffixes only), `get_unregistered_pharmacy_clinics`, `add_pharmacy_clinics`
  (bulk create/attach, per-item safe). `server/routes/route_facilities.js`: `GET /api/facilities/pharmacy-sync`
  + `POST /api/facilities/pharmacy-sync/add` (both `Write_Facilities`, registered before `/:id`, add audited).
- **The joined-clinic guard is bypassed ONLY on the pharmacy-sync paths** via an internal
  `_skip_join_guard` / `opts.skip_join_guard` threaded through `save_facility` + `add_variant`. A pharmacy
  `Dr_ClinicName` is a trusted single-clinic label, so a name that merely *contains* other facility names
  (e.g. contains both the real clinic and a `PATIENT PAY` entry) is still registrable — the billing/invoice
  create paths keep the guard against multi-clinic invoice-header joins.
- **Frontend** (`views/admin/facilities.ejs`): toolbar button + `#pharmacySyncModal` (wide modal, sortable
  table, pharmacy/status filters with counts, chronological last-seen, per-row Create/Attach/Ignore select;
  rows default unticked so the source-of-truth registry is never mass-added by one click).
- **`page_catalog.js`:** the one write route mapped to the Facilities `Write_Facilities` cap (neutral).

## Decisions
- Dismiss/ignore is **session-only** (no ignore table) — a rescan starts fresh.
- New facilities are created **active**. Scan is **all-time** distinct (count + last-seen shown).
- `PATIENT PAY` / `PREPAY` / `NO LONGER`-style labels are **legitimate registry entries** (searchability),
  not junk — the tool registers them, it does not filter them out.

## Rollout / remaining
- Shipped to prod as **1.0.224** (2026-08-22), code-only, no migration. Verified on the dev slot by
  Nicholas (create + attach + ignore, annotation-suffix attach, no post-add error). 87 unit tests in
  `tests/unit/server/facilities.test.js`; page-registry check green.
- Nothing outstanding. Future nice-to-have (not built): optional keyword suppression of obvious operational
  placeholders — deliberately skipped since those labels belong in the registry.
