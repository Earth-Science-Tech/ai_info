# Skill: Add an eMed Page (register it in the per-page permission system)

## Trigger

When adding a **new sidebar page** to eMed (emed_app) — phrases like "add a new page", "create a
`/foo/bar` page", "add a sidebar page/tab", "new admin/CRM/billing screen", or any new
`app.get('/…', … res.render(…))` render route that appears in the sidebar.

## Why this exists

eMed is **fully modular by permission**: every sidebar page has its own Read (`View_Page_<Key>`) and,
unless read-only, Write (`Write_Page_<Key>`) permission, so admins can build custom roles page-by-page.
A new page that is NOT registered in `server/page_catalog.js` is invisible to the role system — it can't
be granted per-page, its read/write routes aren't per-page-enforceable, and custom roles will hit 500s or
"no permission" on it. **Registering the page is part of building it, not an afterthought.**

Full model + rationale: [`projects/emed-app/per-page-permissions.md`](../projects/emed-app/per-page-permissions.md).
Read it if anything below is unclear — especially the **read-completeness rule** and the money/PHI rule.

## What to do (the checklist)

Do ALL of these in `emed_app`, then verify.

1. **Render route** — add `app.get('/your-page', auth.login, auth.perm('<Flag>'), (req,res)=>res.render('<view>', html_data(req)))` as usual. `<Flag>` is the page's read/access flag.

2. **`page_catalog.js` → `PAGES[]`** — add an entry:
   ```js
   { key:'YourPage', label:'Section · Name', href:'/your-page', routes:['/your-page'], section:'<section>',
     description:'What the page shows.',
     readGate: has('<Flag>'),                       // COPY the route/sidebar condition verbatim
     write: { gate: has('<WriteCap>'), subFlags:[/* money/PHI action flags */], description:'What writing does.' } }
   ```
   - **Read-only page?** Omit the whole `write` block.
   - **Single-capability page** (the whole page IS a capability, no read-only view — like IT Support):
     omit `write`; put the capability in `requires` (step 3) so Read grants it.
   - **Money/PHI page?** No `writeCap`; list the granular flags (Charge_Invoice, Write_Refills, …) in
     `write.subFlags` (they stay individually grantable) and do NOT map their routes in step 5.
   - `adminOnly:true` (raw-admin, e.g. /database) → Read flag only. `sidebar:false` → route-only page.

3. **`REQUIRES[YourPage]`** — ⚠ **the step devs forget.** List **every flag the page needs to FUNCTION**,
   not just the sidebar-link flag: `[ '<Flag>', …every flag guarding a GET/read API the view calls on
   load, …any in-page content-access gate flag ]`. Trace the view's `api_call('/api/…','GET')` /
   `fetch('/api/…')` and read each endpoint's `auth.perm(...)`. If a needed flag is a **broad
   `View_Menu_<other-section>` flag**, DON'T add it here (it would light up that other section) — instead
   **relax the shared endpoint** to `auth.perm_any([...])` to also accept your page's flag (additive).

4. **`WRITE_CAP[YourPage]`** — `['<WriteCap>']` if the page has a general Write toggle (skip for read-only
   / money-only pages).

5. **`WRITE_ROUTES[]`** — one entry per write endpoint the page owns:
   `{ methods:['POST',…], pattern:'/api/…/:id', pages:['YourPage'], guard:'<WriteCap>' }`. EXCLUDE
   money/PHI action routes and read-via-POST. A shared endpoint lists every page it mutates.

6. **Sidebar** (`views/partials/sidebar.ejs`) — add the link gated on `<% if (<sectionHeadingFlag> &&
   pg('YourPage')) { %>…`. New section → add its key to `SECTIONS` (page_catalog) and a heading gated on
   **≥1 of the section's pages being visible** (don't render an empty heading).

7. **In-page EJS gates** — a whole-page access deny keys off the **read** flag (`View_Page_YourPage` or the
   readGate flag), NOT `Write_Page_YourPage`. Edit-element gates (buttons/inputs) key off
   `perm.Write_Page_YourPage`.

8. **Verify** — 0 neutrality violations + green tests:
   ```bash
   cd emed_app
   node node_modules/vitest/vitest.mjs run tests/unit/server/page_requires.test.js \
     tests/unit/server/page_catalog.test.js tests/unit/server/write_gate.test.js --no-file-parallelism
   ```
   The `page_requires` render test auto-covers "requires surfaces the link"; add a `write_gate` case if the
   page shares endpoints/flags with siblings.

## Rules that bite (from per-page-permissions.md)

- **readGate is verbatim** — parity for built-in roles is by construction.
- **WRITE_ROUTES neutrality** — map a path→page K only when the path's guard == K's `writeCap`, so no
  built-in role is newly denied. The neutrality validator/test proves it.
- **Everything ships dark** — `PAGE_GATING_MODE` / `WRITE_GATING_MODE` = `off`(default)|`report`|`enforce`.
  The registry (derived `View_Page_*`/`Write_Page_*`) is live regardless; enforcement flips per env.
- **Deploy** — code-only (no `emed_sql` migration; flags are code-defined). Ship via the normal feature
  branch → dev preview → `feat/* → main` promotion.

## Applies to

- **emed_app** — `server/page_catalog.js`, `server/permissions.js`, `server/auth.js`, `app.js`,
  `views/partials/sidebar.ejs`, `views/emed/users.ejs` (role editor, data-driven — no edit needed).
