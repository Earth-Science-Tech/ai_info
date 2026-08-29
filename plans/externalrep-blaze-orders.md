---
title: ExternalRep — Blaze Orders access (read-only, clinic-scoped)
slug: externalrep-blaze-orders
status: Completed in Production
project: emed_app
branches:
  - emed_app: feat/externalrep-blaze-orders
developers:
  - nicholas-cardell
prs:
  - "emed_app#509 (feat->main)"
tags: ["1.0.239"]
created: 2026-08-29
updated: 2026-08-29
related: ["[[clarifications-clinic-scope]]", "[[per-page-permissions]]"]
---

# ExternalRep — Blaze Orders access (read-only, clinic-scoped)

## Status & history
- 2026-08-29 — Not Started → Completed in Production (nicholas-cardell), shipped 1.0.239.

## Summary
ExternalRep (outside sales reps) needed the **Blaze Orders** page for their own clinics.
eMed Orders already worked for them (`Resubmit_Rx`, already clinic-scoped). Blaze Orders was
gated on `View_Menu_MOCT`, which the role lacks — and granting that broad flag would also
expose MOCT Visits, Drug Map, and ScriptSure write APIs. So the grant rides the page's **own**
per-page read privilege instead.

## Design / approach
- `server/page_catalog.js` — `BlazeBatches.readGate` changed from `has('View_Menu_MOCT')` to
  `(p, role) => !!p.View_Menu_MOCT || role === 'ExternalRep'`, so the built-in role **derives**
  `View_Page_BlazeBatches` (a built-in role's page flags come from readGate; a factory-set page
  flag is ignored — `permission_catalog.union_permissions`). Registry stays neutral (only
  ExternalRep added). Write gate stays `Write_Link_Scripts` (unheld) → read-only.
- `app.js` `/blaze/orders` render route + `route_blaze_batches.js` `GET /orders` now gate on
  `View_Page_BlazeBatches` (instead of `View_Menu_MOCT`). `GET /orders` already clinic-scopes
  (`is_clinic_scoped` → SQL narrowing + `filter_by_clinic` + PHI audit).
- **Tab 2** ("Unlinked Blaze Tags") is an internal disambiguation queue whose batches endpoint
  (`GET /api/blaze-batches`) is NOT clinic-scoped — it stays `View_Menu_MOCT`-only and is hidden
  in `views/blaze/orders.ejs` for non-MOCT viewers (nav button, pane, AND its `<script>` block,
  whose load-time `addEventListener`s would otherwise throw and break Tab 1).
- No `permissions.js` change; ExternalRep already holds the clarifications/script flags the
  Script Modal needs.

## Rollout / remaining
- Code-only, no migration. Shipped 1.0.239 (PR #509). Existing ExternalRep sessions pick up the
  page on **next login** (perm is a login-time snapshot; value change, no `PERM_SCHEMA_VERSION` bump).
- Tests: `tests/unit/server/page_blaze_externalrep.test.js` (4). `check_page_registry.js` neutral.
- **Remaining smoke test:** log in as an ExternalRep test account on the dev slot → Blaze Orders
  appears, Tab 1 shows only their clinics, Tab 2 is absent. (Localhost forces Admin, so this can
  only be exercised on the dev slot.)
