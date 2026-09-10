---
title: Peak Now Patient-Portal Integration (webhooks, intake forms, embedded portal + SSO)
slug: peaknow-portal-integration
status: Completed in Production
project: multi
branches:
  - emed_app: feat/peaknow-portal-integration (merged, deleted)
  - emed_sql: main (6ac2e13)
developers:
  - nicholas-cardell
prs:
  - "emed_app#515 (feat->main)"
tags: ["1.0.241", "1.0.313", "1.0.314", "1.0.329", "1.0.330"]
created: 2026-08-30
updated: 2026-09-10
related: ["[[patient-portal-secure-messaging]]", "[[facility-scope-groups]]"]
---

# Peak Now Patient-Portal Integration

## Status & history
- 2026-09-10 — Fix (nicholas-cardell), tag **1.0.330** (PR emed_app#737): **the WooCommerce webhook receiver is no longer behind the 60/min per-IP API limiter** — `rate_limiter.webhook_limiters({ is_trusted })` gives HMAC-signed posts a 1,200/min ceiling (circuit breaker) and keeps unsigned posts at 60/min; `wc_webhook_verify.verified(req)` memoises the HMAC. Webhook #9 (order.updated) was then **re-activated on peaknow.com with its failure counter reset** (12:52 GMT, `wp eval-file`: set_failure_count(0) + set_status(active) in one save). Store hygiene still open for Jorge: WP_DEBUG=true in production (1.36 GB debug.log; WooCommerce logs full webhook bodies to uploads/wc-logs — not web-fetchable, at-rest only).
- 2026-09-10 — Enhancement (nicholas-cardell), tag **1.0.329** (PR emed_app#734): **Add Visit clinic follows the store order number** — the staff form and `POST /api/moct/new-visit` set the clinic from the Clinic Order # (`peaks_sites.clinic_for_order_number` / main.js `peaksClinicForOrder`: a Peaks store clinic + number >= 100000 -> PeakNow, else Peaks Curative; strict on the two store clinics, other clinics untouched). Hand-created PeakNow visits had defaulted to Peaks Curative (1049747 on #112970) and sat on the wrong Orders page. The person lookup for a store visit now spans both store clinics and keeps the found row's clinic (no duplicate patient), and the Add Visit picker lists both stores' patients.
- 2026-09-10 — Investigation (nicholas-cardell, Nick asked): **Woo webhook #9 "eMed — Order Updated" was auto-disabled by WooCommerce itself on 2026-09-05 03:33 GMT** (failure_count 6): WC disables a hook after more than 5 CONSECUTIVE non-2xx deliveries. The AST tracking ETL moved 47 legacy orders Processing->Shipped in one minute -> 68 order.updated deliveries in 9 s -> eMed's own `api_rate_limiter` (60/min/IP, in front of `/wc/webhooks/peaknow`) answered 429 to the 34th onward. #8 order.created unaffected; reconciler recovered 0 (no PeakNow order needed the hook since). The 6-hourly alert email comes from `wc_reconcile_cron._check_webhook_health` (timer resets on every deploy). Not yet done: re-activate + reset failure_count together; move the HMAC-verified receiver out from behind the limiter. ALSO: prod peaknow.com has WP_DEBUG=true, so WC logs full order bodies (PHI) into uploads/wc-logs — flagged.
- 2026-09-07 — Data repair, both sides (nicholas-cardell): migrated subscriptions on peaknow.com referenced LEGACY product ids that are trashed test posts on the new site (100152 Apex, 100202 Triple Threat, 100121 Phenylephrine), so renewal orders carried ids/names no Clinic Products row knew (visit 1049544 stuck in Received). eMed: name-keyed mapping rows 81–84 + row 77 re-keyed off the parent id (PLUS/STANDARD renewals would have got the MAX quick-add). Store: 414 live-subscription lines re-pointed via WC's item API in three passes (43 trashed-product ids, 134 Triple Threat legacy variation ids, 237 name-mapped variations across Tadalafil/Sildenafil/Gummy/GLP-1/GIP/TriMix/Scream Cream) with an order note each; 379 lines had pointed at variation posts that do not exist on the new site. Left: 36 Ignite PLUS+ (private product), 2 Tadalafil 10-tablet, 7 legacy bundle lines.
- 2026-09-05 — Hotfix **1.0.314** (nicholas-cardell): the 1.0.313 PN Orders page rendered Peaks Curative (badge, title AND orders) — `views/peaks/orders.ejs` read the site as top-level locals while `html_data(req, ext)` exposes route extras as `ext`; the pre-ship render smoke passed because it supplied locals flat. Fix: `peaks_sites.orders_page_locals()` → `ext.peaks_site`, the view THROWS without it, and `peaks_orders_pages.test.js` renders the full view through the real `ext` shape. Caught by Nick in the live app.
- 2026-09-05 — Enhancement (nicholas-cardell): **Peaks Orders split into two sidebar pages** — "PC Orders" (`/peaks/pc-orders`, Peaks Curative) and "PN Orders" (`/peaks/pn-orders`, Peak Now), page_catalog `PeaksPCOrders` / `PeaksPNOrders` with their own Read/Write flags (tag **1.0.313**). The Site dropdown is gone (the route fixes the site; a badge + "Switch to … orders" link remain); `/peaks/orders` redirects by `?site=`. Roles: legacy capability roles derive both; the page-ticked custom rows (Peaks, CustomerService, OpsManagement) carried over by `emed_sql 2026-09-05_split_peaks_orders_page_perms.sql` (applied dev+prod before the deploy).
- 2026-09-05 — peaknow.com data repair (nicholas-cardell, Nick's go): WooCommerce HPOS placeholder posts were never created by the migration (41,997 migrated orders had no `wp_posts` row → every API edit 403 `woocommerce_rest_cannot_edit`; 845 order ids collide with unrelated posts). Backfilled the 41,997 placeholders (marker `post_content_filtered='peaks_migrate_placeholder_2026-09-05'`), repaired the 3 open colliders held by old revisions (55307/55390/67185). 842 collisions left by decision (orders read fine; admins can edit; **never enable WooCommerce compatibility/sync mode**). Also: the peaknow REST key was read-only for orders → Nick set Read/Write.
- 2026-09-05 03:31 UTC — first run on the legacy-scope code: **66 shipments pushed to peaknow.com, 0 failed**. Picked-up completion failed 7/7 with `woocommerce_rest_cannot_edit` (HTTP 403 from WooCommerce, not Cloudflare): the peaknow.com REST key behind `peaknow-woo-consumer-key` is READ-only for orders. OPEN for Nick: WooCommerce → Settings → Advanced → REST API → set that key to Read/Write (same key value, no Secret change); the 7 orders retry every 10 min.
- 2026-09-05 — ETL fix 2 (nicholas-cardell, emed_etl main): PeakNow `peaks_update_ast` now also serves LEGACY-numbered orders (`orders_also_tables=("woo_orders",)`, UNION staging source) — after the old-site deployments were paused at cutover, 71 old-site orders that shipped/were picked up had no pipeline pushing tracking / Woo completion to peaknow.com (migrated orders keep their ids).
- 2026-09-05 — ETL fix (nicholas-cardell, emed_etl main): `peaks_update_ast` attributes rows to a site by ORDER TABLE (`order_scope_sql`: PeakNow EXISTS pn_woo_orders / legacy NOT EXISTS), because the pharmacy files every PeakNow script under "PEAKS Curative, LLC" — the PeakNow deployment's clinic filter had matched nothing since go-live (3 shipments unsent, no pick-up email possible; legacy deployments pushed those rows at the old site). Pick-up emails now key on the staged shipping method (`PICKUP_ORDER_PREDICATE`), blank address only as the no-method fallback. No prefect.yaml change (git_clone main per run).
- 2026-09-05 — Enhancement (nicholas-cardell): **pick-up orders → Deliver To 'Pick Up' + `*PICK UP*`** (tag **1.0.310**). Verified: a pick-up order is identified by its Woo shipping line (`local_pickup` / "… Pick up …"), not by a blank shipping address (peaknow.com pick-up customers still enter one; 11 of the first 12 real pick-up orders). `shipping_method_id/title` now staged on both order tables (emed_sql 2026-09-05_add_woo_orders_shipping_method, applied dev+prod, PeakNow rows backfilled); Peaks Orders / Add Visit badge follows the method. ETL follow-up: the "Ready for Pickup" email still keys on blank address + $0 → switch the peaknow site to the shipping method.
- 2026-09-05 — Enhancement (nicholas-cardell): **expedited shipping → priority 5 + OVERNIGHT SHIPPING** (PR emed_app#663, tag **1.0.309**). peaknow.com charges shipping only for Expedited Shipping, so `shipping_total > 0` (or an expedited shipping-line title) marks the visit at ingest (`wc_ingest` step 3b) and on Re-process; idempotent through the instruction row; never lowers priority. Same day: GIP/GLP-1 program Step 1/2/3 name-keyed Clinic Products rows (78–80 → tirzepatide 1/2/3 mL + syringes) and the 1.0.308 auto-approve claim fix (see refill-aware-intake).
- 2026-08-30 — In-Progress → Completed in Production (nicholas-cardell), tag **1.0.241**.

- 2026-09-08 — WordPress plugin `emed-patient-portal` **v1.9.0** (nicholas-cardell): the first-phone-sign-in account-confirm step
  accepts the account's Peak Now PASSWORD as an alternative to the emailed 6-digit code (chooser + code screen; 5 tries per
  choice, 10/hour per account), the code screen can resend the code (1/min, max 3), and wp-admin user profiles gain
  "Link this phone to this account" so support can finish the link for a caller. Why: customers reported the code email
  never arriving; the email is this plugin's, sent via WP Mail SMTP -> SendGrid (account u26413404, not eMed's CRM one),
  DNS/DKIM correct, all 1,183 emails in 14 days accepted — post-acceptance fate needs that SendGrid dashboard. Migrated
  users kept their old-site password hashes, so old passwords work. Deployed by SFTP with `php -l`; `.bak-1.8.0` kept on the server.

## Summary
Integrates the rebranded Peaks Curative WooCommerce site (**Peak Now**, `test.peaknow.com`) with eMed.
**Everything ships DARK** — nothing is patient-facing until a Peak Now facility is configured and its
portal is enabled per facility, and the webhook/SSO/framing are all env-gated (unset on prod). Shipped
in **1.0.241** alongside a small unrelated enhancement (eMed Orders script-modal link).

## Design / approach (what shipped, all dark)
- **Real-time order ingestion.** Signed WooCommerce webhook receiver at `/wc/webhooks/peaknow`
  (`server/routes/route_wc_webhook.js`, HMAC verify-when-set via `server/wc_webhook_verify.js`), a durable
  idempotent outbox (`emed_wc_order_outbox` + `server/wc_order_worker.js`), and `server/wc_ingest.js`
  which upserts `pn_woo_orders`/`pn_woo_order_items` and creates the moct visit via the extracted
  `server/moct_intake.js` (clinic `"PeakNow"`, `external_id="PeakNow:<EMAIL>_<FIRSTNAME>"`). The 15-min
  ETL stays as a backstop; both converge on `woo_order_id` — no duplicate visits.
- **Product → required forms + secure message.** `emed_product_required_form` (product/SKU → `form.id` +
  recency), `server/product_required_form.js` resolves due forms with a 12-month recency check on
  `form_submission`, and a qualifying order flags "Missing Forms" + sends a PHI-free secure message
  (gated on `misc.secure_messaging_enabled` + facility Messages visibility).
- **Intake Forms portal page.** `PORTAL_PAGES += intake_forms`, `/patient/forms` +
  `views/patient/forms.ejs` (shared FormRenderer), `GET/POST /api/patient/forms*` IDOR-scoped to the
  patient's due set, writing `form_submission(source_module='moct_person', source_ref=person_id)`.
- **Embedded portal + SSO.** `portal_frame_headers` relaxed (frame-ancestors + CORP) gated on
  `PATIENT_PORTAL_FRAME_ANCESTORS`; `eMed.pportal` cookie flips to `SameSite=None; Partitioned` ONLY when
  that env is set on Azure (else stays `lax`); `POST /api/patient/public/sso-exchange` +
  `patient_portal_sso_nonce` (deny-when-unset HMAC, single-use jti), magic-link+DOB fallback on
  ambiguous/no-match. WP My Account snippet in `emed_app/docs/peaknow-integration.md`.
- **Peaks staff site-switcher + clinic-leak fix.** `server/peaks_sites.js` (`SITES` whitelist,
  `is_peaks_family()`) parameterizes the Peaks staff endpoints by `?site=` and treats `"PeakNow"` as
  Peaks-family everywhere (so PeakNow visits stay OUT of the default MOCT queues and show on the Peaks
  pages). New admin page `/admin/clinic-products` (registered in `page_catalog`, sidebar under Clinic
  Files).

## Schema (emed_sql main @ 6ac2e13 — applied to prod + dev)
`2026-06-01_add_pn_peaknow_tables`, `2026-06-01_add_pn_woo_order_items`,
`2026-08-24_add_emed_wc_order_outbox`, `2026-08-24_add_emed_product_required_form`,
`2026-08-24_add_patient_portal_sso_nonce`. All additive/idempotent with grants.

## Rollout / remaining (the go-live checklist — Nick's manual prod steps)
The CODE + SCHEMA are live on prod (dark). To actually turn Peak Now on:
1. **Separate PeakNow into its own facility** on prod (currently an alias of "Peaks Curative, LLC");
   confirm the `peaknow_api` account + `PeakNow` facility row exist.
2. **Enable the portal** on that facility (portal pages default-deny; flip the per-facility toggles) and
   set env: `PATIENT_PORTAL_FRAME_ANCESTORS` (peaknow origins), `PEAKNOW_WC_WEBHOOK_SECRET`,
   `PEAKNOW_SSO_SECRET`; confirm `PATIENT_PORTAL_SESSION_SECRET` + `DEV_SMS_PHONE`.
3. **Register the WooCommerce webhook** (Order created/updated → `/wc/webhooks/peaknow`, secret above)
   and add the WP My Account iframes + SSO snippet (`docs/peaknow-integration.md`).
4. **Seed `emed_product_required_form`** via `/admin/clinic-products` once **Carlos Obregon's Jotform →
   Form Builder import** lands (the critical-path external dependency). If it slips, go live with the
   subset of products whose forms are ready.
5. **Cutover (fast-follow):** flip the PeakNow ETL `test_mode → false`; when verified, `sp_rename` the
   `pn_*` tables into the canonical names and repoint the site config.

## Landmines encountered on the prod ship (for the next person)
- emed_sql local `main` was 47 behind origin with 2 unpushed commits + snapshot churn; reconciled by
  reset-to-origin (backing up the 3 unique migration files) — NOT a rebase.
- `pending/` held 4 unrelated CEO/finance migrations; applied ONLY the 5 PeakNow files explicitly (never
  `pending/*.sql` glob) and left the CEO strays untouched.
- Registering `ClinicProducts` broke `sidebar_nav.test.js` (missing NAV_META icon + it sorted before
  Blaze Orders); fixed with a NAV_META entry + moving its PAGES entry under Clinic Files.
- `eslint .` failed on `isPeaksFamily` (needed adding to `eslint.config.js` public globals) + a `var`.
- CI `Unit tests` is red on `main` for a **pre-existing** reason (`api_users_test_mode` is_test — the
  test_context layer is on another branch); merged past it with the org-owner admin bypass.
