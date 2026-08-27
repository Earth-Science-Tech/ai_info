---
title: Prescriber & Clinic Portals + Rep Tools — Program (Facilities-Hub model)
slug: portal-foundations
status: In-Progress
project: multi
branches:
  - emed_app: feat/portal-foundations
  - emed_sql: feat/portal-foundations-schema
developers:
  - mario-tabraue
prs: []
tags: []
created: 2026-08-26
updated: 2026-08-26
related:
  - "[[facility-scope-groups]]"
  - "[[patient-portal-secure-messaging]]"
  - "[[per-page-permissions]]"
---

# Prescriber & Clinic Portals + Rep Tools — Program (Facilities-Hub model)

## Status & history
- 2026-08-26 — **Phase-4 live-review round (Mario on the dev slot) shipped.** (1) **Catalog
  Market filter, twice-revised to Mario's spec:** first a single dropdown, then per his review a
  **checkbox MULTI-select** (Human/Veterinary/Misc, all default-checked, Misc labeled "always on
  price lists"); unchecking Misc slims the LIST view only — **generated price lists (PDF + Email)
  ALWAYS carry Misc** (`with_misc` on the server adds it back whatever the client sends; the
  client `confirm()`s "Misc will be ADDED to the list being generated" when it was deselected).
  CSV export stays literal (a data export, not a customer price list). catalog_where market is a
  whitelisted comma-list IN(...). Verified: byte-identical PDFs for market=vet vs vet,misc while
  the literal CSV shows 0 rows; the Design-modal footer explains the filter-drives-the-PDF rule.
  (2) **Transfer portal signing model corrected (Mario): a transfer/central fill is signed by the
  TRANSFERRING PHARMACIST, never a prescriber** — the original prescriber rides the attached
  original-Rx image. **Three pharmacy tiers** (pharmacist_in_charge = manages + submits ·
  staff_pharmacist = submits · pharmacy_technician = prepares, never submits) added to
  PORTAL_ROLES; none is_prescriber (no DEA/NPI/state-licensing surfaces); `can_sign` is the
  submit gate and now also drives the ACCOUNT SHELL (signing tiers → ExternalPrescriber,
  non-signing → ClinicUser). **`roles_for_portal_type()`** = the family switch: pharmacy_transfer
  facilities offer EXACTLY the three pharmacy tiers, everything else the five medical — enforced
  server-side on BOTH admin surfaces (portal My Team + staff Facilities Users card; both UIs
  render the server catalog so their dropdowns followed automatically); last-admin guard protects
  org_admin OR pharmacist_in_charge. create-visit for transfer facilities: "Pharmacist Signature"
  header, pharmacist attestation, "Sign & Submit Transfer" button, transferring pharmacy +
  pharmacist PREFILL from the facility + effective (impersonation-aware) user. Verified live:
  medical_assistant refused 400 at a pharmacy; technician (ClinicUser shell) 403 at /new-visit;
  staff pharmacist submitted visit 1047343 (held by the preclar gate — correct); My Team legend +
  Add dropdown show the 3 pharmacy tiers; test accounts ZZ Technician (142) / ZZ Pharmacist (143)
  left on facility 2 for Mario's review. portal_membership tests updated to the two-family
  catalog (157 green). Commits 6a5d162c / ab8176a3 / 50695731; dev merges 4e7ff600 + 6e6b533e.
  ⚠ OPEN for the review gate: what the GENERATED Rx PDF's prescriber block should show on a
  transfer (today it renders the submitting pharmacist where a prescriber normally sits — the
  legally operative document is the attached original Rx image; decide whether our PDF should
  restyle as a "Transfer Order" naming pharmacist + original-Rx reference instead).
- 2026-08-26 — **Phases 4B/4C/4D built + verified live — PHASE 4 buildable scope COMPLETE,
  awaiting Mario's review gate.** **4B vet intake:** create-visit vet panel (Species*/Owner*/
  Weight, paw-marked, "name = the animal's; contact/address = the owner's"), server-enforced
  400s, patient record carries the animal shape via the A5 seam, Patients page species badge +
  Owner column + vet modal fields; the Rx PDF prints Species/Owner/Weight (verified via
  pdf_html intercept on live visit 1047341, Rex Barker/Dog/Sam Barker/28 kg). **Three markets
  (Mario mid-build):** emed_price_catalog.market = human | vet | misc — misc (Shipping line
  items + Injection Supplies; the IV-Kit rows are IV drug blends and stayed human) visible to
  EVERY portal type; vet facilities see vet+misc, clinics human+misc, **pharmacy_transfer sees
  all three** (get_portal_catalog `@mkt='all'`; verified live: vet=4/clinic=886/transfer=886).
  **4C transfer intake:** portal_type='pharmacy_transfer' requires transferring pharmacy +
  pharmacist + the ORIGINAL Rx image attachment (server 400s verified); provenance rides the
  special-instructions block (visit page + Rx PDF print it); verified live — visit 1047342
  created AND held by the preclar Semaglutide rule, proving transfers ride the same gate seam;
  attachment persisted as Prescription_Attachment; clinic-type regression clean. **4D:**
  (a) Market select on the catalog's New/Edit Product modal + market badge on the list
  (norm_market app vocabulary, no CHECK constraint); (b) **bulk product import** (Mario:
  "import the vet price list when we go live") — POST /api/pricing/catalog/import, server-side
  dry-run drives the preview modal (single source of validation truth), identity =
  (product, strength, size) among active rows -> update merging ONLY the file's columns
  (price-only file safe), else insert; blank price = upon request never zero; rows apply
  through create_catalog/update_catalog so per-field audit lands as UI edits do; Import modal
  on catalog.ejs (SheetJS raw:true, template download, default-market select); verified live
  incl. a full loop: imported vet product -> vet portal picker served it with effective_price;
  (c) **vet special-pricing sheet verified E2E** (draft->item->override 39.99->final on dev;
  vet portal returned special_price=39.99/is_special=1; one-final-per-facility invariant fired
  correctly on the way — sheet 178 stepped aside and fully restored after); (d) **Zoolzy
  toggle (D16)** on BOTH price-list email modals — attaches the recipient's final Zoolzy sheet
  (EXACT business/dba-name or contact-email match only — fuzzy would leak negotiated prices)
  else the shipped Standard Price List via the exported standard_list_pdf; both branches
  verified live (zoolzy_kind=standard_list and =final_sheet). +6 import unit tests (pricing
  129; pricing+zoolzy_pricing 279 green). Commits 723a1840 / ac21ac45 / e8cf38cb on
  feat/portal-foundations. DEFERRED to the review gate: rapid-fire bulk approval (needs
  Mario's spec on who approves what) + the review-gate items carried from Phase 3.
- 2026-08-26 — **Phase 3 review round complete; pushed to origin + merged to dev (preview slot
  live). PHASE 4 STARTED.** Review round shipped: catalog-driven Dosage Form/NDC autofill
  (Liberty drug file via Product Map; catalog wording BEATS Liberty form per Mario), derived Rx
  Quantity (input only for custom drugs), destination-aware shipping in the estimate + quote,
  Units->Quantity relabel, drug-row layout normalization, stale-field reset on drug switch,
  white button text. Full suite 4,038 green pre-push. Phase 4A shipped: emed_price_catalog.market
  discriminator (D15) + moct_person vet columns (patient_kind/species/owner_name/weight, A5
  whitelisted); portal catalog + quote filter by facility portal_type (vet -> 0 rows until vet
  products seeded — verified both ways). NEXT: 4B vet create-visit fields + patients page species,
  4C transfer intake (transferring pharmacist + original-Rx image), 4D vet sheets/Zoolzy toggle/
  bulk approval.
- 2026-08-26 — **Phase 3 Slice E shipped — PHASE 3 COMPLETE, awaiting Mario's review gate.**
  E-1: per-facility page toggles ENFORCED (portal_page_gate: sidebar filter + page routes + all
  10 prescriber APIs; enforcement only when the facility master switch is ON — deploy-safe for
  live prod prescribers; eScript/billing-only = portal on, Orders off = equal service). E-2:
  Liberty Rx history in the patient modal (exact link-based mirror reads) + refill-from-history
  (?mirror= prefill, Product-Map catalog re-link, never materialized). E-3: Messages & Requests
  (A7 threads) — portal page + staff reply panel on the facility page + email heads-up; Special
  Product Requests as a subject_type. Also: delivery-address gate, Portal Admin pseudo-roles,
  My Clinic editing, Liberty seeding (all this session). DEFERRED to the review gate: facility
  logo + Industry News (approval-gated content — spec with Mario), recurring orders, unit suite
  for portal_liberty_seed/page_gate.
- 2026-08-26 — **Liberty mirror seeding shipped** (eMed + emed_sql wip migration
  emed_portal_patient_link): Sync Facility Patients + Sync Facility Prescriptions, per-facility
  (Portal Settings panel) AND all-facilities (toolbar; portal-enabled facilities only). Mirror
  SQL only — zero Liberty REST. Patients ride the upload's dup rules (seed mode: identity
  required, bad optionals dropped); prescriptions = READ-ONLY history via person<->PatientId
  links (hard-match only; existing link checked first). Bugs killed live: VARCHAR PatientId vs
  INT strict compare; link-existence after contact rule. E2E on real data: 282 seeded + 281
  linked at facility 2; portal lists 286. TODO Phase-3 wrap: unit suite for portal_liberty_seed;
  patient-history mirror section + refill-from-mirror prefill (the read-only Rx history surface).
- 2026-08-26 — **Portal Admin pseudo-roles in User Management** (eMed, Mario): 'Prescriber
  Portal Admin' / 'Clinic Portal Admin' in the role picker = machine role + server-written
  org_admin membership across the user's scope (facility/group/legacy-clinics). NOT separate
  roles — membership stays the one tier source. GET /users annotates portal_admin; explicit
  false demotes (prescriber -> primary_prescriber, clinic user -> removed). Page-verified E2E
  incl. demotion.
- 2026-08-26 — **My Clinic in-portal editing shipped** (eMed, Mario): can_edit per facility on
  GET /mine (manage-capable tier at that facility, impersonation-aware); PUT /mine/contact
  (CONTACT_FIELDS widened to 7 contact-class columns — still never type/billing/flags; leads
  re-mirrored) + PUT /mine/address (save_address, ownership-checked, primary honored — feeds
  ship-to-facility). Tier-gated server-side via require_portal_role(can:manage_users).
  Page-verified incl. negative: medical_assistant gets no controls + 403 on direct PUT.
- 2026-08-26 — **Hotfix PR eMed#479 opened** (Mario's call): the ops staff import on main has
  the SAME SheetJS raw:false day-shift found on the portal patient import — license
  issue/expiration dates (the compliance-alert inputs) import silently off by one day. Fix
  mirrors the portal one (raw:true + Excel-serial UTC conversion in ops.coerce_date); ops suite
  90 green. billing.ejs audited: CSV path uses its own parser, unaffected. Nick gates the merge.
  (Noted: main moved to 1.0.229 — the Clinic Info hotfix #476 already shipped.)
- 2026-08-26 — **Patient bulk upload shipped** (eMed, Mario's spec): server dry-run validation
  -> preview -> commit; duplicate = name+DOB+contact match (rejected), review = name+DOB only
  (per-row approval = contact UPDATE of the existing patient); all pictured fields required
  (middle name excepted — flagged for Mario). BUG KILLED: SheetJS raw:false day-shifted ISO DOBs
  ('1975-06-15' -> '6/14/75') — silent wrong DOBs on import; now raw:true + server-side Excel
  serial conversion (UTC math) + numeric-zip leading-zero restore. 13-case unit suite.
- 2026-08-26 — **Phase 3 Slice D shipped** (eMed): /prescriber/patients — list w/ visit
  aggregates, Add/Edit modal (edit reuses the stored external-id suffix so corrections update
  rather than fork), history modal w/ portal-status badges + per-visit clone, start-order
  prefill (?patient=). FIXED IN THE A5 SEAM: upsert_patient wrote non-existent moct_person
  columns (app_user + clinical fields) — every portal patient save was a silent no-op; the seam
  now whitelists real columns and fails loudly. moct_person = identity+contact ONLY; clinical
  data stays per-visit. Also: tracking exports (masked CSV + filter-aware print, search term
  never echoed). REMAINING Phase 3: Slice E (equal-service gating, portal-aware shared pages,
  extras: facility logo / news / special product requests) + recurring orders (assess at review).
- 2026-08-26 — **Phase 3 Slice C shipped** (eMed): /prescriber/tracking — Liberty-mirror order
  tracking (exship overlay, carrier links, variant-deduped clinic scoping) with the A8 two-tier
  read: full rows on-screen (PHI-audited) vs a SERVER-masked print tier (project_rows +
  assert_masked; print fetches fresh, never reuses on-screen rows). Page-verified: 905 mirror
  orders, masked print carries initials only. Also: list Actions column (View/Clone/Refill)
  from Mario's mockup.
- 2026-08-26 — **Phase 3 Slice B shipped** (eMed): portal-status mapper surfaced on list
  (Pending/Prescribed/All tabs) + detail (visit badge, per-rx badges via latest-hold OUTER
  APPLY), Clone Order + per-drug Refill -> create-visit prefill re-linked to TODAY's catalog
  (quote rows supply catalog_id/units; consent never cloned). Page-verified: dev preclar GLP-1
  rules actually held the test visits -> 'In review' badges from real hold data.
- 2026-08-26 — **Phase 3 STARTED — Slice A shipped** (eMed 2df4ecf5 + emed_sql 6243c9c):
  catalog-driven ordering per Mario's directive. pricing.get_portal_catalog (facility-scoped
  effective list: final-sheet price replaces base, proprietary only when sheet-priced,
  upon-request shown), GET /api/prescriber/catalog, server-side re-pricing + immutable per-line
  quote snapshot (NEW TABLE emed_portal_order_quote, INSERT-only, dev-applied wip migration),
  delivery destination (patient|facility|other|pickup), special instructions ->
  moct_special_instructions, live estimated total in create-visit.ejs, clinic-variant dedupe.
  Page-verified E2E: 885-product picker, $130 estimate, visit 1047338 with quote+instructions
  rows. Portal UNITS field is the SKU count for the estimate (Rx Quantity stays free text —
  Liberty container semantics don't apply to portal orders). REMAINING Phase-3 slices:
  B orders split/status-mapper/clone/refill · C tracking+masked mass-print · D patients page ·
  E equal-service gating + portal-aware shared pages + extras (logo, news, product requests).
- 2026-08-26 — **PRE-EXISTING PROD BUG found by Mario's Phase-2 review, fixed on-branch
  (eMed 9dd4ef21):** `views/facility/info.ejs` (My Clinic) rendered "No facility profile found"
  for every SINGLE-facility portal user — the facility selector is only populated for
  multi-facility users, so `parseInt('')` = NaN and `FACILITIES[NaN]` discarded the loaded
  facility. Shipped with the June facility-registry release; affects prod today (nearly every
  ClinicUser/ExternalPrescriber has one facility). Hotfix PR opened at Mario's direction: eMed#476
  (branch hotfix/clinic-info-single-facility off origin/main, cherry-pick of 9dd4ef21) — merge is
  Nick's call as gatekeeper. Verified through the real page for both test users. LESSON RECORDED: API-level
  verification is NOT page-level verification — every user-facing claim must be proven through
  the page in a browser before reporting it works.
- 2026-08-26 — **Shared-service rule (Mario):** Payment Methods / My Clinic / Documents /
  My Team / Messages are FACILITY-relationship services — one canonical portal-aware page + one
  sidebar entry each, never forked per portal (supersedes Phase 3's "dedicated prescriber
  Documents/My-Clinic/Payments pages"). Sidebar dedupe guard committed (eMed) mirroring the
  existing My Team guard. Clinic-portal per-page grid confirmed parity-by-Phase-5 (legacy live
  pages can't take default-deny gating without a backfill; the rebuild replaces them anyway).
- 2026-08-26 — **Directive (Mario): catalog-driven portal ordering.** Prescriber-portal drug
  picker = the Pricing module's facility-scoped effective list (active catalog + facility
  special/proprietary via finalized sheets; "upon request" shown unpriced); estimated per-line
  prices + order total at submission; quote SNAPSHOTTED per line at submit; order history shows
  quoted amounts (all Phase 3). "Pending Billing" review section (quoted-vs-invoiced
  reconciliation) deferred as v2 = first slice of Phase 8 cart/pay-as-you-go. Side benefit:
  portal orders are born catalog-keyed — no reverse drug-mapping at invoicing, vial-size SKU
  picked directly. Plan file Phase 3 amended.
- 2026-08-26 — **Phase-2 review round 2 applied** (eMed 88966d7f + 243260c1): (1) impersonation
  fix — team_ctx/require_portal_role resolved membership via auth.get_user (the REAL admin under
  impersonation, by audit design), so "View as" a Portal Admin could never reach My Team; membership
  RESOLUTION now follows the effective identity while write attribution stays the real admin
  (verified E2E: impersonated org_admin added a Medical Assistant colleague, membership row
  app_user = the real admin). (2) Facilities panel restructured to "Portal Settings" with
  Prescriber Portal / Clinic Portal subsections (clinic-only facilities no longer configure inside
  a prescriber-branded block); same ids, save round-trip verified. Plan v4 amended (Mario, plan
  mode): clinic-portal-only completeness statement in Phase 5 — the clinic portal already OWNS
  Payment Methods/Documents/Visits (the prescriber portal borrows FROM it), equal-service rule
  generalized, clinic per-page grid + storage decision at Phase 5, MOC billing deferred to Phase 8.
- 2026-08-26 — **Phase-2 review round 1 applied** (eMed c0973fbe, emed_sql 5484806):
  `emed_facility.clinic_portal_enabled` — independent per-facility clinic-portal master switch
  beside the prescriber one (panel checkbox; /clinic/* enforcement deferred to Phase 5);
  `can_manage_users` extended to medical_director + primary_prescriber (solo practices);
  attestation HMAC integrity fix (SQL DATETIME truncates ms — zero milliseconds before
  hash+store; verified live on liberty_link_dev: record→verify integrity:true). Localhost
  walkthrough state: facility 1466, prescriber 137 (primary_prescriber, FL/TX, attestations
  complete), user 66 (org_admin, attestations pending). Still awaiting Mario's Phase-2 gate.
- 2026-08-26 — **Phase 2 built** (Facilities-hub management + in-portal delegation) on
  `feat/portal-foundations` @ 7d7b0a0b; **awaiting Mario's Phase-2 review**. The Facilities page
  now carries the Prescriber Portal Settings panel (master/type/channel/enforcement + default-deny
  page toggles, saved with the facility) and a tier-aware Users card: ExternalPrescriber accounts
  create/edit through the structured-scope path (`POST /api-users` extended), portal capability
  tiers + licensed states (moct_prescriber_license reuse via new set_state_list) + staff-side
  attestation record/revoke. New `/prescriber/team` delegation page + `/api/prescriber/team` API:
  can:manage_users tier gate, enforcement-aware attestation gate (ships dark), last-admin guard,
  colleague creation via new `users.create_portal_account`. Group edits re-sync group-materialized
  memberships. Page fully registered (page_catalog/REQUIRES/nav/sidebar; registry check green,
  118 pages). +10 delegation-authz tests; suite 3,968 green. No schema change (rides Phase 1).
- 2026-08-26 (later) — **Phase-1 review round 1** (Mario): four directives folded in, commits
  eMed 0ca5c29c + emed_sql df5cb1d (both dev-applied).
  (1) **Patient model DECIDED**: each facility owns its patient records; the same human exists
  as separate rows per facility BY DESIGN (already structural via clinic-namespaced
  external_id); within one facility the clinic + prescriber portals share the same rows via the
  A5 seam; cross-facility visibility NEVER surfaces provider-side; an INTERNAL-ONLY identity
  link (Nick's patient_portal_person junction) serves pharmacy safety + the patient portal —
  confirm junction privacy in the D14 conversation. Intra-facility dedup/merge (two channels
  minting two rows for one person) lands in Phase 3 patient management.
  (2) **Group memberships**: external prescribers may be granted facility GROUPS —
  emed_portal_membership.source_group_id + assign_group_membership/recompute_group_memberships
  (materialized per-facility rows, provenance-tagged, re-synced on group edits).
  (3) **Licensed states**: REUSE the existing moct_prescriber_license store +
  /admin/prescriber-licenses (works for external prescribers as-is — no new table). Onboarding
  (Phase 6) and the Facilities hub (Phase 2) must capture states into it. New
  portal_channel_suggest.js: patient state outside the prescriber's active unexpired Medical
  states -> RECOMMEND the Clinic Portal (advisory, never a block; no rows yet -> no redirect).
  (4) **Phase-5 scope change**: the email-the-patient questionnaire dispatch (+ patient-portal
  link) is ON HOLD per Nick. INTERIM RULE: every clinic-portal submission REQUIRES a manually
  uploaded Medical Questionnaire (MQ) attachment at creation until the dispatch feature rolls
  out. D18 -> HELD.
  Also: session re-anchored into the eMed project; both worktrees re-verified current with prod
  (origin/main = 1.0.228, 0 behind, both repos). Suite: 3,957 green.
- 2026-08-26 — Phase 1 (Foundations A1–A9) built on `feat/portal-foundations` @ 924df669 +
  `emed_sql feat/portal-foundations-schema` @ 136e15e; **awaiting Mario's Phase-1 review**.
  Decisions locked with Mario: D21 = NEW `emed_portal_thread`/`_message` (not
  moct_secure_message); backfill tiers = ExternalPrescriber->primary_prescriber,
  ClinicUser->medical_assistant; A4 enforcement = per-facility flag, DEFAULT OFF (ships dark).
  Shipped: migration `2026-08-26_add_portal_foundations.sql` (wip/, **dev-applied**, drift-clean:
  5 tables + 4 emed_facility columns) · `portal_membership.js` (tier catalog +
  require_portal_role) · `prescriber_portal_config.js` (patient-portal config clone +
  portal_type/submission_channel + GET/PUT on route_facilities) · `portal_attestation.js`
  (HMAC artifacts; create_external_prescription now persists the submission attestation) ·
  `portal_status.js` (derived 7-status mapper) · `portal_patients.js` (resolver seam) ·
  `portal_masking.js` (tiered projection) · `portal_threads.js` (the one primitive) ·
  `Write_Portal_Memberships` flag + PERM_SCHEMA_VERSION 4 · `scripts/portal_membership_backfill.js`
  (dry-run default; NOT yet run with --apply). 133 new unit tests; full suite 3,947 green.
  **A9 conventions** (standing rules for every later phase): store code WITH text
  (RxNorm/SNOMED/NDC) on new clinical fields · identity split practitioner/role/organization
  when identity tables land · structured per-state expiring credentials · append-only clinical
  records (amend, never mutate) · tenant key (facility_id) on every new row · PHI audit on reads
  AND writes via log_phi_access.
  Notable: an abandoned May wip draft (`2026-05-12_add_emed_messaging.sql`, `emed_message_*`)
  exists parked — no collision with `emed_portal_thread`; flag to Nick before anyone revives it.
- 2026-08-26 — Not Started → In-Progress (mario-tabraue) — Plan v4 approved (Mario's consolidated
  v3 revised per Nick's Facilities-Hub directive, received 08-26). **Phase 0 (corrections &
  de-risking) executed** on `feat/portal-foundations` @ 1.0.228 base: stale "parked in wip"
  header fixed on the applied facility-groups migration; routing path verified (`emed.select_pharmacy`
  IS `pharmacy_routing.select_pharmacy` — re-exported at `emed.js:15`, so the external flow already
  uses the DB-driven module; no code change needed); **signature dual-spelling normalized** behind
  shared accessors `emed.get_user_signature` / `emed.get_visit_signature` + `SIG_INFO_USER`/`SIG_INFO_VISIT`
  constants (read sites consolidated in `emed.js`, `external_order_worker.js` — which previously
  checked only one spelling — `route_prescriber.js`, `route_moct.js`); CLAUDE.md #44 (facility
  groups) + #16 signature-accessor note added. Full suite green (3878 passed; only the
  pre-existing environmental `webhook_crypto` failures). Awaiting Mario's Phase-0 review before
  Phase 1.

## Summary

One coherent, staff-controllable portal program: the **Facilities registry is the source of truth**
for who belongs to a facility, what capability tier they hold, and which portal features that
facility has. Prescriber Portal (three `portal_type`s: human/clinic · vet · pharmacy-transfer),
Clinic Portal (MOC-serviced: manual entry + JSON-payload intake, Form-Builder questionnaires
emailed to patients), universal rep-gated onboarding, Rep Tools completion, vet pricing line
(+ Zoolzy price-list share toggle), collections/cart/MOC-cutover later. Never rebuilds what
shipped: facility groups, per-user scope, the preclar gate, the per-facility config pattern, the
working prescriber portal.

## Phases (dependency-ordered; each ships dark/default-deny)

| Phase | Content | State |
|---|---|---|
| 0 | Corrections & de-risking (migration header, routing verify, signature accessor, docs) | **done, in review** |
| 1 | **built, in review** — Foundations A1–A9: migrations (`emed_portal_membership`, `prescriber_portal_page_config`, `emed_portal_attestation`, facility columns) · `portal_role` tiers · per-facility config clone · attestation persistence · patient resolver seam · status mapper · messaging primitive (D21) · masking + `external_patient_ref` · EMR-ready conventions | in review |
| 2 | ★ Facilities-hub user/prescriber management + in-portal delegation (Nick's core ask) | built, in review |
| 3 | Prescriber Portal to parity (order flow through preclar gate, clone/refill, patient mgmt, dedicated views, eScript equal-service) | built, in review |
| 4 | Vet + Pharmacy-Transfer types + vet pricing line (catalog discriminator, Product-Map matching, Zoolzy toggle) | built (bulk approval deferred to review gate) |
| 5 | Clinic Portal (MOC pipeline; reuse Patient Portal magic-link for questionnaires) | |
| 6 | Universal Onboarding (rep-gated; payment-before-activation; send-to-us patients; drug selection → questionnaire + alias map) | |
| 7 | Rep Tools (consolidation, `Resubmit_Rx` for SalesRep, resubmit defect trio, preclar follow-up consumers, lead-side territory, order sets, intelligence) | |
| 8 | Collections · Cart · MOC integration + MyScriptOrders cutover · EMR activation | |

Authoritative plan text: Mario's approved v4 (plan mode,
`~/.claude/plans/check-all-the-pre-clarification-logical-fox.md`) — Nick's revision
(“Facilities-Hub model”, 08-26 email) is its spine. Open decisions tracked there
(D-A2 membership table · D14 patient contract · D17 portal_type ownership · D18–D20
clinic-portal fill-ins · D21 messaging · D22 EPCS/regulatory).

## Known defects/debt carried (not this program's causing, tracked here)
Resubmit reject-clone landmine · `release_hold` lacks pharmacy-eligibility re-check on resubmit
clones · override-on-unconfirmed unreachable from ResubmitModal · preclar aging-escalation +
threshold-breach consumers unbuilt · `/api/clarifications/:pharmacy/patient/:id` GET/PUT
ownership gap · `python/Patients.csv` PHI in repo.
