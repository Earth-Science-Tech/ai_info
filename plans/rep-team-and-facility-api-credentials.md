---
title: Rep Team (ExternalRepAdmin + My Team) and rep-mintable facility API credentials
slug: rep-team-and-facility-api-credentials
status: In-Progress
project: emed_app
branches:
  - emed_app: feat/rep-team-and-facility-api-credentials
developers:
  - nicholas-cardell
prs: []
tags: []
created: 2026-09-16
updated: 2026-09-16
related: [externalrep-blaze-orders, facility-scope-groups, portal-foundations]
---

# Rep Team (ExternalRepAdmin + My Team) and rep-mintable facility API credentials

## Status & history
- 2026-09-16 — Not Started → In-Progress (nicholas-cardell): built on the feature branch, unit suite green (6,834 tests), not yet on dev.
- 2026-09-16 — Smoke-tested end to end on the LOCAL app against `liberty_link_dev` via View-As Grant (promoted
  to ExternalRepAdmin on dev): My Team add / promote / demote / disable / re-enable + every guard (self-demote,
  self-disable, out-of-group 404, bad body); My Facilities → Issue API credential → show-once modal → Basic-auth
  `/api/public/ping` 200 with the header, 403 with a wrong header, `/scripts` 200 → Revoke → ping 403. Found and
  fixed one real bug the mocked tests hid: `sql.upsert` needs `'id'` as key_name (its default null = INSERT →
  identity error) on the role-change and revoke paths; tests now pin the key argument. Dev leftovers: user 218
  (`rep.devsmoke@rxcs.net`, disabled) and 219 (revoked API account) in group 8.

## Summary
Three asks from Nick for Grant (GC Consulting, `emed_user` 60, ExternalRep, sales group 8 "GC Consulting",
68 facilities), who is building a third-party tool that views and submits prescriptions through the eMed API
for many clinics and is hiring reps to work his territory:

1. **Per-facility API credentials a rep can issue** from Rep Tools > My Facilities. In eMed an API credential
   IS an `emed_user` with role `API`: Basic auth + a `Customer` header that must equal the account's `name`,
   and that `name` is stamped as the clinic on every order and filters every read — so one credential is
   inherently ONE facility. No new key table: we mint exactly such an account, with the identity chosen by the
   server (never typed — the Azalea "Azelea" lockout class).
2. **Head-prescriber invites** — already shipped (Portal Signups, PR #612): My Facilities → Invite to portal →
   14-day single-use link → approve provisions the facility + head user (ExternalPrescriber / ClinicUser) →
   activate (staff) → the head prescriber manages their own staff on /prescriber/team. Nothing built here;
   67 of Grant's 68 facilities have no portal enabled and are invitable today.
3. **My Team** — a new built-in role **`ExternalRepAdmin`** (= ExternalRep + `Write_Rep_Team`) manages the
   other rep accounts scoped to the same facility group. Nick chose two roles over a per-user bit so a human
   reading User Management can tell the team lead from the team ("eMed is growing large; a `team_admin` bit
   will be confusing once other sections have a My Team").

## Design / approach

**Role (`server/permissions.js`, `server/permission_catalog.js`, `server/rep_roles.js`).**
- `ExternalRepAdmin()` = `ExternalRep()` + `Write_Rep_Team = 1`. Built-in (7th code role in `Get_Roles()`),
  `MACHINE_ROLE_META` identical to ExternalRep (clinic-scoped via `clinics`, session auth, MFA, exclusive).
  `PERM_SCHEMA_VERSION` 23 → 24 so live sessions gain the new flags.
- New flags: `View_Rep_Team` (both rep roles), `Write_Rep_Team` (admin only), `Write_Facility_API_Credentials`
  (both rep roles; explicit capability, deliberately NOT a page W toggle).
- `server/rep_roles.js` (leaf, dependency-free): `REP_ROLES`, `is_rep_role()`. Every former
  `role === 'ExternalRep'` literal now goes through it: `page_catalog.js` (LeadTasks exclusion, BlazeBatches
  read), `facilities.get_users_for_facility`, `portal_notify_groups` exclusion, `route_prescriber` notify
  recipients ×2, `clarifications.ejs` ×2, `lead-tasks.ejs`. Pinned by `external_rep_admin_role.test.js`
  ("admin derives EXACTLY ExternalRep's page set + Write_Page_RepTeam").

**My Team (`server/rep_team.js`, `/api/rep/team*`, `views/reptools/team.ejs`, page `RepTeam`).**
- The team IS the facility group: members = `emed_user.scope_group_id = <actor's group>` with a rep role.
  A new member is scoped to the same group, so territory access (facilities, GCC leads, prescriptions,
  pricing, order sets) is immediate with zero new access code.
- `team_ctx(req, {write})`: effective login (View-As safe) → must be an ACTIVE rep role with a group; writes
  require role ExternalRepAdmin (route flag `Write_Rep_Team` + role re-check = second lock, so a custom role
  can't reach it). Out-of-group targets 404, never 403. Last-admin guard; no self-demote / self-disable.
- Add = `users.create_portal_account(..., { allowed_roles: REP_ROLES })` (login = email, group scope forced,
  `password_change_required=1`, MFA at first login) + `users.send_portal_welcome`; the temp password is
  returned ONCE only if the email failed. Promote/demote writes `role` + `roles` and revokes the target's
  sessions (perms are a login-time snapshot). Disable = `is_invalid=1` (same flag as User Management) +
  session revoke; re-enable guards duplicate logins.
- Page: `gen_datatable`, all columns sortable, funnels with per-value counts on Role / Status / MFA,
  chronological Created (type:'date' + ASCII format), active-filter chips.

**Facility API credentials (`server/facility_api_credentials.js`, `/api/rep/facilities/:id/api-credentials*`).**
- Fence: `rep_territory.territory_facility_ids` (staff unscoped, no group = fail closed, out-of-territory 404).
- `mint(fid)`: facility active; `name` = the display name if it is an active `emed_facility_name` variant
  (true for all 1,855 active facilities on prod 2026-09-16) else the primary variant; printable-ASCII only
  (authenticate_api decodes the header as ASCII); `user_login = <slug>.api.<6 hex>` unique across ALL rows;
  32-char random password; `create_portal_account({ role:'API', scope_facility_id }, {app_name:
  'rep_api_credential'}, { allowed_roles:['API'], password_change_required: 0 })`. Password appears in the
  POST response only. Best-effort heads-up email to the support mailbox (no password).
- Max 2 active rep-minted per facility (rotation). Revoke = soft-disable, ONLY rows with the rep-minted
  marker; staff-issued accounts list read-only. Panel on My Facilities detail, show-once modal with
  username / password / base64 `Customer` header / curl against `/api/public/ping`.
- Admin visibility: minted accounts appear on API & Clinic User Management like any API account.

**Registry.** `page_catalog`: `RepTeam` (section reptools, read `View_Rep_Team`, write `Write_Rep_Team`),
REQUIRES/WRITE_CAP, WRITE_ROUTES for `/api/rep/team*` (guard `Write_Rep_Team`) and the credential
POST/DELETE (guard `Write_Facility_API_Credentials`, mapped to RepFacilities — neutral: every holder also
derives `Write_Page_RepFacilities`). `nav.js` NAV_META `RepTeam`. `check_page_registry.js` ✓ (7 roles neutral).

## Rollout / remaining
- **Code-only. No emed_sql migration** (roles + flags are code-defined; API credentials are `emed_user` rows).
- **Data step after deploy (User Management, no script):** change Grant (`emed_user` 60) to `ExternalRepAdmin`.
  Optionally the other sole-member territory reps (Jill 56, Melanie 57, Giano 58) — each is today the only
  member of their group, so promoting them is behaviour-neutral until they add someone.
- Ship: changelog entry (`node scripts/changelog.js scaffold <tag>`), PR `feat/* → main`, tag. Sessions pick
  up the flags via the PERM_SCHEMA_VERSION bump (no re-login).
- Validate on dev: as Grant (View-As) → Rep Tools shows My Team; add a member (welcome email to a test
  inbox); promote/demote; disable/re-enable; My Facilities → a facility → Issue API credential → ping with
  the curl; revoke → 403 on the next ping. Check the minted row on API & Clinic User Management.
- Policy knobs (one-line factory changes): whether plain `ExternalRep` may mint credentials
  (`Write_Facility_API_Credentials` in `ExternalRep()`); whether minting should require the facility to have
  a payment method on file (not enforced).
- Known gaps: no working test/sandbox mode for API accounts (`is_test_only` is stored, not consumed); the
  My Facilities list itself stays server-paginated (pre-existing hand-rolled table — the credential UI lives in
  the detail panel and never touches it); a promoted member must sign in again (sessions revoked on purpose).
- Tests: `external_rep_admin_role.test.js`, `rep_team.test.js`, `facility_api_credentials.test.js`,
  `sidebar_nav.test.js` (new case); role-list pins updated in `permissions.test.js`, `permission_catalog.test.js`,
  `portal_notify_groups.test.js`, `portal_member_access.test.js`, `sales_review_bugs.test.js`,
  `order_sets_portal.test.js`.
