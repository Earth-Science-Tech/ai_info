# eMed Per-Page Permission System (View_Page_* / Write_Page_*)

Every sidebar page in eMed has its own **Read** permission (`View_Page_<Key>`) and, unless it's
read-only, its own **Write** permission (`Write_Page_<Key>`). Admins compose fully-modular custom
roles by ticking Read/Write per page in User Management → Roles; built-in code roles keep their exact
historical access by *derivation*. This doc is the model + the **rules for adding a new page** so eMed
stays modular. **When you create a new page, you MUST register it here** (see the checklist at the end).

## Single source of truth: `server/page_catalog.js`

A dependency-light registry (requires only `./misc` — `permissions.js` and `permission_catalog.js`
require IT, so it must not require them). It holds four things per page:

1. **`PAGES[]`** — one entry per page:
   ```js
   { key:'CRMLeads', label:'CRM · Leads', href:'/crm/leads', routes:['/crm/leads'], section:'crm',
     description:'View the CRM leads pipeline.',
     readGate: has('View_Menu_CRM'),                       // reproduces TODAY's sidebar-link condition, VERBATIM
     write: { gate: has('Write_CRM'), subFlags:[], description:'Create/edit/delete/import CRM leads.' } }
   ```
   - `readGate(perm, role, isClinicScoped) => bool` — **copied verbatim** from the page's existing sidebar
     link condition. It must be `>=` any route guard so no built-in role loses access.
   - `write` (omit → the page is **read-only**, no `Write_Page_*`): `gate` = the page's general-edit write
     condition; `subFlags` = granular **money/PHI action flags** kept first-class (Charge_Invoice,
     Write_Refills, Release_Pre_Clarification, …) — they are NOT collapsed into the page W.
   - `adminOnly:true` → Read flag only, write stays on the real Admin role (`/database`, `/users`).
   - `sidebar:false` → route-only page (e.g. invoice detail opened from a list), no sidebar link.

2. **`REQUIRES{}`** — **the load-bearing map.** The flags auto-granted when a custom role ticks the page's
   Read. It MUST grant **everything the page needs to FUNCTION**, not just what makes the sidebar link
   appear: the `readGate` flag **+ every flag guarding a GET/read API the page calls on load + any in-page
   content-access gate flag.** (See "Read-completeness rule" below — this is the #1 thing devs get wrong.)

3. **`WRITE_CAP{}`** — the single capability flag a W-toggle page's general write endpoints are gated on
   (e.g. `CRMLeads:['Write_CRM']`). Absent for read-only pages and money/PHI-only pages.

4. **`WRITE_ROUTES[]`** — per-page-independent **write** enforcement map. One entry per write API endpoint:
   ```js
   { methods:['POST'], pattern:'/api/crm/leads', pages:['CRMLeads'], guard:'Write_CRM' }
   ```
   `guard` is the flag the endpoint is guarded on today (string, or an array = the `perm_any` set) — used
   only by the neutrality test. A path that mutates >1 page lists all of them. **Money/PHI action routes
   are DELIBERATELY OMITTED** (they keep only their granular guard). See exclusions below.

## How the flags resolve (built-in vs custom)

`server/permission_catalog.js` `union_permissions(roles, map)`:
- **Built-in (code) role** → `derive_page_flags` sets `View_Page_X` (and `Write_Page_X`) from `readGate`/
  `write.gate` over the role's own code-defined perms. So built-ins carry per-page flags == today's access
  with **zero role-factory edits**.
- **Custom role** (`emed_custom_role`) → its ticked `View_Page_X`/`Write_Page_X` keys are authoritative;
  `View_Page_X` expands to `requires_for(key)`, `Write_Page_X` implies Read + grants `write_requires_for`
  (`requires ∪ writeCap`). Money/PHI sub-flags are NOT auto-granted — they stay individually grantable in
  the editor's **Advanced** group.

Perms resolve **once at login** into `req.session.user.perm`. `PERM_SCHEMA_VERSION` (permission_catalog)
is stamped on `perm_v`; `auth.login` transparently rebuilds a stale-shaped perm on the next request (no
forced logout). **Bump PERM_SCHEMA_VERSION only if you change the resolved-perm SHAPE** (adding page flags
does not require a bump — new pages just appear).

## Enforcement (two additive, dark-by-default middlewares)

Both mirror each other; both are mounted in `app.js` right after `auth.login`, and both are **additive** —
they run *on top of* the routers' existing `auth.perm` guards, never replacing them.

- **Read:** `auth.page_gate(route_to_page(), {exclude})` — matches a GET render route to its page and
  requires `View_Page_<key>`; renders `views/401.ejs` on denial. Env `PAGE_GATING_MODE` = `off` (default) |
  `report` (log `page_gate_would_deny`) | `enforce`.
- **Write:** `auth.write_gate(write_route_to_page())` — method + param-aware, matches a write request
  (POST/PUT/PATCH/DELETE) to its page(s) and requires `Write_Page_<key>`. Env `WRITE_GATING_MODE` (same
  three modes). Because `Write_Page_X` derives == the endpoint's old capability for built-ins, it is
  **behavior-neutral for every code role** — proven by a script + the test suite (0 violations across all
  built-in roles × all entries).

Both ship **dark**. Roll out per env: `off` → `report` (watch App-Insights would-deny telemetry) →
`enforce`, dev slot first. The registry (`Write_Page_X` derived flags) is live regardless of mode.

## The load-bearing RULES (learn these before adding a page)

1. **readGate is VERBATIM** — copy the page's existing sidebar-link / route condition exactly. Parity for
   built-ins is by construction; a render-based test asserts each page's `requires` surfaces its link.
2. **Read-completeness (REQUIRES must cover the page's data APIs).** The #1 bug class. A page's `requires`
   originally only granted its section's `View_Menu_*` flag (enough to show the *link*), but the page's
   data fetch / content gate often needs MORE. Symptoms for a custom Read role: the page renders but a GET
   500s (`auth.perm` returns 500 `{message:'Unauthorized'}`) or a content gate says "You do not have
   permission." **Fix:** put every read-API guard flag + content-gate flag in `requires`. When the missing
   flag is a **narrow capability** (e.g. `View_Logs`, `Write_Tasks`, `View_Payment_Methods`) → add it to
   `requires`. When it is a **broad `View_Menu_<other-section>` flag** (adding it would light up another
   sidebar section) → instead **relax the shared list endpoint** to also accept the page's read flag
   (`auth.perm_any([...])`, purely additive) rather than over-granting. Examples of the latter:
   `/api/clinic/clinics`, `/api/clinic/document-clinics`, `/api/crm/tags`, the `/api/clarifications/*` GET
   reads (relaxed to accept the caller pages' flags).
3. **Single-capability pages have no read-only mode.** IT Support (`Manage_User_Auth`), CRM Pending
   (`Write_CRM`) — the whole page IS the capability. Model as **one access toggle**: readGate stays the
   section flag but `requires` grants the capability, and **no separate W toggle** (a split would show the
   action UI to a Read-only role while the write-gate blocks the action). Do NOT give these a `write` block.
4. **Money/PHI stays granular.** Charge/refund/set-prescriber/sign/refill/resubmit/release/redrive keep
   their own action flags. Put them in `write.subFlags` (shown under the page in the editor, kept in
   Advanced), NOT in `writeCap`, and **do not add their routes to WRITE_ROUTES.**
5. **WRITE_ROUTES neutrality.** Map a path → page K only when the path's guard flag == K's `writeCap`
   (so `guard passes ⟹ Write_Page_K held` for every built-in). A `perm_any` guard is covered if `requires`
   has any one of its flags. The neutrality validator (below) proves this.
6. **Sidebar gating.** Every link: `<% if (<section_heading_flag> && pg('Key')) { %>` where
   `pg(k)===perm['View_Page_'+k]`. A **section heading must not render empty** — gate it on ≥1 of its pages
   being visible (see `moct_section_links`/`emed_section_links` in sidebar.ejs), else a role that holds a
   broad flag but none of the section's pages shows a bare heading.
7. **EJS gates: access vs edit.** A whole-page **access** deny (`<% if (!perm.X) { include('401') } %>`)
   must key off the **read** flag (`View_Page_X` or the readGate flag) — NOT `Write_Page_X`, or a Read-only
   role 401s. An **edit-element** gate (buttons/inputs) keys off `Write_Page_X` (or the shared `writeCap`
   for views shared by several pages, e.g. moct/visits.ejs).
8. **Shared views/endpoints.** Peaks pages render the MOCT visit views and call `/api/moct/*` (guarded
   `View_Menu_MOCT`), so their `requires` include `View_Menu_MOCT`. A write endpoint serving multiple pages
   lists them all in its WRITE_ROUTES entry (gate passes if the user may write ANY).

## Verify (always, before shipping a page change)

```bash
# neutrality: no built-in role newly denied; no dropped page refs
node -e "const pc=require('./server/page_catalog'),perms=require('./server/permissions'),pcat=require('./server/permission_catalog');
 const gp=(g,p)=>Array.isArray(g)?g.some(f=>p[f]):!!p[g];
 for(const r of perms.Get_Roles()){const p=pcat.union_permissions([r],null);
  for(const e of pc.WRITE_ROUTES){if(gp(e.guard,p)&&!e.pages.some(k=>p['Write_Page_'+k]))console.log('VIOLATION',r,e.pattern);}}"
# run via: node node_modules/vitest/vitest.mjs run <file>   (.bin shim missing on this box)
node node_modules/vitest/vitest.mjs run tests/unit/server/page_requires.test.js tests/unit/server/page_catalog.test.js tests/unit/server/write_gate.test.js --no-file-parallelism
```
Tests that must stay green: `page_requires.test.js` (requires surfaces the sidebar link; W-toggle write
gate consistency; managed/advanced partition), `write_gate.test.js` (neutrality across all roles + per-page
independence + method/param matcher + exclusions), `page_catalog.test.js`, `custom_roles.test.js`,
`role_preview.test.js`.

## CHECKLIST — adding a new page (do ALL of these)

1. **Route** — add the `app.get('/your-page', auth.login, auth.perm('<flag>'), …)` render route as usual.
2. **`PAGES` entry** — `{ key, label:'Section · Name', href, routes:['/your-page'], section, description,
   readGate: has('<the route/sidebar flag>'), write:{ gate:has('<writeCap>'), subFlags:[<money/PHI flags>],
   description } }`. Omit `write` if the page is read-only; `adminOnly:true` for raw-admin pages;
   `sidebar:false` for route-only pages.
3. **`REQUIRES[key]`** — `[<readGate flag>, …every GET/read-API guard flag the page calls on load, …content
   gate flag]`. Trace the view's `api_call('…','GET')`/`fetch('/api/…')` and each endpoint's `auth.perm`.
   If a needed flag is a broad other-section `View_Menu_*`, **relax that shared endpoint** instead.
4. **`WRITE_CAP[key]`** — `['<writeCap flag>']` if the page has a W toggle (omit for read-only / money-only).
5. **`WRITE_ROUTES`** — one entry per write endpoint the page owns: `{ methods, pattern, pages:[key],
   guard:'<writeCap>' }`. EXCLUDE money/PHI action routes and read-via-POST. Shared endpoints list every
   page they mutate.
6. **Sidebar** — add the link `<% if (<heading_flag> && pg('Key')) { %>…`; if it's a NEW section, add the
   section key to `SECTIONS` in page_catalog.js and a heading in sidebar.ejs gated on ≥1 visible page.
7. **EJS gates** — page-access deny on `View_Page_Key` (or the readGate flag); edit-element gates on
   `perm.Write_Page_Key`.
8. **Verify** — run the neutrality one-liner (0 violations) + the test suites above. Add a
   `page_requires`/`write_gate` case if the page has unusual sharing.

Related: `projects/emed-app/context.md` (auth/roles), `skills/add-page.md` (this checklist as a skill).
