---
title: Per-Page Read/Write Permissions (View_Page_* / Write_Page_*)
slug: per-page-permissions
status: Completed in Dev
project: emed_app
branches:
  - emed_app: feat/per-page-permissions
developers:
  - nicholas-cardell
prs:
  - "emed_app#397 (feat/per-page-permissions -> main, open for review)"
tags: []
created: 2026-08-08
updated: 2026-08-12
related: []
---

# Per-Page Read/Write Permissions

## Status & history
- 2026-08-08 — Not Started → In-Progress (nicholas-cardell) — framework + registry built.
- 2026-08-12 — In-Progress → Completed in Dev (nicholas-cardell) — full system on `feat/per-page-permissions`,
  merged to `dev` (live on the Azure dev slot); enforcement default flipped to **fail-closed**; CI gate +
  release-skill checks added. A 4-lens adversarial review then caught two route-level breaks under enforce
  (EO participant detail = BLOCKER, `/issues/new` = MED) — both fixed with a `page_gate` carve-out; the
  `View_App` backfill was scoped to page-driven roles. Pending: developer review/test, then
  `feat/* → main` promotion + prod rollout.

## Summary

Make eMed **fully modular by page**: every sidebar page gets its own **Read** (`View_Page_<Key>`) and,
unless read-only, **Write** (`Write_Page_<Key>`) permission, so admins can build custom roles page-by-page
(User Management → Roles). **Built-in roles are behavior-neutral** — they *derive* their per-page flags
from their existing capability grants, so nothing changes for them. Enforcement is two additive,
registry-driven middlewares that run **on top of** the existing `auth.perm` guards.

Why: access was welded to ~21 coarse `View_Menu_*` flags + ~40 capability flags, several spanning multiple
pages, hardcoded across the sidebar, ~274 route guards, and per-page EJS gates. There was no per-page
permission, so you couldn't grant "read this one page" without lighting up a whole section.

## Design / approach

**Registry = single source of truth:** `emed_app/server/page_catalog.js`
- `PAGES[]` — one entry per page: `key`, `label`, `href`, `section`, `readGate` (copies the page's existing
  read condition **verbatim**), and (unless read-only) `write: { gate, subFlags[] }`.
- `REQUIRES[Key]` — every flag the page needs to **function** (the sidebar-link flag **plus** every flag
  guarding a GET/read-API the view calls on load, plus any in-page content gate). The step devs forget.
- `WRITE_CAP[Key]` / `WRITE_ROUTES[]` — method+param-aware map of each write endpoint → page(s), keyed on
  the endpoint's real guard capability.

**Derivation symmetry** (`server/permission_catalog.js` `union_permissions`):
- Built-in (code) roles: `View_Page_*`/`Write_Page_*` are **derived** from `readGate`/`write.gate` at
  resolution — zero factory edits, parity by construction.
- Custom roles (`emed_custom_role`): carry ticked flags authoritatively; a ticked page **expands** via
  `requires_for` / `write_requires_for` (grants the section header + capabilities the page needs).
- **Invariant (added 2026-08-12):** if the resolved perms grant any `View_Page_*` but not `View_App`,
  `View_App` is backfilled — so an admin can't build a page-granting custom role that's locked out of
  every page under enforce. Additive; verified no-op for all 19 built-in roles.

**Enforcement — two additive, dark-capable middlewares** (`server/auth.js`, mounted in `app.js`):
- `page_gate` (READ, GET renders): denies with the friendly `views/401` when the user lacks
  `View_App && View_Page_<key>`. Skips non-GET, unauthenticated, unmatched paths, and excludes
  `/api-documentation` (public).
- `write_gate` (WRITE, POST/PUT/PATCH/DELETE): 403 JSON when a mapped path's `Write_Page_<key>` is absent.
  Runs alongside — never replaces — the existing `auth.perm('Write_*')` guards. **Money/PHI action routes
  (charge/refund/sign/prescribe/resubmit/release/…) are deliberately UNMAPPED** — they keep only their
  granular action-flag guard.
- **Neutrality:** `Write_Page_X` derives == the endpoint's old guard for built-ins, so enforce denies no
  built-in role any write it can do today (proven by `tests/unit/server/write_gate.test.js` + the registry
  checker across all 19 roles).

**Fail-closed default (changed 2026-08-12):** `PAGE_GATING_MODE` / `WRITE_GATING_MODE` now default to
**`enforce`** when unset/misspelled; only an explicit `off` or `report` reduces enforcement. Rationale: a
forgotten env var should stay secure, not silently allow. (Was `off` — dark by default.)

### Load-bearing rules (from `ai_info/projects/emed-app/per-page-permissions.md`)
readGate is verbatim · read-completeness (REQUIRES grants every read-API/content flag) · single-capability
pages have no W toggle (capability goes in `requires`) · money/PHI granularity stays as `subFlags`, routes
excluded from WRITE_ROUTES · WRITE_ROUTES neutrality (map path→K only when guard == K's writeCap) ·
empty-heading suppression · access-gate keys off the Read flag, edit-gate off `Write_Page_X`.

## Safety verification (default → enforce)

Verified deterministically **and** by a 4-lens adversarial workflow (lockout / public-machine-surface /
View_App-invariant / login-only-tightening):

- **0 built-in-role lockouts:** all 19 built-in roles resolve `View_App=1`; every page a role derives is
  reachable under enforce. Deterministic check over `Get_Roles() × PAGES`, independently re-derived by the
  lockout lens.
- **Public / machine surface SAFE:** both gates skip any request with no `session.user`, so
  unauthenticated, public-render, webhook, and Basic-auth API routes are untouched; `/api-documentation`
  (the one registered public page) is excluded.
- **Custom-role lockout closed** by the `View_App` invariant — **scoped to page-DRIVEN roles** (an admin
  who ticked a page), so it does NOT silently re-activate a legacy capability role that was disabled by
  clearing `View_App`.
- **Two route-level breaks found by the workflow and FIXED** (a new `page_gate` `excludePaths` carve-out —
  a sub-route whose own guard is authoritative is exempted without un-gating its parent list page):
  - **HIGH (BLOCKER, fixed):** `/eo/orders/:id` — EO **participants** (assigned a subtask, no
    `View_Menu_EO`) view an order via `page_order_scope` + template gate; enforce would 401 them because
    page_gate prefix-matched the detail to the `/eo/orders` list (`View_Menu_EO`). Now exempted (`/eo/orders/`).
  - **MED (fixed):** `/issues/new` (guard `Submit_Issue`) was prefix-swept under `/issues`
    (`View_Menu_Issues`). Now exempted. (The topbar report-issue modal was already unaffected.)
- **LOW (validate in report):** `/billing/invoice/:id` tightens from login-only to `View_Menu_Billing`;
  confirm no non-Billing role deep-links to it during report-mode validation.
- **Full unit suite green** with the enforce default; per-page + gate + EO subset is 342/342. (One
  unrelated pre-existing test, `api_users_test_mode.test.js`, fails only until `origin/main` is merged
  forward — main already allowlists `rx_resubmit.js`.)
- **Known intentional tightening (R3):** enforce otherwise closes direct-URL access to registered pages
  whose route guard is weaker than their readGate (login-only GETs). This is the point of per-page access
  control; it removes no built-in role's *sidebar* pages (readGate is verbatim). It **improves** security
  in places — e.g. `/database` and `/users` were reachable by any logged-in user by direct URL and are now
  gated. Full tightening enumeration is in the PR. Validate per env in `report` mode first.

## Guardrails so new pages stay modular (no manual audits)

- **`scripts/check_page_registry.js`** — CLI + `run_checks()`: sidebar links ⊆ registry, write-gate
  neutrality, no dropped/read-only refs, tooltip completeness.
- **CI gate:** `tests/unit/server/page_registry.test.js` runs in `npm run test:unit` on every PR to
  main/dev — a new sidebar page without its registration turns the PR red.
- **Release gate:** wired into `push-prod` (Step 1.6) and `push-pr` (Phase 5.0) pre-flight.
- **Author guidance:** `ai_info/skills/add-page.md` + `ai_info/projects/emed-app/per-page-permissions.md`.

## Rollout / remaining

1. **Developer review + test** on the dev slot (this PR). Enforce is now the default there, so the reviewer
   exercises real enforcement; set `PAGE_GATING_MODE=report`/`WRITE_GATING_MODE=report` on the dev slot to
   validate via App Insights `page_gate_would_deny` / `write_gate_would_deny` events instead.
2. **Promote** `feat/per-page-permissions → main` (gatekeeper PR + tag).
3. **Prod rollout:** set the prod slot to `report` first; watch would-deny telemetry for a few days (zero
   built-in-role events = go); then leave UNSET (=enforce) or set `enforce`. Instant rollback = set `off`.
4. Custom roles are built page-by-page in User Management → Roles; effective at the user's next login
   (perms rebuild every request via the `auth.login` login-snapshot upgrade — no forced logout).

## Key files

`server/page_catalog.js` (registry) · `server/permission_catalog.js` (derivation + View_App invariant) ·
`server/auth.js` (page_gate/write_gate + fail-closed modes) · `app.js` (mounts) ·
`views/emed/users.ejs` (Roles "Page" section) · `views/partials/sidebar.ejs` (per-page `pg()` gating) ·
`scripts/check_page_registry.js` + `tests/unit/server/{page_registry,write_gate,page_requires,page_catalog}.test.js`.
