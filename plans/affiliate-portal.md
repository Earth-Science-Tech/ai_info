---
title: Affiliate Portal — invite-only affiliates, single-use QR codes → patient portal → MOCT visit
slug: affiliate-portal
status: Completed in Production
project: multi
branches:
  - emed_app: feat/affiliate-catalog        # PR-A — catalog + pricing groundwork (ships dark)
  - emed_app: feat/affiliate-portal         # PR-B — the module
  - emed_sql: feat/affiliate-portal-schema  # 7 migrations (incl. the intake-form map) — applied to prod 2026-09-17, tag 1.0.359
developers:
  - mariotabraue
prs:
  - "emed_app#851 (feat/affiliate-catalog -> main, PR-A — merge FIRST)"
  - "emed_app#852 (feat/affiliate-portal -> main, PR-B; includes Nick's Intake Form Map cherry-pick 2ed7f5dc)"
  - "emed_sql#97 (feat/affiliate-catalog-schema -> main, pairs with #851)"
  - "emed_sql#98 (feat/affiliate-portal-schema -> main, pairs with #852; includes Nick's emed_catalog_required_form migration)"
tags: []
created: 2026-09-17
updated: 2026-09-17
related: ["[[patient-portal-secure-messaging]]", "[[peaknow-portal-integration]]", "[[facility-scope-groups]]"]
---

# Affiliate Portal

## Status & history
- 2026-09-17 — Not Started → In-Progress (mariotabraue): plan approved in plan mode (bundle math, earned-when rule,
  encrypted TIN/bank, own payout ledger, pre-paid billing, `moct` gateway, base64 images all decided by Mario the same day).
- 2026-09-17 — In-Progress → Completed in Dev (mariotabraue): PR-A (`b9a84665`) and PR-B (`27776333`, `0041b25d`,
  `41b81c99`, `b88bc9f1`) merged to `dev` (`4e3d6b1d`), dev-slot deploy green 08:20 UTC; full Vitest suite 338 files /
  7,417 tests green except the pre-existing local `webhook_crypto` failures (no `WEBHOOK_SECRET_KEY`). emed_sql
  `feat/affiliate-portal-schema` @ `e5aeff4` pushed, all six migrations applied to `liberty_link_dev`. Two UI fixes from
  Mario's dev test followed the same day (wizard picker keeps categories expanded; Facilities type filter offers Affiliate).
  **Handed to Nick for review and for the patient side** (see § Contract and § Rollout).
- 2026-09-17 — still Completed in Dev (mariotabraue): **quantity per drug** (Mario: "when completing the retail pricing,
  quantity should be a required field for each drug") — `emed_affiliate_product.quantity` + `emed_affiliate_sale_line.quantity`
  (emed_sql `47f488c`, dev-applied, pending prod with the rest), floor = drug_cost × quantity + consult + shipping, no default,
  `no_quantity` rows are not sellable, the QR snapshot / sale line / visit `Drug[].Quantity` carry it; the Retail table was
  re-laid out (fixed colgroup, shipping price inside the select, cost-source pill under the cost). On dev.
- 2026-09-17 — still Completed in Dev (mariotabraue): **QR readiness keys off the INTAKE-FORM rule, not the prescription
  template** (Mario: "no prescription template is preventing me from adding products — only the intake should be required;
  check the intake form association against the Intake Form Map page"). `affiliate_qr.list_products` now asks
  `product_required_form.list_for_facility` for ANY rule on the catalog id — the facility's Clinic Products row or Nick's
  global `emed_catalog_required_form` row ([[pricing-intake-form-map]]) — and answers `no_intake_form` only when there is
  none; `mappable` (quick-adds present) is informational. `affiliate_visits.create_visit_for_sale` still runs the forms
  step for a line without a template and leaves the visit in Received for the provider to prescribe by hand. This closes
  the map plan's open item 2 (a global Rx-preset twin is no longer needed for QR readiness). On dev.
- 2026-09-17 — PRs OPEN (mariotabraue, on Mario's go): eMed #851 (PR-A) and #852 (PR-B), emed_sql #97 and #98; review requested
  from nicholas-cardell. Order: emed_sql #97 -> apply to prod -> eMed #851 -> emed_sql #98 -> apply -> eMed #852 (both eMed PRs
  target main, never stacked; #852 shows #851's commits until it merges). #852 / #98 carry Nick's Intake Form Map commits
  cherry-picked from dev at Mario's request (e784b536 -> 2ed7f5dc app, 80abd06 -> 2bda541 sql) because they depend on PR-A/B
  code. eMed CI (lint, cut-from-main, schema-dependency section) passed at open; the migration files must reach emed_sql
  main and prod before the paired eMed PR deploys.

- 2026-09-17 — Completed in Dev → Completed in Production (nicholas-cardell): eMed **#851** + **#852** merged to `main`
  after review; emed_sql **#97** + **#98** merged and every migration applied to `liberty_link_stage` with
  `apply_migration.py --db both --confirm`; tagged **1.0.359** (with #849 Show Pricing and #850 rep lead notes).
  Review commit `da953535` on #852 (all tests green, 356 files / 7,707): reversing a payable sale already on a
  submitted/approved/paid statement now POSTS AN ADJUSTMENT instead of editing the locked statement (a draft is
  recomputed); the sweep keys rejections off the visit's CURRENT status, not history, and skips already-adjusted
  sales; `payments.gateway_for('moct')` THROWS when `PROPELR_MOCT_*` is unset (was: silently fell back to the
  pharmacy merchant) and the public tokenization key answers '' so checkout refuses cleanly; W-9 uploads are
  `field_crypto`-encrypted at rest (legacy plaintext rows still read) and capped at 5 MB; `/api/affiliate/me` returns
  a `SELF_FIELDS` whitelist (no `*_enc`, notes, tokens); a second `submit` answers 409; the Facility editor may KEEP
  `type='Affiliate'` but can neither set nor clear it (it drives MOC-billing exclusion); the User editor refuses
  only MINTING/PROMOTING the Affiliate role (editing an existing affiliate login works again); `sql_error()` reads
  `db.__last_error` (the config object, not the wrapper) across the affiliate modules; `handle()` maps a null query
  result to a `db` error; `order_context_for_visit` fences the `AF-<id>` fallback to the sale's own facility;
  `ready()` caches a negative table probe for 60 s. #851 review: the public product-image route has its own
  600/min limiter. **Still owed on the prod App Service:** `PROPELR_MOCT_SECURITY_KEY`,
  `PROPELR_MOCT_PUBLIC_TOKENIZATION_KEY`, `AFFILIATE_ALERT_EMAIL` (and confirm `FIELD_ENCRYPTION_KEY`). Until then the
  module is inert for every existing clinic/user — nothing changes until an application is approved.

## Summary
Guerrilla-marketing channel: **affiliates** (non-medical individuals, invited by an eMed Admin) sell an admin-curated
subset of the product catalog through **single-use QR codes**. A patient scans, creates a patient-portal account, pays,
and an ordinary **MOCT visit** is created under the affiliate's facility for MOC provider review; our pharmacies fulfil.
The affiliate earns the markup above eMed's all-in floor (drug cost + MOC consultation + shipping). The order is
**pre-paid by the patient**: nothing is ever invoiced to the affiliate.

Mario's words (2026-09-17): the affiliate portal is "treated just as any other clinic portal currently operating,
submitting orders to MOC for review that, if approved, get sent to our pharmacies for fulfilment — the only difference is
that these portals incorporate the patient portal module for a better patient experience."

Ownership: **Nick** owns the patient side (scan → account → pay → `claim_and_record` → `create_visit_for_sale`, plus the
patient portal's Products / Payment Info sections). **This plan is Mario's side** — everything an affiliate or an eMed
admin touches, the pricing engine, the QR token, the sales ledger and payouts — and the contract Nick codes against.

As-built detail lives in the app repo: `emed_app/docs/plans/affiliate-portal.md` (same content as the Design section
below plus the verification checklist) and `CLAUDE.md` items **88** (PR-A) and **91** (PR-B).

## Decisions (Mario, 2026-09-17 — do not re-open)

| Topic | Decision |
|---|---|
| Bundle math | **Per product, literal.** `total_i = drug_cost_i × quantity_i + consult + shipping_i`; `retail_i` = explicit price, else `total_i × (1 + markup%)` (program default +50 %, cap +100 %). A QR bundle's patient price = Σ retail_i — consult and shipping repeat per product by design. Affiliate margin_i = retail_i − total_i. **Quantity is a REQUIRED per-drug field on Retail** (Mario 2026-09-17): how many units of the catalog row the retail price buys; no default — a row without one is `no_quantity` / not sellable and `set_retail` refuses until it is typed. |
| Earned when | Sale `pending` at patient payment → `payable` on the visit's first *Approved by Prescriber* / *Approved Refills* / *Approved OTC* → `reversed` on refund / Cancelled / Rejected. Statements include `payable` only. |
| TIN / bank | `field_crypto` AES-256-GCM at rest, last-4 shown, reveal = `Admin_Affiliates` + `log_phi_access` + `no-store`. W-9 PDF as a base64 document. |
| Payouts | Own ledger (`emed_affiliate_sale` / `_payout` / `_payout_payment`), not the Commissions module. Payment rows mirror `etst_commission_payment` so warehouse bank-matching can be added later. |
| Facility / role | `emed_facility.type = 'Affiliate'`; exactly one user per facility; built-in exclusive clinic-scoped role **Affiliate** (custom roles cannot be clinic-scoped). Invite-only. |
| Consult fee | `emed_affiliate_settings.default_consult_fee` (25) with `emed_affiliate.consult_fee_override`; edited only on the admin page. Never touches the CEO dashboard's `config:moct_consult_rate`. |
| Shipping | `emed_pricing_config.ship_2day / ship_overnight` + per-sheet overrides on `emed_price_special`; `null` = not configured → the row is **not sellable** (never falls back to the clinic in-state `ship_rate`). |
| Product images | Base64 in `emed_price_catalog_image` (own table so an upload never bumps the catalog row's `date_modified` / `row_token`), public cacheable route. Chosen over Azure Blob: non-PHI, ≤ 1 MB, hundreds of rows. |
| Patient charges | New Propelr gateway **`moct`** ("My Online Consultation") — `payments.GATEWAYS.moct`, env `PROPELR_MOCT_SECURITY_KEY` / `PROPELR_MOCT_PUBLIC_TOKENIZATION_KEY`. Checkout must use `payments.assert_gateway('moct')`, never `gateway_for()`'s rxcs fallback. |
| Billing | Pre-paid — Affiliate-type facilities are excluded from MOC consult invoicing and from the pharmacy ready queue / `create_invoice` (409 `prepaid_affiliate`). |
| Pipeline | Identical to every clinic portal once the visit exists: Received → Pending Consultation → provider review/sign → pre-clarification gate → pharmacy routing → Liberty → shipping. Nothing downstream of approval is new or bypassed. |

## Design / approach

### Modules (`emed_app/server/`)

| File | Role |
|---|---|
| `affiliates.js` | identity + settings + invite tokens + application validation/submit (encrypt-at-write) + `approve_and_provision` (facility → user → group → template clone → selection) + suspend/reactivate + `for_user` / `require_affiliate()` + payout/contact self-service; `catalog_tree()` for the anonymous wizard (names only) |
| `affiliate_math.js` | PURE money math: `build_line`, `apply_promo` (floor-guarded), rounding |
| `affiliate_pricing.js` | eligible catalog tree, selection diff (revive/insert/soft-delete), `retail_rows` priced live, `set_retail` (409 below_floor / above_cap), `bulk_markup_pct`, `quote_lines` (the seam for QR + ledger) |
| `affiliate_promos.js` | affiliate promo codes (code/kind/value immutable), `validate_promo`, uses derived via a registered counter |
| `affiliate_qr.js` | mint (frozen snapshot, SHA-256 token, `token_enc` for the owner), `resolve` state machine, floor re-check, `reserve` / `claim`, share/png, revoke/duplicate, `public_projection`, `price_for_claim` |
| `affiliate_sales.js` | the ledger: `claim_and_record`, `record_portal_sale`, `attach_visit`, status machine (`mark_payable`, `reverse_sale` → adjustment rows on paid), `on_visit_status` (fast path), `sweep` (cron), `order_context_for_visit` (the provider), reads / CSV / report |
| `affiliate_visits.js` | `create_visit_for_sale` — the MOCT orchestrator (§ Contract) |
| `affiliate_payouts.js` | `build_statements`, `approve` (frozen PDF + number + email), `void_payout`, append-only payments + `refresh_paid_status`, statement HTML (div-grid), xlsx |
| `affiliate_sales_cron.js` | 15-min durable pass (history approvals / rejections / refunds / unlinked alert / stale reservations); dormant on localhost unless `AFFILIATE_CRON_ON_LOCALHOST=1` |
| `pricing_images.js` | stock images (PR-A) |
| Routers | `route_affiliate.js` (`/api/affiliate`, portal; sub-mounts `route_affiliate_pricing` at `/`, `route_affiliate_qr` at `/qr`, `route_affiliate_sales` at `/sales`), `route_affiliate_admin.js` (`/api/affiliates`; sub-mounts `route_affiliates_finance` at `/finance`), `route_affiliate_public.js` (`/api/public/affiliate`; sub-mounts `route_affiliate_qr_public` at `/qr`, `affiliate_qr_rate_limiter` 60 / 15 min per IP) |
| Views | `views/public/affiliate-apply.ejs` (5-step wizard), `views/public/affiliate-landing.ejs` (`/a`), `views/affiliate/{general,products,retail,sales,qr}.ejs`, `views/admin/affiliates.ejs` + `affiliates-finance.ejs` (Sales / Payouts tabs), `public/js/affiliate_product_picker.js`, `public/js/image_downscale.js` |

### Schema (emed_sql `feat/affiliate-portal-schema`, `migrations/pending/2026-09-17_*`, dev-applied, PENDING PROD)

PR-A (hard deploy-order dependencies — selected unconditionally, named in `pricing.schema_check()`):
`emed_price_catalog.affiliate_eligible`, `emed_pricing_config.ship_2day/ship_overnight`,
`emed_price_special.ship_2day/ship_overnight`; `emed_price_catalog_image` ships dark behind a probe.

PR-B (ship dark behind `OBJECT_ID` probes): `emed_affiliate`, `emed_affiliate_invite_token`, `emed_affiliate_document`,
`emed_affiliate_settings` (singleton, seeded 25 / 50 / 100 / 14 / 90 / 20), `emed_affiliate_product` (incl. `quantity`, 2026-09-17),
`emed_affiliate_promo`, `emed_affiliate_qr`, `emed_affiliate_sale`, `emed_affiliate_sale_line` (incl. `quantity`), `emed_affiliate_payout`,
`emed_affiliate_payout_payment`. Filtered unique indexes are the race backstops: one live affiliate per facility / user,
one live selection row per (affiliate, catalog), one sale per QR and per payment transaction, one adjustment per paid
sale, one non-void statement per (affiliate, month), one payment per bank key and per reversed payment. No triggers on
the new tables; every claim still uses `OUTPUT … INTO @t`. GRANT SELECT/INSERT/UPDATE to `emed_app`, no DELETE.

### Permissions / pages

Role `Affiliate` (built-in, `MACHINE_ROLE_META`: clinic-scoped, exclusive, session, MFA) = `Default()` + `View_App`,
`View_Menu_Affiliate_Portal`, `Write_Affiliate_Portal`, `Submit_Issue`. Staff flags `View_Affiliates` / `Admin_Affiliates`
(Admin-only during build-out; `SuperUser()` zeroes them). Pages `AffiliateGeneral|Products|Retail|Sales|QR` (section
`affiliate`) and `AdminAffiliates`. `PERM_SCHEMA_VERSION` 25 (stale sessions rebuild). `POST /api/users` refuses the
role (created only through Invite → approve). Portal writes are in `WRITE_ROUTES` under their page; `/api/affiliates/*`
writes and `/finance/*` stay unmapped (pure `Admin_Affiliates`, the `Admin_Zoolzy` precedent).

### Flows

**Onboarding.** Admin → Invite (email; raw token returned only when not emailed) → `/affiliate/apply#token=…`
(contact → W-9 with TIN + certification → payout ACH/wire + authorization → products (names-only tree) → review) → ONE
guarded UPDATE `invited → submitted` + W-9 document → admin Approve = `approve_and_provision`: claim `provisioning`,
refuse an existing login, `save_facility(type 'Affiliate')` (collision → "(Affiliate)" suffix) + address,
`patient_portal_config.set_facility_config(portal_enabled, pages from settings)`, `users.create_portal_account(role
Affiliate, scope_facility_id)`, Affiliates group membership (`group_type 'affiliate_program'`), program-template clone
(`emed_product_required_form` rows from `settings.template_facility_id`), product selection, `active`, welcome email
(temp password redacted from `emed_email` — fixed for every caller of `send_portal_welcome`). Suspend =
`set_account_status inactive` + cache clear + `revoke_user_sessions`.

**Retail.** `retail_rows(affiliate)` = selection LEFT JOIN catalog + `get_portal_catalog(facility)` effective price
(FINAL sheet → base, promo if lower) + `get_shipping_rates_for_facility` per row's service + consult fee → `build_line`
→ `{ quantity, drug_total, total, floor, cap, retail, retail_source, margin, flags:{upon_request,no_quantity,no_shipping,below_floor,above_cap,unavailable},
sellable }`. An explicit retail is stamped and never auto-changed; cost drift flags it (the special-sheet `final_price`
lesson). `quote_lines` refuses unsellable lines and returns the frozen per-line snapshot.

**QR.** `mint` = sellable ∩ covered by an intake-form rule (a Clinic Products row of the facility or a global Pricing →
Intake Form Map row for the catalog id, as `product_required_form.list_for_facility` merges them; an explicit no-form row
counts, no row = `no_intake_form`; a missing prescription template does NOT block — the reviewing provider prescribes by
hand, Mario 2026-09-17) → `quote_lines` → `INSERT emed_affiliate_qr` (hash, `token_enc`,
`bundle_json`) → `https://<host>/a#t=<raw>` (fragment — the bearer never reaches access logs; ~71 bytes → QR v5).
`resolve` → `invalid | too_many_attempts | revoked | claimed | expired | unavailable | repriced | reserved | active`; the
floor re-check uses `effective_total_i = max(snapshot, live)` — eMed's floor is never eroded, the affiliate absorbs drift
up to its margin, the patient price stays what the flyer said; a live-pricing failure FAILS CLOSED. `reserve` (20 min,
guarded UPDATE — the two-phones-one-flyer race), `claim` (atomic active → claimed). Public payload = `public_projection`
(display name, labels, images, prices; never floor / margin / cost / ids).

**Ledger.** `claim_and_record` = idempotent on `payment_transaction_id` → `price_for_claim` → `amount_mismatch` check →
`validate_money` (gross = Σ patient_price, floor_total = Σ total, affiliate_due = gross − floor_total) → INSERT sale (the
UQ on `qr_id` is the double-claim gate) + lines → `aq.claim` → on `claim_lost` the sale is retired (never half-written).
Status machine: fast path `on_visit_status` fire-and-forget from the THREE status writers (`route_moct /set-status`,
`emed.reconcile_visit_approved`, `advance_ready_visit`'s auto-approve); durable path `affiliate_sales_cron.sweep` every
15 min. A **paid** sale is never edited — `reverse_sale` posts an `adjustment` row (`adjusts_sale_id` UQ) that nets on
the next statement. **HIPAA: the only patient fields in the ledger are `moct_person.id` (shown as Patient ID) and
`external_id`.**

**Payouts.** `build_statements('YYYY-MM')` claims every `payable` unstamped sale whose `payable_at` falls before the next
month (adjustments always) into one draft per affiliate; net ≤ 0 is skipped and carries forward; idempotent (garbage
period → `validation`, never "this month"). `approve` freezes the PDF, stamps `AFS-YYYYMM-<affiliate_id>`, emails it
(PDF attached, base64 kept out of `emed_email`). `record_payment` / `reverse_payment` (negation row) →
`refresh_paid_status` flips `paid` and the sales with it; `paid_total` is never stored. `void` un-stamps.

**Billing exclusions.** `facilities.affiliate_clinic_names()` (60 s cache) / `is_affiliate_clinic(name)`:
`GET /api/moct/billing` drops affiliate clinics; the billing ready queue marks rows `PrepaidAffiliate` (purple pill,
unselectable in every select-all path) and `invoice.create_invoice` refuses them (`prepaid_affiliate`, HTTP 409); the
visit page shows "Pre-paid (Affiliate)" from `GET /api/moct/visit`'s `visit.prepaid_affiliate`.

**⚠ The one change outside the module.** `product_required_form._order_required` answered `null` for every non-Peaks
clinic (→ `advance_ready_visit` `no_order_context`), so an affiliate visit would never have left Received. It now
consults **`ORDER_CONTEXT_PROVIDERS`** when `peaks_sites.site_for_clinic` is null; the affiliate provider returns the sale
lines (`{catalog_id, name}`) so `_match_mapping` (pass 2, `catalog_id`) and `scope_lines_to_visit` (request name = line
label) work unchanged. Peaks and every unclaimed clinic behave byte-identically (pinned by
`product_required_form_order_context.test.js`).

**`moct` gateway.** `payments.GATEWAYS.moct`; new `gateway_code()` recognizes the LITERAL `moct` before
`misc.fmt_pharmacy` (which knows only pharmacy codes and is unchanged); unset keys ⇒ `assert_gateway('moct')` refuses —
a patient charge never falls through to a pharmacy merchant. Boot log prints `moct_key=<set|unset>`.

## Contract with Nick (patient side)

| Step | Who | Call / rule |
|---|---|---|
| Scan | eMed | `/a#t=<raw>` renders the landing (`views/public/affiliate-landing.ejs`, `Referrer-Policy: no-referrer`, no-store); **Continue** → `/patient/signup#t=<raw>&promo=<code?>` (fragment keys `t`, `promo`). |
| Resolve | Nick | `POST /api/public/affiliate/qr/resolve {t}` → `{ok, status, affiliate:{display_name}, bundle:{lines:[{catalog_id,label,image_url,retail,discount,patient_price}], subtotal, discount_total, total, currency, promo_code}, promo_hint, expires_at}`; in-process twin `affiliate_qr.resolve(raw, {bump:false})` (carries `_row/_bundle/_eff_lines` for server callers). Promo preview `POST /qr/promo {t, code}`. ⚠ Public POSTs under `/api/*` must send `X-Requested-With: eMed` (CSRF middleware). |
| Account | Nick | `patient_portal.find_or_create_user(phone)` + demographics + consent. |
| Reserve | Nick → us | `affiliate_qr.reserve({raw, patient_portal_user_id})` BEFORE the pay form → `{ok:true, status:'reserved', reserved_minutes}` or `status: reserved_by_other | claimed | expired | revoked | repriced | unavailable | invalid`. |
| Price to charge | Nick → us | `affiliate_qr.price_for_claim({raw, promo_code})` → `{ok, gross, floor_total, discount_total, affiliate_due, promo, lines}` — charge `gross`, never a browser total. |
| Pay | Nick | Collect.js keyed with `payments.public_tokenization_key('moct')`; `payments.assert_gateway('moct')` MUST pass; `payments.sale({vault_id, amount: gross, cvv, pharmacy:'moct', orderid:'AF-QR-<qr_id>', idempotency_key, email, customer_receipt:true})` → `emed_payment_transaction` row (`pharmacy='moct'`). Refunds through the same gateway. **`bill_to_type='patient'`** is new vocabulary Nick adds in `payments_methods` / `route_payment_capture` (today `'clinic'` is hard-coded and asserted). |
| Claim | Nick → us | `affiliate_sales.claim_and_record({raw_token, patient_portal_user_id, promo_code, payment:{transaction_id, amount, gateway:'moct', gateway_ref}}, {app_user:'patient_checkout', app_name: clinic})` → `{ok, sale_id, order_id:'AF-<id>', affiliate, lines, gross, affiliate_due}` or `code: claim_lost | claimed | reserved_by_other | repriced | amount_mismatch | expired | revoked | unavailable | invalid | db` → **Nick refunds on failure**; our function never leaves a half-written sale; a retry with the same `transaction_id` is idempotent. |
| Visit | Nick → us | `affiliate_visits.create_visit_for_sale(sale_id, patient, {app_user:'patient_checkout'})` with `patient = {first_name, last_name, date_of_birth 'YYYY-MM-DD', sex, email, phone, address, address2, city, state, zip, shipping:{name, phone, address, city, state, zip}}` → `{ok, visit_id, person_id, external_patient_ref, order_id, clinic, forms_due, advance:{advanced, reason}}`; retry ×3; a failure leaves the sale `pending` / `visit_id NULL` → cron alert + admin Attach. The visit's `PatientId` is `'PP'+patient_portal_user_id` (non-PHI, one `moct_person` per patient); `OrderId` is `'AF-'+sale_id`; `VisitType 'Affiliate Bundle'`; each `Drug[]` entry is a sale line named by its label with `Quantity` = the line's affiliate quantity (the auto-prescribed draft keeps the quick-add template; the reviewing prescriber reconciles the two, as for a store order). |
| Link | Nick | `patient_portal.link_person(uid, person_id, clinic, 'affiliate_qr')`. |
| Later purchases | Nick → us | `affiliate_sales.record_portal_sale({person_id | affiliate_id, patient_portal_user_id, catalog_ids, promo_code, payment})` then `create_visit_for_sale` again. Products to offer = `affiliate_qr.list_products(affiliate).rows.filter(r => r.qr_ready)` (via `affiliate_sales.affiliate_for_person(person_id)`). |
| Portal pages | Nick | add `products`, `payment_info` to `patient_portal_config.PORTAL_PAGES`; `emed_affiliate_settings.patient_portal_pages` (default `messages|my_prescriptions|intake_forms`) is what provisioning turns on per affiliate facility — add the new keys there once they exist. |

Writers: Nick owns `patient_portal_*`, `emed_payment_method`, `emed_payment_transaction`; we own `emed_affiliate_*`;
`moct_*` rows are written only through `affiliate_visits` → `moct_intake` / `auto_prescribe_for_visit`.

## Environment

`FIELD_ENCRYPTION_KEY` (required — invites/submits refuse without it; missing on localhost), `PROPELR_MOCT_SECURITY_KEY` +
`PROPELR_MOCT_PUBLIC_TOKENIZATION_KEY`, `AFFILIATE_ALERT_EMAIL`, `AFFILIATE_CRON_TICK_MS`, `AFFILIATE_CRON_ON_LOCALHOST`.
All documented in `.env.example`.

## Rollout / remaining

**Where it is (2026-09-17, later).** SHIPPED to production in **1.0.359** (eMed #851/#852 + emed_sql #97/#98, all migrations on `liberty_link_stage`). Earlier the same day: both PRs' worth of code was on `dev` and live on the dev slot (`https://emed-dev.azurewebsites.net`).
The PRs to `main` are **held until Mario OKs**: PR-A (`feat/affiliate-catalog`) first, then PR-B (`feat/affiliate-portal`),
never stacked, each paired with the emed_sql PR from `feat/affiliate-portal-schema` (cross-link, state deploy order:
migrations before or with the app deploy — the PR-A columns are hard dependencies).

**Prerequisites before real testing** (Azure app settings — dev slot done by Mario; **PROD STILL OWED** as of the 1.0.359 tag):
1. `FIELD_ENCRYPTION_KEY` — without it every Invite / Submit answers `encryption_unavailable`.
2. `PROPELR_MOCT_SECURITY_KEY` + `PROPELR_MOCT_PUBLIC_TOKENIZATION_KEY` — the "My Online Consultation" Propelr account.
3. `AFFILIATE_ALERT_EMAIL` — recipient of the paid-but-no-visit alert.

**Finding it in the menu.** The sidebar layout appends unseen sections at the END and focus mode collapses them, so a
user who saved a section order before this shipped sees "Affiliate Portal" / "Affiliates" collapsed at the bottom. Use the
sidebar "Search menu…" box (type `Affil`) or go direct: `/admin/affiliates`, `/affiliate/general`.

**Localhost caveat.** `auth.login` forces Admin on localhost, so every `/api/affiliate/*` portal call answers
`no_affiliate` there; the affiliate-role paths (login as an affiliate, Products / Retail / QR pages with data) only work
on the dev slot. Two local servers share the `localhost` session cookie — use `127.0.0.1` for the second one.

**Nick's side (not built yet) — until it exists a QR resolves and previews but nothing can be bought:**
- `bill_to_type='patient'` in `payments_methods` / `route_payment_capture` (vault a patient card on the `moct` gateway).
- Patient-portal pages `products` and `payment_info` (`patient_portal_config.PORTAL_PAGES`), then add the keys to
  `emed_affiliate_settings.patient_portal_pages`.
- The checkout: `reserve → price_for_claim → payments.sale('moct') → claim_and_record → create_visit_for_sale → link_person`,
  refunding on any claim failure.
- `/patient/signup` reading `#t=` and `promo=` from the fragment the landing page hands over.

**E2E to run together once the checkout exists:** scan → account → reserve → pay (test MID) → `claim_and_record` →
`create_visit_for_sale` → visit in Pending Consultation with rx drafts linked to requests → prescriber signs → sale
`payable` (hook) → second visit approved with the hook disabled → cron flips within 15 min → Build statements → Approve →
PDF → Record payment → sale `paid` → refund one → adjustment row next month; second phone during checkout → `reserved`;
revoke → landing says revoked; raise a floor above retail → `repriced`.

**Open (business / Nick):**
1. Refund path and partial refunds (v1: any approved refund = full reversal).
2. Affiliate "new sale" notification email (v1.1).
3. Reservation 20 min, QR default expiry 90 days, statements monthly, no minimum payout — confirm.
4. Default patient-portal page set once Nick's `products` / `payment_info` keys exist.
5. Liberty **Paid** workflow location for pre-paid fills — nothing invoices them, so nothing moves them today (v1.1
   candidate: `affiliate_sales_cron` calls the same `move_to_paid` as `invoice.mark_paid` once dispensed).
6. Batch QR mint + PDF tile sheet (v1.1); warehouse bank matching for payout payments (columns in place).
7. AR reporting (`ceo_ar` unbilled decomposition) should classify affiliate fills as pre-paid rather than facility-billable.

**Landmines for whoever continues:**
- `sql.js` is a FACTORY (`sql(db).query` never throws → null + `sql(db).__last_error`; `upsert` returns
  `{rows_modified, error}`); never a bare `OUTPUT INSERTED` on a triggered table — the module tables have no triggers but
  every claim still uses `OUTPUT … INTO @t`, keep it that way.
- The QR floor re-check must stay at BOTH resolve and claim; `public_projection` must never grow a cost/floor/margin field.
  When the affiliate changed a row's quantity after minting, the live floor is computed for the SNAPSHOT's quantity
  (`affiliate_qr.live_total_for`) — never re-judge a printed code against a quantity it did not promise.
- Quantity has NO default anywhere (product row, bulk tools, revive-on-reselect all leave it NULL); only the affiliate types it.
- `_order_required` provider seam: any new non-Peaks ordering surface registers a provider in `ORDER_CONTEXT_PROVIDERS`
  rather than special-casing the clinic string.
- Payout money is never stored as a total (`paid_total` = SUM of payments); a paid sale is corrected by an adjustment
  row, never edited.
- Unit suites (Vitest — never `npx jest`): `affiliate_math`, `affiliate_pricing`, `affiliate_promos`, `affiliate_qr`,
  `affiliate_sales`, `affiliate_visits`, `affiliate_payouts`, `affiliates`, `affiliates_provisioning`, `affiliate_role`,
  `route_affiliate_admin_perm`, `route_affiliate_portal`, `route_affiliate_public`, `route_affiliate_qr_public`,
  `route_affiliates_finance_perm`, `payments_moct_gateway`, `facilities_affiliate_clinic`,
  `product_required_form_order_context`, `pricing_images`, `pricing_affiliate_catalog`.
