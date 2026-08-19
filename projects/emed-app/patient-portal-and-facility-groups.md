# Patient Portal + Facility Groups — As-Built Briefing

**Audience:** another team's Claude (Mario's) reviewing what the eMed platform team (Nicholas)
built and shipped, to compare it against a separate plan. This is the **entry point + cross-cutting
story**; the two tracked plans hold the full detail:

- [`plans/facility-scope-groups.md`](../../plans/facility-scope-groups.md) — Facility Scope Unification / Facility Groups
- [`plans/patient-portal-secure-messaging.md`](../../plans/patient-portal-secure-messaging.md) — Patient Portal + Secure Messaging (Phase 1)

Last updated 2026-08-19. Everything below is **as-built and in production** unless it says DARK / deferred.

---

## TL;DR — what's live

| Feature | State | Prod versions |
|---|---|---|
| **Facility Scope Unification / Facility Groups** | **LIVE** — registry is the single source of truth for clinic access | 1.0.205–1.0.207, enhancements 1.0.211 |
| **Patient Portal + Secure Messaging (Phase 1)** | **LIVE but DARK** — code + 6 tables in prod, kill-switch OFF; enables after BAA/consent | 1.0.205 (+ 1.0.208 auth hotfix) |

The two shipped **together** off one branch (`feat/patient-portal-secure-messaging`) because they both
edit `views/admin/facilities.ejs`. (1.0.209 = role-preview fix, 1.0.210 = a *different* team's "exship
tracking" release that collided on the version number — unrelated to these two features.)

---

## 1. Patient Portal + Secure Messaging (Phase 1) — as built

**Problem it solves:** eMed's prescriber network was texting patients plain SMS with clinical content —
not HIPAA-safe. Phase 1 stops that: staff write a **Secure Message**; the patient gets a **PHI-free SMS
magic link**, authenticates, and reads it inside an isolated **Patient Portal**.

**Architecture (all in `emed_app`):**
- **Isolated patient identity** (separate from staff `emed_user`): `patient_portal_user` (phone-keyed,
  passwordless), `patient_portal_person` (junction → `moct_person`; IDOR ownership + clinic scoping),
  `patient_portal_token` (SMS magic link, SHA-256 hashed at rest, single-use, attempt-capped — modeled on
  the existing `emed_payment_capture_token`).
- **Auth = SMS magic link + DOB step-up.** Token rides the URL **fragment** (never sent to the server on
  the preview fetch), verified only on explicit click; DOB is a timing-safe compare against the bound
  `moct_person`; attempt cap then invalidate; session-fixation guard (`session.regenerate()`); links ONLY
  the token's `moct_person` (no auto-merge of other rows sharing the phone).
- **Message store** `moct_secure_message` (PHI, `moct_*` family). Notification SMS goes through the durable
  **`emed_sms` queue** (PHI-free body; ETL owns RingCentral delivery).
- **Per-facility × per-page config, DEFAULT-DENY:** `patient_portal_page_config` (visible_on_emed +
  iframe_enabled per facility×page) + `patient_portal_facility_origin`. Nothing is visible until an admin
  enables it on `/admin/facilities` → Patient Portal. Send-time + view-time gates both enforce it.
- **Own session, isolated from staff:** cookie `eMed.pportal` path-scoped to `/api/portal`; its own
  `express-session` instance. Staff `eMed.session` is untouched (SameSite=Lax). The staff SEND endpoint is
  **`/api/secure-messages`** (deliberately NOT under `/api/portal`, so it keeps the staff session).

**Ships DARK behind `SECURE_MESSAGING_ENABLED` (default off):** staff send 403s, returning-login SMS is a
no-op, and the "Send Secure Message" button/modal on `views/moct/visit.ejs` are omitted server-side — so
no message is sent, no token is minted, no patient can log in. `/portal/*` pages render but are inert.

**⚠ Required prod env var: `PATIENT_PORTAL_SESSION_SECRET`** — `app.js` fail-fasts on boot in prod if
unset (it's the Patient-Portal session secret, distinct from the staff `SESSION_SECRET`; set on prod).

**Dev/localhost SMS behavior:** `is_prod()` keys off `IS_PROD=1` (an explicit env flag, not the DB). On
localhost/dev `is_prod()` is false, so the secure-message SMS **never goes to a patient** — it's routed to
`DEV_SMS_PHONE` (with a `[DEV]` prefix) if set, else suppressed; either way the magic-link URL is printed
to the server console (`[PORTAL] secure-message link (dev): …`) so the flow is testable without any SMS.

**To ENABLE (product-owner, not code):** signed BAA (RingCentral/Azure) + patient e-comms consent
(TCPA/HIPAA) → per-facility enable Messages → tick `Send_Secure_Message` on the MOCT/Prescriber custom-role
rows → set `SECURE_MESSAGING_ENABLED=1`.

**Deferred:** Phase 2 = cross-origin **iframe embedding** (flip `eMed.pportal` to `SameSite=None;
Partitioned`; per-facility origin allowlist drives frame-ancestors/CORS). Phase 3+ = My Prescriptions / My
Profile / Intake pages (each added to the `PORTAL_PAGES` catalog so it's independently per-facility
configurable), patient replies/threading (columns reserved), SMS-OTP step-up, email channel.

---

## 2. Facility Scope Unification / Facility Groups — as built

**Problem it solves:** clinic access for the 4 clinic-scoped roles (**API, ClinicUser, ExternalPrescriber,
ExternalRep**) was hand-typed name strings — `emed_user.name` for API, pipe-delimited `emed_user.clinics`
for the rest. Unmaintainable (one rep had an **891-entry** clinics field), and it never consulted the
Facilities registry, so a clinic's spellings only resolved if someone typed every one. The API `clinics`
field was overloaded as both a name-variant list AND a partner grouping.

**The model (derived-cache):** the Facilities registry is the **single source of truth**. A user's scope is
`emed_user.scope_facility_id` (single facility) **XOR** `scope_group_id` (one `emed_facility_group` — a
**typed** collection of DISTINCT facilities; `group_type` is descriptive free-vocab: `'sales'` = a rep
territory like "JPV/Jill", `'affiliated'` = partner companies like "Valhalla"). `emed_user.clinics` (and
the webhook mirror `emed_user_clinic`) become an **auto-regenerated projection** of the effective facility
set → every active `name_variant` of every scoped facility. **The ~31 read consumers are unchanged** —
they just read a complete, correct list. Tables: `emed_facility_group`, `emed_facility_group_member`,
`emed_user.scope_facility_id/scope_group_id` (migration `2026-08-15_add_facility_groups_and_user_scope.sql`).

**Deliberately NOT done:** re-keying operational tables (`moct_visit`/scripts/orders) to a `facility_id`
FK — huge, high-risk migration on the Rx path; the derived-cache gets ~95% of the benefit at near-zero
risk. **API scope stays `clinic_source:'name'`** — API is Basic-Auth with no browser session, so flipping
it to read `clinics` would break scoping (the public-API path already derives clinics via the name).

**Editing UI (`/admin/facilities`):** a reusable `ScopePicker` (facility-typeahead XOR group-select) is
wired into all 4 clinic-scope editors. **Facility Groups are managed inline in the Facilities table**
(Type = "Group", name shown as "Helimeds (3 Clinics)") and open in the same right-hand detail pane as a
facility — no separate modal. A sortable **Users** column shows how many users are scoped to each facility
or group. A facility's **Users** section lists API + Clinic Portal accounts (editable) AND the External
Reps / Prescribers who can view that clinic (read-only, noting "via group X" vs "scoped directly"), and an
API account's Display Name (the base64 `customer` header) is editable there. `merge_facility` re-points
group memberships + recomputes affected accounts, so merging duplicate facilities never strands access.

**Prod data migration (run 2026-08-17):** backfill → cleanup → settle → recompute, all `--allow-prod`,
each dry-run/shadow-diffed first. Result: **all 60 clinic-scoped accounts** derive from the registry (47
facility, 13 group; 1,450 group memberships). Cleanup: 5 facility merges, 5 variant registrations, 2 new
facilities, 1 group rename. Recompute shadow-diff = **51 unchanged, 9 gained variant spellings, 0 removed
(0 access-loss)**. A final parity audit confirmed 60/60 cache==scope, 28/28 API name-access intact, 0
empty/broken, 0 webhook under-coverage.

**⚠ The load-bearing gotcha:** `emed_user_clinic` (the normalized webhook mirror) has **ONE writer — the DB
trigger `trg_emed_user_clinic_sync`** (on `emed_user` AFTER INSERT/UPDATE; soft-delete/reactivate/insert,
DISTINCT + NOT-EXISTS guarded). Anything that writes `emed_user.clinics` must NOT also hand-maintain
`emed_user_clinic`, or its reactivation step collides on duplicate rows (err 2601). This cost a 1.0.207 fix
(removed a manual double-write) and a later data purge of the debris the double-write had already left.

---

## 3. Release history + incidents / lessons

- **1.0.205** — both features shipped (facility scope live; portal dark).
- **1.0.206** — ScopePicker group prefill/reset fix (singleton picker showed the prior user's group).
- **1.0.207** — removed `recompute_user_scope`'s manual `emed_user_clinic` write (see the trigger gotcha).
- **1.0.208** — **P0 auth hotfix.** The two `express-session` instances (staff + patient) shared ONE
  `MSSQLStore`; `session()` overwrites `store.generate` with its own cookie config, so the patient session
  (created last) clobbered it and every NEW staff login got the patient cookie (`path:/api/portal`) →
  browsers never sent it to `/api/auth/*` → **staff login broke app-wide from 1.0.205 until 1.0.208**
  (masked by overnight low traffic). Fix: a separate store instance per session. **Lesson: never share one
  express-session store instance across two session middlewares.**
- **1.0.211** — Facilities page enhancements (inline groups in the table, Users column, reps/prescribers
  in the Users section, editable API display-name, UI polish).
- **`emed_user_clinic` debris purge (2026-08-17/18):** the pre-1.0.207 migration recompute had left, for
  ~all 60 migrated accounts, both an active AND a soft-deleted row per clinic (647 soft-deleted rows).
  That made the sync trigger's reactivate step collide on the next `emed_user` UPDATE → **editing any
  migrated account in User Management failed** with "Failed to update user." Fixed by an admin
  `DELETE FROM emed_user_clinic WHERE is_invalid=1` (active rows = the real mirror, untouched; the trigger
  rebuilds from `emed_user.clinics`). Collision-risk accounts 59→0. Not a code bug — residual data.
- **Version collision (1.0.210):** another team cut 1.0.210 for "exship tracking" concurrently; our
  facilities work shipped as 1.0.211 and we restored their overwritten changelog entry. Lesson: version
  numbers are a shared, racy resource — check the remote tag before assuming your patch number.

---

## 4. Design decisions & rationale (for comparison against a plan)

Points most likely to differ from an independent plan, with the *why*:

1. **Derived-cache, not a `facility_id` FK on operational data.** The registry is authoritative; `clinics`
   is a regenerated projection. Chosen to avoid a massive, high-risk migration on the Rx write path.
2. **One typed `FacilityGroup` model, not two.** A rep territory and a partner-company set are the same
   mechanism; `group_type` (free-vocab, no CHECK constraint — avoids a widen-before-deploy landmine) just
   labels *why*. Scope is exactly one facility XOR one group.
3. **Read-side untouched.** `auth.js` (`filter_by_clinic`, `get_user_clinics`, API name-scoping) is
   byte-identical pre/post — only the *content* of `clinics` changed. This is what made "0 access-loss"
   provable and is the core safety argument.
4. **API stays name-scoped.** Non-obvious but load-bearing (Basic-Auth has no session to read `clinics`).
5. **Portal ships DARK + isolated.** Separate cookie, separate session store, separate identity table,
   default-deny per-facility config, kill-switch. The framing/session concessions are portal-scoped so the
   staff app's security posture is never weakened. Enable is a product-owner action (BAA/consent), not code.
6. **Substring clinic matching is unchanged (pre-existing).** `filter_by_clinic` matches case-insensitive
   substrings; the "Valhalla ⊂ Valhalla Vitality Texas" hazard is a *pre-existing* trait, and moving to
   exact-variant matching is a deferred Phase-4 hardening behind a flag — not part of this work.

---

## Where the full detail lives
- Plans: [`facility-scope-groups.md`](../../plans/facility-scope-groups.md),
  [`patient-portal-secure-messaging.md`](../../plans/patient-portal-secure-messaging.md).
- Code (emed_app): `server/facilities.js`, `server/patient_portal.js`, `server/secure_messaging.js`,
  `server/patient_portal_config.js`, `views/admin/facilities.ejs`, `views/moct/visit.ejs`, `app.js`
  (dual session), `public/js/scope-picker.js`.
- Schema (emed_sql): `migrations/applied/2026-08-14_add_patient_portal_and_secure_messaging.sql`,
  `migrations/applied/2026-08-15_add_facility_groups_and_user_scope.sql`, trigger `trg_emed_user_clinic_sync`.
