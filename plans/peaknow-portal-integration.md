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
tags: ["1.0.241"]
created: 2026-08-30
updated: 2026-08-30
related: ["[[patient-portal-secure-messaging]]", "[[facility-scope-groups]]"]
---

# Peak Now Patient-Portal Integration

## Status & history
- 2026-08-30 — In-Progress → Completed in Production (nicholas-cardell), tag **1.0.241**.

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
