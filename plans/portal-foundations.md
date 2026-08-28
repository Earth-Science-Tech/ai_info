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
- 2026-08-27 — **"All" tab now means ALL** (commit 64ed4391; dev merge 4889877f; Mario's
  follow-ups to the tab arithmetic). All merges THREE kinds: visits + the team's
  awaiting-approval queue (badge "Pending Prescriber Approval", drafted-by, Review action =
  the same dr_modal) + MY personal drafts (badge "Draft", Resume action `?draft=`). Pseudo-rows
  carry the exact visit-row key set (gen_datatable derives the header from the FIRST row's
  keys). Count = visits + queue + drafts, re-rendered when the async draft lists land.
  Verified live: All = 14 = 8 + 5 + 1, review popup opens from inside All. ⚠ LESSON: an
  earlier verification pass read ALL ZEROS and looked like a regression — **the impersonation
  had EXPIRED mid-check** (session fell back to the clinic-less localhost admin). Impersonated
  browser checks must re-impersonate and assert IN ONE flow.
- 2026-08-27 — **'Pending' tab → 'In Review' + every visit bucketed** (commit 91c6ac77; dev
  merge f6972bd4). Mario asked twice what the Pending tab was for — two real defects behind the
  confusion: (1) its member set carried **'Draft', dead code** (nothing ever sets the is_draft
  flag), and the name collided with 'Pending Prescriber Approval'; renamed **In Review** =
  In review / On hold / Attention needed (submitted, not yet moving at the pharmacy). (2)
  **drug-less MOC visits (Received / Pending Consultation / Missing Forms) mapped to NO portal
  status** and fell out of every tab — Mario caught the arithmetic (All 8, tabs 7). They now map
  to 'In review' (they ARE with our medical team); other drug-less visits keep the raw-status
  fallback. Verified on the screenshot's own data: 1 In Review (1047512) + 7 Prescribed + 0
  unbucketed.
- 2026-08-27 — **SIGNUP WIZARD PRODUCT PICKER (Mario's directive on the 5C seam)** (commit
  e29532f4; dev merge 1125541f). The clinic fork's "What are you looking to order?" free-text
  box is now a real picker over the price catalog — **category → subcategory → products,
  SELECT-ALL at every level** (tri-state parents), filter box, running count. Prescriber-only
  signups keep the free text. Tree = ACTIVE catalog, **names only** (no prices on an anonymous
  surface), vial ladders deduped by (product, strength) — an interest list picks PRODUCTS not
  SKUs; token-gated `POST /api/public/portal-signup/catalog`. **Stored TWICE on purpose:**
  structured `{catalog_id, name}` pairs in `answers_json` — **the exact input the 5C
  questionnaire mapping (emed_product_required_form keyed catalog_id) will consume** — plus a
  human-readable `products_interest` summary COMPOSED SERVER-SIDE from the structure so the two
  can't disagree. Verified through the real wizard: clinic invite → 24 categories, category
  select-all + 1 individual = 8 selected → review listed them → stored summary + 8 structured
  pairs (first: catalog_id 784). ⚠ vitest footnote: asserting "no prices in the query" via
  /price/i matches the TABLE NAME emed_price_catalog — assert on the price COLUMN names.
- 2026-08-27 — **PHASE 7 E3+E4+E5+E6 SHIPPED — the phase's build items are COMPLETE** (E3-E5
  commit 709cb05b / merge 348a7839; E6 commit e975ffe7 / merge fbac59de; E7 leads-slice
  extraction stays the designated slack-week item). **E3 My Facilities** (`/rep/facilities`):
  territory facilities (paged — 890 for the test rep) with portal state, payment-on-file,
  linked-lead status + invite-to-portal for portal-less facilities;
  `GET /api/facilities/rep/territory` registered BEFORE '/:id'. **E4 My Patients**
  (`/rep/patients`, new `/api/rep` router) — the A8 tiers as built: **masked LIST, audited
  unmasked own-scope DETAIL** (each open writes a PHI audit row; out-of-scope 404s with NO
  audit row). ⚠ TWO MASKING GAPS found while verifying: **`external_patient_ref`/`external_id`
  EMBED First-Last-DOB for portal-created patients** (fine as the owning clinic's record key on
  exports; decorative-mask-defeating on a rep bulk list — DROPPED on this surface, numeric id
  is the handle) and **`owner_name` was unmasked** (on a vet record the name fields are the
  ANIMAL's but owner_name is the HUMAN — added to PHI_FIELDS). **E5 Order Sets**
  (`/rep/order-sets` + `emed_order_set`/`_item`, migration `2026-08-27_add_order_sets.sql`
  dev-applied **PENDING PROD**): reps propose per-facility drug bundles, staff approve
  (**Write_QuickAdds — a rep can never approve their own**; claim-first transitions IN the
  UPDATE; approved/rejected frozen — edit = clone, the price-sheet lesson), and the portal's
  create-prescription page grew an "Apply an order set" control that prefills **through the
  SAME `fill_drug_rows` loop clones/drafts use** — pricing/validation/preclar all run normally;
  a set is a prefill, never a bypass. E2E verified: rep 58 → "GLP-1 Starter Bundle" →
  staff approve → prescriber 144's form applied both drugs+sigs. **E6 order→lead intelligence**
  (`server/order_lead_intel.js` + nightly `order_intel_cron`): `total_orders`/`last_order_date`
  refresh from the **Liberty MIRROR** (`<pharm>_rxqFullOrder`, 9999-sentinel excluded) —
  never the live API — resolved through **`emed_facility_name` (THE alias consolidation)**,
  variants summing per facility, unlinked leads exact-match only, NO fuzz (unmatched volume
  logged, never guessed). Updates touch ONLY the two columns — **never `date_modified`** (it
  orders the CRM list). Proven on dev's real mirror: 1,655 clinics → 1,642 facilities, 1,505
  leads updated, 11 unmatched (93 fills, junk names); top lead (Valhalla, 55,715 fills)
  hand-recounted EXACT. The manual `/import-order-data` CSV loop is superseded for the two
  order columns (endpoint stays for business-status transitions). Suite 4096; registry 129
  pages. ⚠ PROD env on promotion: nothing new (cron is always-on off-localhost; ships dark
  without mirrors).
- 2026-08-27 — **PHASE 7 E1+E2 SHIPPED** (commit 9c84e1f6; dev merge 3a61f0e7; migration
  `2026-08-27_add_group_sales_team_code.sql` = 2 additive columns on `emed_facility_group`,
  dev-applied, **PENDING PROD**). **E1 lead-side territory:** `sales_team_code` (maps a sales
  group to `emed_crm_lead.sales_team` — ONE territory, two sides, one source of truth) +
  `company_email`, editable on the group modal. **`server/rep_territory.js`** resolves
  FAIL-CLOSED (staff = View_Menu_CRM/Write_CRM pass-through; narrow-flag rep = their group's
  code; no group/code/login/any error = NOTHING). New narrow flag **`Write_Rep_Leads`**
  (ExternalRep; NEVER Write_CRM — the asymmetry is the point) accepted at the FOUR lead
  handlers: list (forced WHERE + `territory_empty`), read (out-of-territory 404), create
  (**sales_team STAMPED, client value never trusted**), update (404 fence + sales_team
  immutable). The per-page WRITE framework holds too: RepLeads carries a write gate and the
  two lead mutation routes map `[CRMLeads, RepLeads]` (the write gate passes on ANY mapped
  page's flag). **E2 rep lead view + signup front door:** `/rep/leads` (section 'reptools',
  top of the hub) — territory list, minimal detail, **Invite to Portal** = the Phase 6 invite
  prefilled with facility/email/crm_lead_id (the locked rep-gated entry). ExternalRep gains
  Write_Rep_Leads + Write_Portal_Signups in code; approve stays staff. ⚠ **TWO OF MY OWN BUGS
  CAUGHT ONLY BY THE LIVE WALK:** (1) `rep_territory` read the RAW SESSION — under View-As
  that's the ADMIN, so the admin's perm decided "staff" and the admin's login resolved the
  territory (impersonated rep listed zero leads; a rep-created lead kept its client-chosen
  team). Fixed with `auth.get_permissions`/`get_effective_user` — **any scope resolver MUST use
  the impersonation-aware accessors.** (2) an edit batch ABORTED at a failed anchor assert
  after its first section, silently leaving five later edits unapplied while `node --check`
  passed on the UNMODIFIED files — **batch edit scripts are now per-section independent.**
  Also: `GET /api/crm/leads` responds `{rows}` not `{leads}` (cost one false-negative fence
  walk). Verified live as ExternalRep 58 (group 9 = GCC): 17 leads all GCC, own r/w 200,
  territory move blocked, foreign read AND write 404, created lead stamped GCC despite
  claiming ETST, page renders + invite returns the one-time link. Suite 4071; registry 126.
  **REMAINING Phase 7: E3 My Facilities, E4 territory patients, E5 Order Sets, E6 order→lead
  intelligence, E7 leads-slice extraction (slack-week item).**
- 2026-08-27 — **PHASE 7 STARTED — E0 SHIPPED** (commit 6f4c2c9c; dev merge e4b6aa1a). **Q-HOUSE
  DECIDED (recommendation a):** the Rep Tools heading renders for HOUSE reps too — predicate
  `View_Menu_Rep_Tools && (is_clinic_scoped || !View_Menu_Admin)` (the compound route_clinic
  trick; Admin holds every flag by design). Hub = Held + eMed Orders + Script Search +
  Clarifications + My/Lead Tasks + **Special Pricing (MOVED out of the Pricing heading for
  rep-home viewers)**. EXTERNAL reps: scattered links MOVED into the hub; HOUSE reps: hub in
  ADDITION (eMed muscle memory). ⚠ Tasks MOVES for both — the My/Lead Tasks badges are DOM ids
  and must render once per viewer. SalesRep() gains View_Menu_Rep_Tools in code;
  **Resubmit_Rx = a UI grant on the SalesRep custom-role row (dev applied; PROD row needs
  View_Menu_Rep_Tools + Resubmit_Rx + Write_Portal_Signups on promotion)**. Verified live:
  pure SalesRep user 99 = full hub incl. eMed Orders; multi-role user 51 correctly EXCLUDED
  (holds View_Menu_Admin); ExternalRep 58 = consolidated hub. **THE RESUBMIT DEFECT TRIO —
  investigated (all three confirmed with exact mechanisms) and FIXED:** (1) **reject-clone
  landmine** — a rejected held clone stayed live (no script_created, no OPEN hold ⇒ redrive
  candidate; the gate re-evaluates prior='rejected' fresh; corrected fields often no longer
  fire ⇒ a human-REJECTED prescription could reach the pharmacy and supersede a possibly-
  dispensed parent; also bricked the parent's resubmit forever). reject_hold now soft-deletes a
  never-sent clone + its ledger row (the 12c cleanup); ordinary holds and pharmacy-reached
  clones untouched. (2) **release_hold never re-ran the pharmacy-eligibility check** — a clone
  held for days could submit after the pharmacy dispensed the PARENT. Release now re-runs
  rx_resubmit.check_eligibility on the PARENT row (its rx id is the pharmacy's tag), clones
  only, after the rule re-gate and BEFORE the ledger/flip — refusal leaves the hold OPEN;
  fail-closed on Liberty errors with the existing override escape hatch. (3) **override-on-
  unconfirmed unreachable from ResubmitModal** — endpoint accepted override_reason, modal never
  collected it; prefill now returns can_override, the banner grows the reason input, the 409
  keeps the modal open. **THE TWO PRECLAR CONSUMERS** (`server/preclar_alerts_cron.js`): aging
  escalation (holds open > PRECLAR_AGING_DAYS, default 3) + rule threshold breaches computed by
  **preclar.run_discovery — the SAME evaluator production uses** (7-day window, parent
  population denominator; each check persists a discovery run as the alert's evidence). One
  daily digest to PRECLAR_ALERT_EMAIL; dormant unset; NO quiet-day email; localhost-guarded.
  ⚠ PROD ENV on promotion: set PRECLAR_ALERT_EMAIL. Tests: +8 trio regressions (preclar 69),
  preclar_alerts_cron (8); suite 4063 green. NEXT in Phase 7: E1 lead-side territory
  (`Write_Rep_Leads`), E2 external-rep lead view + signup-link generation (Phase 6's front
  door), E3 My Facilities, E4 territory patients, E5 Order Sets, E6 order→lead intelligence.
- 2026-08-27 — **PHASE 6 SHIPPED — Universal Onboarding** (commit 3d32573f; dev merge 48701e89;
  migration `2026-08-27_add_portal_signup.sql` = `emed_portal_signup` + `emed_portal_signup_token`,
  dev-applied, **PENDING PROD**). One dynamic flow, three forks, all the locked 2026-08-07
  decisions: **rep-gated entry** (new flag `Write_Portal_Signups` on Admin/SuperUser/SalesRep —
  ⚠ also added to dev's migrated SalesRep `emed_custom_role` row, the DB list being
  authoritative; **prod's row will need the same on promotion**), **rep confirms before
  provisioning** (submitted → rep_confirmed is a mandatory step; approve refuses anything else),
  **payment-before-activation** (provisioning creates facility + portal config with MASTERS OFF
  + pages preset ON + org-admin account + emails the EXISTING payment-capture link; a
  fire-and-forget hook in `route_payment_capture.run_submit` calls
  `portal_signup.activate_on_payment(facility_id)` when a method lands → masters flip ON; staff
  keep an explicit Activate-now override), **patient list = send-to-us** (a promise checkbox,
  never an upload). Lifecycle: invited → submitted → rep_confirmed → provisioned → active |
  rejected. Tokens = the Zoolzy bearer discipline verbatim (SHA-256 at rest, fragment-riding,
  single-success, attempt-capped, REDACTED from the persisted email). **Provisioning is
  CLAIM-FIRST from birth** (the same-morning approval-race lesson: one conditional UPDATE flips
  rep_confirmed→provisioned before the slow work; failure rolls back). Provisions via the
  existing primitives ONLY: save_facility + primary address (**the address STATE feeds the
  capture link's pharmacy routing**), set_facility_config, emed_user shell (ExternalPrescriber /
  ClinicUser; ⚠ `emed_user` has a trigger → SCOPE_IDENTITY not OUTPUT, the emed_email lesson),
  set_user_scope, membership tier (primary_prescriber / org_admin / pharmacist_in_charge — a
  Pharmacy-type signup also gets `is_fulfillment_pharmacy=0`, identity drives the transfer
  realm), house temp-password welcome email. Surfaces: public wizard `/portal/signup#token=…`
  (4 steps, fork cards preset from the invite, honeypot answers a plausible 200, X-Requested-With
  from the page's own JS — the zoolzy-apply CSRF pattern, NOT a WEBHOOK_PREFIXES entry) + staff
  queue `/admin/portal-signups` (pills, invite modal showing the link ONCE, per-status actions).
  All registries updated in one pass (page_catalog entry + REQUIRES + WRITE_CAP + nav + sidebar
  heading/section-links — the review-pass lesson applied). ⚠ **CAUGHT ONLY BY WALKING THE REAL
  UI (third time today): the submit button's id `ps_submit` SHADOWED the same-named function in
  inline-onclick scope** — every API test passed while the wizard's submit threw; renamed
  `ps_send`. Also: a same-URL hash navigation never refetches the document (browser retest needs
  location.reload). E2E verified live BOTH ways: API lifecycle (invite→…→active, token dies on
  first submit, re-activate 409s) AND the browser wizard + queue (Browser Walk Clinic → facility
  #1961 / user #148, Awaiting payment). Suite 4048 green; registry 125 pages. **Deferred within
  Phase 6:** clinic drug-selection → questionnaire-linked offer list (blocked on the 5C answers
  from Nick/Carlos — the wizard collects free-text products-of-interest meanwhile). **GROUPED
  WITH THE 5C PROPOSAL (Mario, same day):** the wizard's offer-list step reads the SAME
  `emed_product_required_form` mapping as the clinic-intake trigger, so the `catalog_id`
  mapping-key decision now has TWO consumers — addendum emailed to Nick + Carlos so it gets
  settled ONCE, not re-decided per consumer; rep
  signup-link generation from the REP portal is Phase 7 E2 (staff/SalesRep invite ships now).
  Recurring sidebar merge conflict (dev's ClinicProducts vs this branch's new links) converged by
  carrying ClinicProducts on the branch.
- 2026-08-27 — **REVIEW PASS over the day's ~3,500 lines: 15 confirmed defects fixed** (commit
  a62dd244, dev merge 92309db3). Three adversarial reviewers (security / correctness /
  front-end); everything verified against the running app. **Money/safety class:** (1) **double
  -submitted prescriptions** — approve-batch was read-check-then-act around a seconds-long
  replay, so two overseers each minted a visit AND a pharmacy submission for the same draft;
  now **claim-first** (`claim_for_approval`, one conditional `pending->approving` UPDATE, the
  loser told "already being approved"), with `mark_failed` RELEASING back to pending. Verified:
  approve #1 → visit 1047513, #2 refused. (2) **second visit on a 502** — visit created + send
  failed left the draft pending, and a retry replayed the whole handler; a 502 now consumes the
  draft against that visit and reports `send_pending` (the outbox owns delivery). (3)
  **cross-territory message read** — `GET /:id/threads` was widened to PM_READ without
  inheriting `message_scope`. (4) **Transfer Order lost on Edit & Resend** — `rx_resubmit`
  regenerated from a bare `get_visit`, so the corrected doc lost the banner, the pharmacist box
  and **the embedded original prescription**; both regen paths now load the same persisted
  context `redrive_unsent_scripts` uses. **Silent data loss:** news tiles were **unpublished by
  merely opening the admin page** (the auto thumbnail backfill posts a partial body and the
  UPDATE rewrote every column — now omitted-means-unchanged); the portal-config **scalars** were
  still unsafe on a partial PUT (the grid hardening covered only the grids — a vet facility
  could silently lose its intake rules); `import_catalog` **re-marketed vet/misc products to
  human** on a plain price-refresh import (default now applies to INSERTS only — the existing
  "merge only what the file carries" test asserted `category` and never `market`, so it passed
  over the bug); **Resume Draft came back nearly empty** (passed `{drug}` to `apply_clone`,
  which reads `c.drugs` and re-set every patient field from its own empty input; drug rows are
  now one shared `fill_drug_rows()` and resume restores clinic → fields → destination →
  shipping in dependency order). **Injection:** new **`misc.clean_base64`** (strip + charset
  gate) on the logo, news doc/thumb and Rx attachments — those bytes are interpolated into HTML
  (admin preview, Transfer Order, Rx); `fail_reason` sat inside `title="…"` and the house
  `escape_html` does NOT escape quotes. **Attestation integrity:** the rapid-fire selection was
  never pruned on reload, so a withdrawn draft stayed in the POSTED set while the signed list no
  longer showed it. ⚠ **TEST DEBT FROM EARLIER TODAY — 16 unit tests were already red before
  this pass, and one was a live crash: `permissions.js` `CustomerService()` had a TDZ throw**
  because my Portal Messages flags were spliced ABOVE the `ret` declaration (and the union loop
  would have discarded them anyway) — **every CustomerService permission lookup threw, already
  merged to dev**. Also: the three new pages were never registered in `REQUIRES`/`WRITE_CAP` and
  the sidebar's eMed heading/section-links lists never learned about them (a page-level grant
  produced a page with no link); the Rx banner tests asserted the pre-logo `<div>`. **Suite now
  4029 green (from 16 red), registry green.** New `tests/unit/server/portal_clinic_scope.test.js`
  (9) pins the shared resolver. **LESSON: run the full unit suite before merging, not after a
  day of merges** — the crash and the registry gaps were all catchable at commit time.
- 2026-08-27 — **5C questionnaire coordination note SENT** to Nicholas Cardell + Carlos Obregon
  (cc Mario) from the app mailbox, per Mario. Key finding that shaped it: **Mario's proposal —
  a link to the patient's own portal — is ALREADY BUILT by Nick** (dev, 8/24–8/25 Peak Now
  workstreams): `server/product_required_form.js` (product→form mapping + `recency_months`,
  `resolve_required_forms`, `due_forms_for_person`), `/admin/clinic-products`, the **'Missing
  Forms'** visit flag, a **PHI-free secure message pointing at the portal**, the patient-portal
  **Intake Forms** page, and the iframe/SSO handoff (dark). **THE GAP: the trigger is wired only
  into `wc_ingest`** (the Woo/PeakNow path) — Phase 5's two clinic channels
  (`POST /api/clinic/create-visit`, `POST /api/public/moct/visit`) never call it. Proposal sent:
  lift the trigger into one shared `trigger_for_visit()` called by all three channels; **add a
  `catalog_id` mapping column** because the mapping is keyed on `wc_product_id`/`wc_sku` while a
  clinic-portal order is catalog-keyed (name-matching across a vial ladder is where auto-pricing
  got burned); and decide the fallback for clinic facilities **without** the patient portal (the
  notifier requires its Messages page enabled and otherwise sends nothing). Blocked on their
  answers before building 5C.
- 2026-08-27 — **PHASE 5 DECISIONS ANSWERED (Mario) — and most of the phase turns out to be
  ALREADY BUILT.** D20 questionnaire delivery: **reuse the Patient Portal magic-link method —
  NICK IS BUILDING IT**, and the questionnaire↔drug/product MAPPING lives on a **"Clinic
  Products" page already in progress on another branch**. So the mapping + delivery are NOT
  mine; do not build them (collision risk is `page_catalog.js` + `sidebar.ejs` when his branch
  lands, both mergeable). D18 dispatch states: MOCT visits arrive **'Received'**, staff review
  and move them to **'Pending Consultation'** for a prescriber — an EXISTING status vocabulary,
  nothing new to model. D19 partner JSON: **Helemeds already uses `POST /api/public/moct/visit`
  and its payload** — no new contract. **VERIFIED both intake channels already agree:**
  route_clinic's manual `POST /api/clinic/create-visit` sets `status = 'Received'` + a
  moct_visit_history row, and route_public's partner endpoint sets `'Received'` too — so
  "two intake channels → one MOC pipeline" is essentially shipped. **5B FIX (found by actually
  running the manual channel as a ClinicUser):** the submit failed with *"Clinic selection is
  required"* because `emed_user.clinics` holds NAME STRINGS and one facility often owns several
  variants ("1st Aid Station Medical Clinic LLC." + "First Aid Station"); route_clinic used the
  naive `clinics.length === 1 ? auto : demand a pick`, so a user belonging to ONE facility could
  not submit at all. ⚠ **This is the SAME defect Mario hit on the prescriber portal and I fixed
  there — it survived here because the fix lived inside that router.** The variant dedupe now
  lives in ONE place, **`server/portal_clinic_scope.js`**, and route_prescriber's local copy
  delegates to it. Verified: ClinicUser submit → visit 1047512, status Received, clinic stored
  as the facility's PRIMARY name, history row written. Commit f00bdf38; dev merge cb9f901c.
  **REMAINING Phase-5 work is Nick's questionnaire branch**; when it lands, add a
  `clinic_products` key to CLINIC_PAGES so the facility can toggle that page too.
- 2026-08-27 — **PHASE 5 STARTED — 5A shipped: Clinic Portal per-page grid + equal-service
  parity.** ⚠ **STORAGE DECISION (the plan left it open): the clinic grid REUSES
  `prescriber_portal_page_config` with `clinic_`-PREFIXED page keys**, not a second table —
  that table is already a generic per-(facility, page_key) toggle store, and a parallel one
  would duplicate the loader, the TTL cache and the panel code for nothing. `CLINIC_PAGES` =
  visits · tracking · documents · payments · threads · news; **My Clinic is deliberately NOT
  toggleable** (facility-relationship service, always available — the shared-service rule).
  `portal_page_gate` gained `effective_clinic_pages()` + `require_clinic_page()`, governed by
  `clinic_portal_enabled` with the SAME deploy safety as the prescriber side (an unconfigured
  facility keeps today's behavior, so no live clinic portal darkens on deploy day); the writer
  keeps omitted-means-unchanged for BOTH grids (this morning's blackout lesson). Facilities
  panel: clinic grid under the Clinic Portal subsection, saved with the facility Save, verified
  independent of the prescriber grid (8/8 prescriber flags untouched). **EQUAL SERVICE:** the
  Clinic Portal section now borrows **Order Tracking, Messages and Industry News** — exactly ONE
  sidebar entry each however many portals a facility runs, skipped when the prescriber section
  renders them; ungoverned facilities get the full set. Order Tracking is now reachable by
  clinic-portal users (ONE canonical page, portal-aware: page + API gates widened to accept
  View_Menu_Clinic_Portal, data still clinic-scoped, requires map updated so the registry stays
  green at 124 pages). ⚠ PROCESS: an earlier verification run silently tested the ADMIN session
  because the old ClinicUser test account had been deleted in the dev refresh — the impersonate
  call 404'd and I only caught it because the status was printed. Re-run as a REAL ClinicUser:
  clinic_news OFF ⇒ /prescriber/news 403 while tracking + messages 200, tracking API returned
  905 clinic-scoped orders, sidebar = Visits · Clinic Info · Prescriptions · Payment Methods ·
  Documents · Order Tracking · Messages & Requests · My Team, no news link. **ALWAYS assert the
  impersonation succeeded before trusting a scoped test.** Commit c81d269f; dev merge 09128a70.
  **NEXT (needs Mario): the Phase-5 intake body — D18 dispatch flow states, D19 partner JSON
  contract, D20 drug↔questionnaire model.**
- 2026-08-27 — **PORTAL MESSAGES page (cross-facility queue) — reps first.** Mario: facility
  messages were reachable only by expanding ONE facility at a time on the Facilities page,
  gated on `Write_Facilities` (the facility-ADMIN permission), with **no cross-facility view and
  no unread count anywhere** — the only real notification was the support@ mailbox. New page
  **`/portal-messages` under EMED** (Mario's placement) following the Clarifications-SMS pattern:
  every conversation in one queue + status/unread filters, reading pane, reply/close, and a red
  **sidebar badge** polling the unread total. No schema change — threads + read tracking already
  existed; `portal_threads` gained `list_threads_all()` / `unread_total()`. **ACCESS (Mario's
  correction — "reps are the most important and should be first to see", then "sales reps should
  see all… external reps have limitations"):** SalesRep sees ALL (exactly like their CRM access);
  **ExternalRep sees ONLY assigned clinics** and another territory's thread **404s on read AND
  reply** (404 not 403 — never confirm it exists); MOCT/Clarifications/CustomerService see all;
  all of it split from `Write_Facilities` so message workers gain no facility-edit/portal-settings/
  merge rights. ⚠ **The "sees everything" capability is its OWN flag `View_All_Portal_Messages`,
  deliberately NOT `View_All_Clinics`** — SalesRep holds that for CRM, so reusing it would have
  leaked every facility's conversations to any rep; without the flag the queue narrows to
  assigned clinics and an UNASSIGNED user sees NOTHING (fail closed), never a silent fallback to
  everything. ⚠⚠ **MAJOR FINDING — dev's built-in roles are MIGRATED to DB-defined custom roles**
  (`emed_custom_role` holds MOCT, SalesRep, Clarifications, CustomerService, Billing, Peaks,
  Pharmacy, Shipping, ITSupport, Prescriber, SuperUser, plus ACQ/CEODash/Operations/…). For those
  roles **the stored permission list — not the code factory — is authoritative**, so a NEW code
  flag grants NOTHING until it is added there: the first test showed SalesRep with zero access
  while `permissions.SalesRep()` reported the grant, and `union_permissions` took the CUSTOM
  branch. ExternalRep is still a code role, which is why ITS code grant worked immediately.
  The four migrated roles were updated in place on dev — **any future permission flag must be
  added to the migrated roles too (or ticked in the Roles UI), on every environment.** Also
  fixed: `users` was never imported in route_facilities.js (the reply crashed with a
  ReferenceError — same class of miss as `misc` earlier the same day). Verified per tier: admin
  2/unscoped, SalesRep 2/unscoped, rep-with-territory 2/scoped, rep-without 0 + 404 on
  cross-territory read and reply; reply persisted; badge=1; registry green (124 pages).
  Commit c7958bd2; dev merge 3c4f34e5.
- 2026-08-27 — **Clinical autofill + Save Draft + the PDF-preview verdict.** (1) **CLINICAL
  AUTOFILL** (Mario): clinical data is a per-VISIT snapshot on `moct_visit`, never on the
  person, so "the last order" IS the right source — new PHI-audited
  `GET /patients/:id/last-clinical` returns allergies/conditions/current-meds from the newest
  visit carrying any of them; selecting an existing patient fills only fields left EMPTY (never
  overwrites typing — regression-checked in-browser), shows "Auto-filled from the last order
  (date)" with a clear link, stays editable, and is silent for patients with no history.
  (2) **SAVE DRAFT** for orders in progress — deliberately DISTINCT from Save for Approval: a
  DRAFT is unfinished work owned by its author, a PENDING order is finished work handed to a
  prescriber. Same table, different status. Save Draft skips every field gate (incomplete by
  definition) but refuses a totally empty form; `draft_id` makes a re-save UPDATE rather than
  pile up copies; **drafts are PERSONAL** (listed only to their author — verified another user
  sees zero) while the pending queue stays the facility's shared work; new **My Drafts** tab
  with Resume (`?draft=<id>` rehydrates patient/clinical/delivery/transfer/drug rows through the
  clone path so pricing re-runs) + Delete; Save for Approval on a resumed draft promotes it in
  place (verified my-drafts 1→0, pending 2→3). (3) **⚠ PDF PREVIEW — MEASURED VERDICT:** pdf.js
  is now served from OUR origin (`public/js/vendor`, library AND worker) because a CDN worker
  needs both a CSP allowance and outbound reachability, and **when the worker fails pdf.js
  silently parses on the MAIN THREAD and hangs the tab** (that is what "no preview" looked
  like). Even same-origin, the uploaded infographic measured **parse 72 ms / render >20 s** —
  browser rasterization is simply the wrong tool for graphics-heavy PDFs, so rendering is now
  **TIME-BOXED at 12s** and reports "took longer than 12s" instead of spinning; the
  auto-backfill logs and skips such files. RELIABLE PATHS: staff upload a preview image
  (instant, always works) or accept the file icon. If automatic previews for heavy PDFs are
  wanted, that needs SERVER-side rasterization = a new dependency (pdfjs-dist + a prebuilt
  canvas binding) — a deployment-risk decision for Mario/Nick, deliberately NOT slipped in.
  Also: the queue subtitle now reads "drafted by your team for your review and approval".
  Commit 3cf7fa75; dev merge c2812b6a.
- 2026-08-27 — **⚠ THE DATA-URL BUG (why "the test Article" wouldn't open or preview) + draft
  review popup.** `public/js/main.js` **`file_to_base64()` resolves the FULL data URL**
  (`data:application/pdf;base64,…`), and the news save stored it verbatim — so
  `Buffer.from(x,'base64')` decoded garbage: the served file failed to open AND `atob()` threw
  before a thumbnail could render. ONE cause, BOTH symptoms. The portal ATTACHMENT path had
  always normalized through `misc.strip_base64` ([route_prescriber.js:539]) — the newer
  news/logo paths did not. ⚠ **THE PROCESS LESSON, second time today: my API tests passed BARE
  base64 and went green while the real UI upload was broken — the UI and the API send different
  shapes, so a feature is not verified until the UI path is exercised** (the same trap as the
  PO-line product picker on 2026-08-12). Fixed: `strip_base64` on WRITE (news doc + thumb,
  facility logo) and defensively on every READ (staff doc, portal thumb/file, Transfer Order
  embed, Rx logo); client passes bare base64 into pdf.js; **`misc` was never imported in
  route_facilities.js** — the same latent fault would have crashed the new video-poster helper's
  error path — imported. **Repaired the stored dev row in place** (tile 3 "Test Article.pdf" was
  the only corrupt one; logos clean): now serves 208,227 bytes starting `%PDF-`, confirmed
  through the portal page itself. Also shipped Mario's draft-queue questions: queued orders
  carry an explicit **"Pending Prescriber Approval"** badge (distinguishing them from the
  Pending tab, which is SUBMITTED work at MOC/the pharmacy — Draft/In review/On hold/Attention
  needed); a **REVIEW POPUP** per row (new PHI-audited `GET /draft-orders/:id` returning the
  whole order with attachment BYTES stripped but names kept — patient identity, allergies/
  conditions/meds, every drug incl. sig/qty/refills/form/NDC/notes/controlled, delivery + ship-to,
  transfer provenance, special instructions, ID-photo presence) with **Approve & Sign** routing
  through the SAME attestation step as a batch, plus Withdraw; and a **Pending-screen banner**
  counting queued drafts so Rapid-Fire is reachable from there too. Commit 7e0d4d3b; dev merge
  d746baf1.
- 2026-08-27 — **⚠ CSP ROOT CAUSE: helmet ships CSP only OFF localhost — two bugs that are
  INVISIBLE in local testing.** Mario reported "why are thumbnails not being generated?" and
  "View PDF button not working", both on the dev slot. `app.js:108` gates helmet on
  `if (!misc.is_local_host())`, so localhost sends NO CSP header at all: (a) there was **no
  `worker-src` directive**, so it fell back to `default-src 'self'` and **pdf.js's CDN worker
  was blocked** → `getDocument()` rejected → the document preview produced nothing, and my
  `catch` swallowed it (that is what hid it — evidence: tile 3 held a real 208 KB PDF with 0
  thumbnail bytes); (b) **`frame-src` allows `'self'` + `blob:` but NOT `data:`**, so every
  `data:application/pdf` iframe renders blank once deployed. **Fixes:** `workerSrc:
  ['self', blob:, cdnjs]` (narrow — cdnjs is already trusted for scripts) — this ALSO
  un-breaks the **Ops floor-plan PDF background**, which rasterizes the same way and was
  failing for the same reason, unnoticed; the client rasterizer (`pdf_first_page_b64`) now
  THROWS and the caller reports "Saved without a preview — <reason>"; a **Generate preview
  from document** button + staff doc-read endpoint so already-stored PDFs get a preview
  without re-upload; **server-side video posters** (`fetch_video_poster`: YouTube maxres→hq,
  Vimeo oEmbed; 6s timeout, 2 MB cap, fail-open) because `imgSrc` is `'self'/data:/blob:` so a
  browser `<img>` from img.youtube.com is blocked AND canvas would taint on a cross-origin
  draw; a document tile now REQUIRES a file (the "Draft tile" trap: kind switched to document,
  filename defaulted to 'document.pdf', zero bytes ever uploaded); **View PDF** switched to
  the house `open_base64_file()` blob helper (the same mechanism MOCT's visit page already
  used — one mechanism, not two); new shared **`base64_to_blob_url()`** in main.js with the
  clinic **Documents + Clinic Files** inline previews moved onto blob: (pre-existing,
  portal-facing) plus an "open in a new tab" fallback; thumbnails render `object-fit: contain`
  so a wide logo is not cropped. **VERIFICATION NOTE — the lesson:** to test CSP behaviour
  locally, boot with `IS_LOCAL_HOST=0` (misc.is_local_host reads that env) and read the
  header; that is how `worker-src 'self' blob: https://cdnjs.cloudflare.com` was confirmed
  present rather than assumed. Commit fc37a4af; dev merge 48c3fd9f.
- 2026-08-27 — **News presentation + article CONTRIBUTORS + approved logo ON THE RX** (four
  follow-ups from Mario's screenshots, all dev-verified). **(1) Search-result rows:** Mario sent
  a Google video-results screenshot — tiles became ROWS (200px thumbnail left with a play badge
  on video links, domain line, blue title, snippet, then "Source · Date"); new optional
  `source_label` so staff type the source verbatim ("YouTube · Modern Healthspan"); admin page
  gained a **Preview Page** button (staff CAN open /prescriber/news — the page gate fails open
  for non-clinic-scoped users, verified 200) and the label/title dropped "(Manage)".
  **(2) PDF first-page thumbnails:** a document tile with no preview image rasterizes page 1 via
  pdf.js (the Ops floor-plan pattern, CDN script + worker); Word can't rasterize client-side and
  keeps the icon. **(3) CONTRIBUTORS** — "all users with access can be a contributor to that
  Blog": new `emed_portal_content_comment` + per-article `allow_comments`; every user who can
  see the news page may post to an ARTICLE's ONE SHARED discussion and everyone with access
  reads it. ⚠ **CROSS-FACILITY BY DESIGN** — a contributor's name + facility are visible to
  other facilities, so the composer carries the A7 threads' no-patient-information warning;
  author name/facility are DENORMALIZED so a comment still renders if the account is disabled or
  moves. Authors delete their own (403 otherwise — verified); staff moderate any from a
  Contributions column + modal (audited); comments refused on link/document tiles and when
  contributions are switched off. **(4) APPROVED LOGO ON THE PRESCRIPTION, always 1 page:**
  `emed.load_facility_logo()` renders ONLY `status='approved'` (a pending/rejected upload never
  reaches a pharmacy document) at top-right with **position:absolute — OUT of the document flow,
  so the page count cannot change**; verified a content-heavy standard Rx = **1 page** with the
  logo and the transfer order = 1 page + embedded original; fail-open (lookup hiccup ⇒ no logo).
  Commits a852fff8 + emed_sql 5953357 (source_label, comment table, allow_comments — all
  dev-applied, pending prod); dev merge 178f3ae1.
- 2026-08-27 — **FACILITY LOGO + INDUSTRY NEWS shipped — Mario's review-gate spec round is
  COMPLETE** (all three: rapid-fire, logo, news; see the entry below for rapid-fire).
  **Logo:** portal admins upload from My Clinic — PNG/JPG, square up to 3:1 landscape
  (portrait rejected), client-normalized to 400px height, 1 MB server cap; ONE live row per
  facility (`emed_facility_logo`, filtered-unique); every upload lands PENDING and eMed staff
  approve/reject from a new Portal Logo block on the Facilities panel (rejection reason shown
  back); nothing consumes an unapproved logo — placement on documents/branding is a later
  approval-gated step. **Industry News (built to Mario's mock: bordered tiles, preview block,
  manual title, Date Added):** universal staff-curated tiles (`emed_portal_content`, kind =
  link | document ≤15 MB | article, optional preview image downscaled to 800px, publish
  switch, display order) managed at /admin/portal-news (Write_Facilities; page AdminPortalNews,
  section emed); portal page /prescriber/news renders the grid (link opens, document streams,
  article opens a reader modal; drafts never show); 'news' joined PORTAL_PAGES so the
  per-facility toggle appears automatically on Portal Settings and page + APIs are page-gated
  (verified: off → 403); readable by BOTH portal shells (universal). page_catalog +
  check_page_registry green (123 pages). ⚠ ROUTE-ORDER NOTE: the staff news CRUD lives in
  route_facilities as '/portal-news' registered BEFORE the bare '/:id' route — moving it below
  would make '/portal-news' parse as a facility id. Verified live end-to-end: staff created
  link/article/draft → portal listed exactly the 2 published; article body + streamed jpeg
  thumbnail served; tile grid rendered per the mock in-browser; logo upload → pending → staff
  approve → approved badge + image on My Clinic. Commit e8c201c3; dev merge 6d9ad1e8. Tables
  were created in 2026-08-27_add_portal_draft_orders_logo_news.sql (dev-applied, pending prod).
- 2026-08-27 — **RAPID-FIRE BULK APPROVAL shipped (Mario's spec, verbatim) + VET MODEL
  FINALIZED.** (1) **Rapid-fire:** NEW `emed_portal_draft_order` queue — any member whose tier
  can_draft saves an order WITHOUT a signature ("Save for Approval" on Create Prescription,
  reusing submit's validation via a draft-mode flag so the paths can't drift); My
  Prescriptions gains an "Awaiting Approval" tab; activating Rapid-Fire opens the DISCLAIMER
  ("you will review every pending prescription before submitting"), then checkboxes + "Bulk
  Submit (n)", then the ATTESTATION modal — "I have reviewed and approved the below listed
  prescriptions" listing patient + drug, standard e-signature attestation text, Submit
  disabled until the box is ticked. ⚠ ARCHITECTURE: approval REPLAYS each stored payload
  through the REAL new-visit handler (named `new_visit_handler`, invoked with a capture-res
  shim + prototype-chained fake req) with the APPROVER as signer — vet/transfer rules,
  address gates, attachment caps, preclar all apply identically; 25/batch cap; failures stay
  pending with the reason. Verified E2E: technician (ClinicUser shell) drafts + refused at
  approve; PIC batch-approved 2/2 → visits 1047506/1047507 through the full transfer path;
  UI walked in-browser (disclaimer → selection gating → attestation list → checkbox-gated
  Submit). Draft/list/withdraw endpoints gate on MEMBERSHIP capabilities (draft_ctx), not the
  shell — that's what lets assistants/technicians draft. (2) **Vet model, final:** Mario's
  follow-up mock reverted the morning's owner-first flip — the ORIGINAL model stands (name
  fields = the ANIMAL's; Owner Name in the vet box; contact/address = the owner's), NEW: DOB
  + Sex RELOCATE into the vet box on vet facilities (they're the animal's) on both the Add
  Patient modal and the Create Prescription panel (verified in-browser). moct_person
  owner_name restored (the pet_name rename was dev-only wip: column renamed back by hand, wip
  file dropped — never promoted). ⚠ LESSON: the flip commit had staged the WHOLE route file,
  sweeping in the uncommitted draft routes — its revert removed them too; restored from the
  flip commit + un-flipped surgically (verified: 15 draft-order refs, 0 pet_name). Also
  answered Mario: Primary Prescriber ALREADY manages the team (capability-checked, per his
  own Phase-2 rule) — no new role needed. Commits e738ac3d / fe8074f9 / c970afc4; emed_sql
  b1e5793 (+drop b1e5793's rename); dev merge 53445e59. STILL BUILDING from this spec round:
  facility logo upload (square-to-3:1, staff-approved) + Industry News tiles page (mock
  received: bordered tiles, preview block, manual title, date added).
- 2026-08-27 — **CUSTOMER-PHARMACY REALM shipped (Mario): the facility IDENTITY drives the
  transfer portal.** "Pharmacies that transfer should be type Pharmacy, with a primary
  Fulfillment Pharmacy toggle — ON = the RxCS/MM/MEDV variety, OFF = a customer of the
  pharmacies and MOC. All the special roles and transfer features live in this realm."
  New BIT `emed_facility.is_fulfillment_pharmacy` (wip migration
  `2026-08-27_add_facility_is_fulfillment_pharmacy.sql`, dev-applied; backfill verified EXACT —
  the only type='Pharmacy' rows were rxcs/mmed/mdvo ids 1741-1743 — plus normalization of
  transfer-portal facilities into the realm). **THE SEAM:** `prescriber_portal_config
  .get_facility_config` derives the EFFECTIVE portal_type — type='Pharmacy' + fulfillment OFF
  ⇒ 'pharmacy_transfer' whatever the stored column says — and EVERY consumer (pharmacy role
  family, transfer intake, Transfer Order, all-market catalog, team page) already reads that
  one function, so the identity became the single switch with zero consumer edits. Coherence
  in set_facility_config (AFTER vocab validation — a pinned test caught the ordering): setting
  portal_type='pharmacy_transfer' NORMALIZES the row to Pharmacy/fulfillment-off; switching a
  customer pharmacy to another portal type is REFUSED ("change the facility Type first").
  Facilities editor: Fulfillment switch w/ plain hints; Pharmacy Code field now only for
  fulfillment pharmacies; flag in FACILITY_FIELDS + list select + `is_customer_pharmacy` on
  the config UI payload. Verified live: stored portal_type NULLed → still derives
  pharmacy_transfer; PIC (ZZ Pharmacist promoted to pharmacist_in_charge) sees the 3-tier team
  page; catalog serves all markets; guard 400s; Clinic row normalized on panel save; UI both
  ways (1st Aid Station = customer, RxCS = fulfillment + code). +5 config tests incl. the
  partial-PUT no-blackout pin (101 green). Commits 327e57df + emed_sql 35917c6; dev merge
  ff17bd30. NOTE: staff/portal team surfaces + role families were already portal_type-driven,
  so they follow the identity automatically — the ONLY portal_type writers left are the
  Portal Settings panel and this derivation.
- 2026-08-27 — **⚠ DEV DATABASE WAS REFRESHED FROM PROD OVERNIGHT (~01:24-04:16) — what broke,
  what didn't, and what to re-do after the next one.** Mario hit it as "why is Misc empty?".
  Diagnosis (not a guess — evidenced): `emed_price_catalog.market`'s default constraint was
  created 2026-08-27 01:24 (sys.default_constraints.create_date) = the column was DROPPED and
  RE-ADDED, and the table was modified again 04:00; ZERO emed_price_audit rows for a market
  change, so no app code did it. Signature = a ROW-LEVEL refresh from prod of core tables:
  `emed_user` (dev portal test accounts 137-143 GONE, live users back to prod's 125),
  `emed_facility` (portal_type NULL, both portal toggles false), `emed_price_catalog` (892 live
  = prod's count, ZZTEST rows gone, market all back to the 'human' default). Dev-ONLY tables
  survived intact (emed_portal_membership/attestation/thread/message/order_quote/patient_link,
  prescriber_portal_page_config) — which left 7 MEMBERSHIP ROWS ORPHANED against deleted users
  (cleaned; harmless because every read JOINs emed_user). **ALL SCHEMA VERIFIED PRESENT** (12
  tables + 9 columns audited one by one) and **ALL CODE IS IN GIT** — nothing of the feature
  work was lost, only dev row data. Restored: the misc classification (new standalone
  re-runnable migration, see below), facility 2 = prescriber+clinic portal ON /
  portal_type=pharmacy_transfer / all 7 pages ON, and the two pharmacy test accounts rebuilt
  through the REAL staff path (ZZ Pharmacist id 144 staff_pharmacist, ZZ Technician id 145
  pharmacy_technician) — which re-verified the staff-side family guard (a medical tier at a
  pharmacy facility still 400s). **NEW MIGRATION `emed_sql/migrations/wip/
  2026-08-27_reassert_catalog_misc_market.sql`** (dev-applied; pending prod with the rest):
  the misc data step used to live inside the column-add file, so re-asserting it meant
  re-running a file full of no-op ALTERs; it is now standalone, idempotent and data-only —
  **after any future dev refresh or market-column rebuild, run just that one file.**
  ⚠ SELF-INFLICTED BUG FOUND + FIXED WHILE RESTORING: `prescriber_portal_config
  .set_facility_config` defaulted `pages = {}`, so a PUT that omitted the page grid DISABLED
  ALL SEVEN PORTAL PAGES — my own restore call blacked out facility 2 (audit stamped 04:16,
  which is how I caught it). Omitting `pages` now means "unchanged" (PUT semantics); the
  Facilities panel always posts the full grid so turning a page OFF is unchanged. Also
  shipped: the **attachment size guard** Mario asked for — client downscales images >1.5 MB to
  max 2200 px JPEG q0.85 (verified in-browser: a 12 MP photo 2.26 MB -> 0.81 MB, small/
  non-image files untouched, failure falls back to the original) + a hard 8 MB per-attachment
  server cap (verified: 12 MB rejected by name+size, 2 MB accepted) — motivated by the finding
  that **Liberty accepts multi-page PDFs**: proven with REAL production scripts by decoding
  submitted PDFs and matching them inside Liberty's own mirror (visit 1026365 = 2 pages ->
  scripts 528432/528434/528435; 1025968 = 2 pages 1.3 MB -> 526149; **1025932 = 8 pages,
  3.8 MB -> 526200/526203**, all WorkFlowStatus V), so the 2-page Transfer Order (sheet +
  embedded original Rx) flows to RXQ like any other script and only SIZE, not page count,
  matters. Plus the Misc checkbox label cleanup (Mario: the "(always on price lists)" note
  wrapped and crowded the dropdown). Commits 83ca1858 + emed_sql 807e65d; dev merge 6708b960.
- 2026-08-26 — **TRANSFER ORDER document shipped (Mario's call at the review gate).** A
  pharmacy-transfer submission now generates a "PRESCRIPTION TRANSFER ORDER", not a
  prescription: banner title, transfer header (Transferring Pharmacy / Pharmacist / Original
  Rx # / pharmacist phone — deliberately NO address row, the on-file address is the SUBMITTING
  user's record, not the transferring pharmacy's), "Medication to Transfer / Fill" section,
  pharmacist attestation + signature captioned "Transferring Pharmacist", and — the ask — the
  uploaded ORIGINAL Rx image(s) EMBEDDED on the sheet full-width/bordered in unbreakable
  blocks ("Original Prescription (as received from X)"); a non-image original (PDF) is
  referenced by filename. ⚠ ARCHITECTURE: everything derives from PERSISTED state
  (emed.parse_transfer_block over moct_special_instructions + moct_pdf
  Prescription_Attachment rows; emed.load_transfer_context attaches v.transfer inside
  redrive_unsent_scripts) because outbox re-drives AND preclar releases regenerate the PDF
  long after the request body is gone — both funnel through redrive. Fail-open: a context
  fetch hiccup renders a plain Rx, never fails a submission. Special Instructions on the
  order strips the transfer block (it renders in the header) and keeps operator-added notes;
  human/vet/refill documents untouched. Verified live on dev: visits 1047344/1047345 rendered
  with the full layout + embedded image + notes-only special instructions; PDF sent to Mario.
  Commit ca9a4426; dev merge bf184682. ⚠ Bash-heredoc'd Python edit scripts mangle
  backslashes in this environment — write edit scripts with the Write tool and execute the
  file (bit twice).
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
