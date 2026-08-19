---
title: Facility Scope Unification (FacilityGroups)
slug: facility-scope-groups
status: Completed in Production
project: multi
branches:
  - emed_app: feat/patient-portal-secure-messaging (shipped 1.0.205); feat/facility-scope-fixes (1.0.206); feat/recompute-trigger-sync (1.0.207)
  - emed_sql: migrations/applied/2026-08-15_add_facility_groups_and_user_scope.sql (prod+dev)
developers:
  - nicholas-cardell
prs: []
tags: ["1.0.205", "1.0.206", "1.0.207"]
created: 2026-08-15
updated: 2026-08-17
related: [[patient-portal-secure-messaging]]
---

# Facility Scope Unification (FacilityGroups)

## Summary

Clinic access for the four clinic-scoped roles (**API, ClinicUser, ExternalPrescriber, ExternalRep**)
is stored as free-text clinic **name strings** — `emed_user.name` for API accounts and the
pipe-delimited `emed_user.clinics` for the rest. This is unmaintainable (one ExternalRep,
`giano.saumat`, has an **891-entry** `clinics` field) and it never consulted the Facilities registry,
so a clinic's name variants were only covered if someone hand-typed every spelling. The API `clinics`
field had even been overloaded as a per-account name-variant list **and** as a partner grouping
(Valhalla's account = `Valhalla Vitality | Valhalla Vitality Texas | Ironsail Pharma`, three distinct
facilities).

The fix makes the **Facilities registry the single source of truth** and expresses a user's scope as a
set of facilities, via **one typed grouping mechanism**:

- `emed_user.scope_facility_id` — a single facility (the common single-clinic case), **XOR**
- `emed_user.scope_group_id` — one `emed_facility_group`, a **named, typed** collection of DISTINCT
  facilities. `group_type` is descriptive, not behavioural: `'sales'` (a rep's territory, e.g. "JPV")
  or `'affiliated'` (partner/sister companies, e.g. "Valhalla" = Valhalla Vitality + Texas + Ironsail).
  A facility may belong to several groups (overlap is expected).

**Derived-cache design (keeps the blast radius from exploding):** `emed_user.clinics` (and the webhook
`emed_user_clinic` rows) become an **auto-regenerated projection** of the effective facility set →
every active `name_variant` of every scoped facility. So the ~31 read consumers (`filter_by_clinic`,
the `LIKE '%c%'` SQL sites), the webhook matcher, and ETL (which only sends `emed_user.name` as the
`customer` header) all keep working **unchanged** — they just start reading a complete, correct list.
The only things that change are where scope is **edited** and a `recompute_user_scope()` step.

## Design / approach

- **Atoms:** a facility owns its name variants (`emed_facility_name`, globally-unique variant string).
- **Grouping:** `emed_facility_group` + `emed_facility_group_member` (typed, reusable, DISTINCT
  facilities). One mechanism for both a rep's 100-clinic territory and a 2-3 company affiliated set —
  the `type` just labels why. No group-of-groups; a facility in two groups is fine.
- **Scope:** `emed_user.scope_facility_id` XOR `emed_user.scope_group_id`. Both NULL during transition =
  fall back to legacy `clinics`/`name` (behaviour-neutral).
- **Effective set → derived clinics:** `scope_facility_id → {that facility}`; `scope_group_id → {all
  active members}`; expand to the union of all name variants; recompute `emed_user.clinics` +
  `emed_user_clinic` on any scope/membership/variant change.
- **One behavioural change (later phase):** API scope moves off `clinic_source:'name'` onto the derived
  `clinics` set (Valhalla's account name resolves to no operational row; only the derived variant set
  scopes it). `emed_user.name` + the ETL `customer` header stay as an **identity** cross-check only —
  **ETL needs zero changes.** This also fixes a latent bug where API scope differed between the session
  path (`name` only) and the public-API path (`clinics` via `get_clinic_list`).
- **Deliberately NOT a CHECK constraint on `group_type`** (app-validated free vocab) — avoids the
  widen-constraint-before-deploy landmine.
- **Rejected:** re-keying operational tables (`moct_visit`/scripts/orders) to `facility_id` — huge,
  high-risk migration on the Rx path; the derived-cache gets ~95% of the benefit with near-zero risk.

## Investigation findings (live prod = dev, 2026-08-15)

- **Only 3 roles ever populate `clinics`:** API (28 users), ClinicUser (25), ExternalRep (7). Every
  other role: 0. No unaccounted user type; no multi-role user mixes a clinic-scoped role into a
  non-scoped primary. So scoping stays simple.
- **ExternalRep is the pain:** `giano.saumat` 906 pipe entries (891 distinct facilities), `julien.orbea`
  209, `clinicalhealthllc`/Jill 207, `christy.bermudez` 65, `gcconsulting` 55.
- **Coverage is high:** of 1,253 distinct clinic strings, only ~7 don't resolve to a facility variant.
- **The audit exposed facility-registry DUPLICATES** — the same clinic registered as two facilities
  (e.g. #170 "Balanced Aesthetics Medspa" vs #173 "balancedaestheticsmedspa"; "Drip Vitals" vs "Drip
  Vitals LLC"). These need **merging** (existing `facilities.merge_facility`), not grouping.
- **GUI editors that write user scope (all must convert in Phase 3):** `views/emed/users.ejs` (chip
  editor, all roles — only place ExternalRep is set) → `POST /api/users`; `views/moct/api-users.ejs`
  (pipe textbox, API+ClinicUser) → `POST /api/api-users`; `views/prescriber/manage-prescribers.ejs`
  (single datalist, ExternalPrescriber) → `POST /api/prescriber-users`; and the new **Users card** on
  `views/admin/facilities.ejs` → `POST /api/api-users`. Every other "clinics" mention (35+ files) only
  reads/filters and stays untouched.

## Rollout / remaining

- **Phase 1 — additive schema + backfill/audit (dev). DONE 2026-08-15.**
  - Migration `emed_sql/migrations/wip/2026-08-15_add_facility_groups_and_user_scope.sql`
    (`emed_facility_group`, `emed_facility_group_member`, `emed_user.scope_facility_id` +
    `scope_group_id`; GRANTs; unique/supporting indexes). Applied to `liberty_link_dev` only; file in
    `wip/`. Zero runtime behaviour change (nothing reads the new columns yet).
  - `emed_app/scripts/facility_scope_backfill.js` — dry-run/audit + `--apply` (+ `--reset` for dev).
    Classifies each user FACILITY / GROUP / **MERGE** (duplicate facilities of one clinic) / UNMAPPED,
    with a base-name heuristic to distinguish duplicate registrations from genuine affiliated groups.
    Refuses to write prod without `--allow-prod`. Applied on dev: single-facility scopes set, provisional
    groups created (sales for reps, affiliated for multi), MERGE + UNMAPPED left for registry cleanup.
- **Phase 1.5 — registry cleanup (dev). Safe part DONE 2026-08-15** via
  `emed_app/scripts/facility_scope_cleanup.js` (name-guarded, dry-run default, prod-refusing): merged the
  5 duplicate pairs (Balanced Aesthetics, Drip Vitals, Fifty 410, Modern RX, Trust Clinic Rx) + registered
  2 obvious variants (Hoedebecke Clinic → #641, RejuvaMeds → #1253); re-ran backfill → MERGE 5→0,
  FACILITY 40→45, unmapped strings 7→5. **Remaining (needs human judgment / Phase 3 UI):** the Apprize /
  TRIM FITT joined-clinic artifact (#124) + real "TRIM FITT LLC" (#1536); "Bloom Restorative Wellness" vs
  #1902 "In Bloom Restorative Wellness"; new "Ocean Bloom Wellness"; renaming the 12 provisional groups
  (→ "JPV", "Valhalla") and confirming/splitting the 4 small auto-`affiliated` groups.
- **Phase 2 — resolver + recompute + shadow:** `recompute_user_scope()` regenerates `emed_user.clinics`
  (+ `emed_user_clinic`) from the effective facility set; shadow-diff the derived vs current `clinics`
  per user until clean. Still no read-path change.
- **Phase 3 — flip the editing UI.** Built on `feat/patient-portal-secure-messaging` (consolidated there
  because that branch holds the facilities.ejs Users card + editor cards; `feat/facility-scope-groups`
  was merged in).
  - **Part 1 — Groups manager. DONE on dev 2026-08-15.** `facilities.js` group CRUD + `set_user_scope` +
    `recompute_user_scope` (regenerates `emed_user.clinics`, syncs `emed_user_clinic`) + `recompute_group`;
    `/api/facilities/groups*` routes (Write_Facilities; read also Write_API_Users). "Facility Groups"
    button on `/admin/facilities` → two-pane manager (list w/ type + member/user counts, create/rename/
    retype/describe, add/remove members via typeahead, delete-blocked-while-scoped, scoped-users list).
    Editing membership recomputes scoped users' clinics immediately (verified on the Valhalla account).
    **This is the surface for renaming the 11 remaining provisional groups + confirming the small ones.**
  - **Part 2 — scope picker (IN PROGRESS).** Reusable `public/js/scope-picker.js` (facility-typeahead
    XOR group-select). Backend `set_user_scope` derives `emed_user.clinics` from the chosen scope; legacy
    `clinics` still honored when scope fields are absent (additive/back-compat). `attach_scope_labels`
    enriches user GETs for prefill; `/api/facilities/list` opened to `Write_API_Users`.
    - **Slices 1–3a DONE on dev 2026-08-15 — covers 100% of actually-scoped users** (API 28, ClinicUser
      25, ExternalRep 7). Groups modal restyled. ScopePicker wired into: the **facilities Users card**
      (scopes to that facility), **`emed/users.ejs`** + `POST/GET /api/users` (the only ExternalRep editor
      → rep territories become Sales groups), and **`moct/api-users.ejs`** (reuses the wired
      `/api/api-users`). Backend `set_user_scope` derives `clinics`; legacy `clinics` kept as fallback so a
      no-scope edit never wipes access; `attach_scope_labels` prefills.
    - **Prescriber DONE on dev 2026-08-15:** `prescriber/manage-prescribers.ejs` single-clinic datalist →
      ScopePicker; `POST/GET /api/prescriber-users` accept/return scope. **All four editors now use the
      picker.**
    - **API `clinic_source` flip — NOT DONE, deliberately.** Analysis showed it would BREAK API scoping:
      API is Basic-Auth with no browser session, so `get_user_clinics`'s `'name'` branch (reads the
      `customer` header) is correct; flipping to `'clinics'` would read `session.user.clinics`, which is
      empty for Basic-Auth. The derived `clinics` is already used for the real API vendor path via
      `get_clinic_list(name)`. So `clinic_source` stays `'name'`.
- **Phase 2 — global recompute. DONE on dev 2026-08-15.** `scripts/facility_scope_recompute.js`
  (shadow-diff then `--apply`). Diff caught ONE issue — Giano's sales group still referenced facility
  #417 "Drip Vitals LLC" after it was merged into #416 in Phase 1.5, because `merge_facility` didn't
  re-point group memberships. **Fixed:** hardened `merge_facility` to re-point `emed_facility_group_member`
  (source→target, dedup) + recompute affected groups, and repaired the dangling row on dev. Re-ran:
  **60/60 scoped users recomputed, 0 empty clinics, 0 access-loss.** ClinicUser/ExternalRep/ExternalPrescriber
  pick up derived clinics at next login (session snapshot); the API vendor path already reads them live.
- **Phase 4 (optional) — tighten matching:** substring `.includes()` / `LIKE '%c%'` → exact-variant-set
  once coverage is proven (closes the "Valhalla" ⊂ "Valhalla Vitality Texas" hazard). Behind a flag.

## Status & history
- 2026-08-15 — Not Started → In-Progress (nicholas-cardell). Phase 1 built + applied to dev.
- 2026-08-15 — Phase 1.5 safe cleanup applied to dev (5 merges + 2 variants); MERGE 5→0, FACILITY 40→45.
- 2026-08-15 — Phase 1.5 round 2 applied to dev (Apprize/TRIM FITT variants + "Apprize TRIM FITT" group
  + 2 new facilities). **All 60 clinic-scoped users now scoped (47 facility, 13 group); 0 unmapped, no
  gap.** Remaining curation = renaming the other 11 provisional groups + confirming the 4 small
  auto-`affiliated` groups → Phase 3 UI.
- 2026-08-15 — Phase 3 Part 1 (Groups manager) + Part 2 (polished modal + ScopePicker in all 4 editors +
  scope wiring on all 3 user endpoints) done on dev.
- 2026-08-15 — Phase 2 global recompute done on dev (60/60, 0 access-loss); `merge_facility` hardened to
  re-point group memberships. **Facility registry is now the source of truth for clinic scope on dev.**
  NEXT: curation (rename provisional groups) via the Groups manager, then a `feat/* → main` promotion PR
  (move migration `wip/ → pending/`) to ship — likely coordinated with the patient-portal branch since
  they share `facilities.ejs`.
- 2026-08-17 — **SHIPPED TO PRODUCTION (1.0.205).** In-Progress → Completed in Production (nicholas-cardell).
  Shipped together with Patient Portal Phase 1 (dark) off `feat/patient-portal-secure-messaging` (they
  share `facilities.ejs`). Migration `2026-08-15_add_facility_groups_and_user_scope.sql` moved `wip/ →
  pending/` and applied to prod+dev (`--db both`); now in `migrations/applied/`.
  - **Prod data migration run (backfill → cleanup → settle → recompute, `--allow-prod`):** all **60
    clinic-scoped accounts** now derive from the registry (47 facility, 13 group; 1,450 group memberships).
    Cleanup applied on prod: 5 facility merges, 5 variant registrations, 2 new facilities (Bloom
    Restorative Wellness #1904, Ocean Bloom Wellness #1905), group #4 renamed "Apprize TRIM FITT". Prod
    recompute shadow-diff = **51 unchanged, 9 gained variants, 0 removed (0 access-loss)** — matched dev.
- 2026-08-17 — **1.0.206:** fixed the ScopePicker group prefill/reset bug (the singleton picker only
  applied the selected group on first load, so a 2nd ExternalRep never prefilled and showed the prior
  user's group). `ensureGroups()` now re-syncs the dropdown every `setMode('group')`; `set()` clears the
  opposite mode. Also deduped derived clinics.
- 2026-08-17 — **1.0.207:** removed `recompute_user_scope`'s MANUAL `emed_user_clinic` maintenance. ⚠
  **GOTCHA:** the DB trigger `trg_emed_user_clinic_sync` (on `emed_user`, AFTER INSERT/UPDATE) already
  keeps `emed_user_clinic` in sync from `emed_user.clinics` (DISTINCT + NOT-EXISTS guarded). The manual
  soft-delete-then-reinsert double-wrote, accumulating duplicate soft-deleted rows that later collided
  (err 2601) with the trigger's reactivation step. Only ONE account had accumulated debris
  (`giano.saumat`: 915 active + 2,737 soft-deleted); repaired via an admin hard-DELETE of his
  `emed_user_clinic` rows + a no-op `clinics` UPDATE to let the trigger rebuild a clean 911-row mirror.
  **Lesson: anything that writes `emed_user.clinics` must NOT also touch `emed_user_clinic` — the trigger
  is the single writer.**
- 2026-08-18 — **`emed_user_clinic` debris purge (data-only, no code).** Editing any migrated account in
  User Management started failing with "Failed to update user": the pre-1.0.207 recompute had left BOTH an
  active AND a soft-deleted row per clinic for ~all migrated accounts (647 soft-deleted rows across 59
  accounts), so the sync trigger's reactivate step collided (err 2601) on the next `emed_user` UPDATE.
  Fixed with an admin `DELETE FROM emed_user_clinic WHERE is_invalid = 1` (active rows = the real mirror,
  untouched; trigger rebuilds from `emed_user.clinics`). Collision-risk accounts 59 → 0. Generalizes the
  single-account giano fix from 1.0.207. (Surfaced while re-scoping the `Jack.Jill` API account to the
  merged "Jack & Jill Health" facility.)
- 2026-08-18 — **1.0.211: Facilities page enhancements.** Facility Groups folded into the main Facilities
  table (Type = "Group", name shows "Helimeds (3 Clinics)"), opening in the same right-hand detail pane as
  a facility (groups modal removed). Added a sortable **Users** column (scoped-user count per facility/
  group). The facility **Users** section now also lists the External Reps / Prescribers who can view that
  clinic (read-only, "via group X" vs "scoped directly"), and an API account's **Display Name** (the
  base64 `customer` header) is editable there. Plus UI polish (full "Names"/"Group" headers, greyed
  `[inactive]` facilities, "Clinic Portal User" label). No schema change.
- 2026-08-19 — Cross-team **as-built briefing** written for review:
  [`projects/emed-app/patient-portal-and-facility-groups.md`](../projects/emed-app/patient-portal-and-facility-groups.md).
