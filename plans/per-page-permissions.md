---
title: Per-Page Read/Write Permissions (View_Page_* / Write_Page_*)
slug: per-page-permissions
status: Completed in Production
project: emed_app
branches:
  - emed_app: feat/per-page-permissions
developers:
  - nicholas-cardell
prs:
  - "emed_app#397 (feat/per-page-permissions -> main, MERGED)"
tags:
  - "1.0.201"
created: 2026-08-08
updated: 2026-08-14
related: []
---

# Per-Page Read/Write Permissions

## Status & history
- 2026-08-14 — Completed in Dev → **Completed in Production** (nicholas-cardell) — **SHIPPED PROD as
  1.0.201** (PR #397 merged to main + tagged; Azure deploy green). Added per-page Zoolzy WRITE (54 routes),
  hid 3 dead flags, forward-merged main. Final go-live audit: **0 neutrality violations** across all 19
  built-in roles (identical read+write access under enforce); custom roles lockout-safe. Code-only, no
  schema. Enforce is the default; `auth.refresh_stale_perms` upgrades active sessions on deploy.
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

## Deploy-safety hardening (Step A, 2026-08-13)

The gates are mounted globally and read the session perm **before** the per-route `auth.login`
rebuild — so a session created before the `PERM_SCHEMA_VERSION` bump would, under enforce, be
401/403'd on its first post-deploy request. `auth.refresh_stale_perms` (a global middleware mounted
ahead of the gates) re-resolves any stale session in place first, so **enforce-on-deploy never locks out
an active session** (no re-login). Decision: **ship straight to prod with enforce** (the default) and
fix-forward any reported page — cheaper than manually testing every page. feat `9cc493d`, on dev + #397.

## Prod-parity + registration RESOLVED (2026-08-13)

Forward-merged `origin/main` into feat (feat is now current with prod; PR #397 is a clean promotion; the
old rx_resubmit tripwire cleared). The merge revealed **3 features that shipped to prod while this branch
was in dev, all unregistered**: CRM Scheduling (1), Ops (8), Zoolzy (11). **Registered all 19:** Ops +
Scheduling brought from the dev registration; **Zoolzy fully registered** (reads gate `View_Menu_Zoolzy`,
settings `Admin_Zoolzy` — verbatim from the route guards). **Per-page Zoolzy WRITE done** (2026-08-14):
write blocks + `WRITE_CAP` on the 9 writable pages (`Write_Zoolzy` for Vendors/Customers/Applications/PO/
Inventory/Counts; `Write_Zoolzy_Billing` for Products/PriceLists/Invoices) + 54 `WRITE_ROUTES`. The 5
`Admin_Zoolzy` actions (config, app/invoice templates, invoice void, invoice-design) stay UNMAPPED/granular
like money-PHI actions. Compliance + Settings read-only. Adversarial review of the write map: both lenses
SAFE, 0 findings (every guard == route guard, no matcher collision, no missed/stale entry). `/ops/my-forms` → `SIDEBAR_EXCLUDE`. Also **hid 3 dead
flags** (`View_Users`/`Write_POP`/`Write_Inventory` — no enforcement anywhere) from the editor's Advanced group.
**112 pages, 286 write routes, 19 roles neutral, 0 lockouts; full suite 3405/3405; 4-lens adversarial review
all SAFE** (registration-parity: every readGate == its route guard exactly; zoolzy read can't leak write;
merge-neutrality: security files byte-identical/clean). Non-blocking notes: SuperUser reaches CRM-Scheduling
admin (pre-existing on main, neutral — eyeball intent); per-page Zoolzy write is a follow-up.

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
