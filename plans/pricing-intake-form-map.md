---
title: Pricing → Intake Form Map (global product → intake-form map + product images)
slug: pricing-intake-form-map
status: In-Progress
project: multi
branches:
  - emed_app: feat/pricing-intake-form-map (merges into dev — depends on Mario's Affiliate Portal PR-A/PR-B, dev-only today)
  - emed_sql: feat/pricing-intake-form-map (migrations/pending/2026-09-17_add_emed_catalog_required_form.sql — dev-applied, PENDING PROD)
developers:
  - nicholas-cardell
  - mariotabraue (Affiliate Portal owner — the first consumer; template clone + quick-adds stay his)
prs: []
tags: []
created: 2026-09-17
updated: 2026-09-17
related: []
---

# Pricing → Intake Form Map

## Status & history
- 2026-09-17 — Not Started → In-Progress (nicholas-cardell): schema applied to dev, module + page + tests built and
  verified on the dev DB against Mario's test affiliate facility (1967).

## Summary
The Affiliate Portal (Mario, `feat/affiliate-portal`, as-built in `emed_app/docs/plans/affiliate-portal.md`) creates
ordinary MOCT visits from sale lines keyed by **Pricing Product Catalog id**, and the intake-form gate decides which
questionnaires the patient owes from **Clinic Products** (`emed_product_required_form`) — a **per-facility** map keyed
to one store product / catalog row at a time, cloned onto every affiliate facility from a template facility. That is
hard to navigate and cannot express the thing that is actually true: *every strength and size of a drug needs the same
intake form(s), for every portal*. This feature adds the **global** map and the page to maintain it:

- **Pricing → Intake Form Map** (`/pricing/form-map`): the catalog grouped **one row per product** (no strength / size /
  price / unit columns), multi-select → bulk **Add forms / Replace forms / No form required / Clear mappings**, per-pill
  recency / required edits, and the product's **stock image** (Mario's `emed_price_catalog_image`, one upload covers
  every size).
- The map feeds the existing resolution engine unchanged, so Affiliate Portal visits pick it up with **zero changes to
  Mario's code**; later, the MOCT clinic portal can order by catalog id and inherit the same rules.

## Design / approach
**Storage — `dbo.emed_catalog_required_form`** (emed_sql `feat/pricing-intake-form-map`, migration
`2026-09-17_add_emed_catalog_required_form.sql`): `product NVARCHAR(200)` (= `emed_price_catalog.product`, CI collation),
`form_id INT NULL`, `recency_months` (default 12), `is_required`, `label`, `sex_restriction` (column reserved, same
vocabulary as Clinic Products, **not yet on the page**), mandatory audit fields, filtered UQ on `(product, form_id)`
live rows (NULLs compare equal → at most one live "no form" row per product), grants to `emed_app`. No trigger (mirrors
`emed_product_required_form`).
- Keyed by **product NAME on purpose**: a size added to the catalog later inherits the mapping unasked. On dev the 988
  catalog rows collapse to **408 products**; 12 product names span two category pairs (Finasteride tablet, Dermaglow
  Cream, Cyanocobalamin…) — those are grouped by name (same drug, same form) and the page shows every pair.
- `form_id NULL` = explicit **"no form required"** register row (the product is COVERED, asks nothing). A product with
  **no row at all is a GAP**: `advance_ready_visit` holds the visit with `no_rule` (Clinic Products convention kept).

**Resolution seam — `server/catalog_form_map.js` → `product_required_form.list_for_facility`:**
- `rows_for_resolution()` expands each global row to one Clinic-Products-shaped mapping per **live catalog id**
  (`JOIN emed_price_catalog ON product`). Global rows are **catalog_id-keyed only** (`product_name` null — a store
  line's plan name never matches them) and carry **no `quickadd_ids`** (prescription presets are per size and remain a
  Clinic Products / template concern), so every quick-add-filtered consumer (`auto_prescribe_for_visit`, refill waiver,
  `required_forms_for_visit_drugs`, `affiliate_qr.list_products` "mappable") ignores them by construction. 30 s cache,
  invalidated on every write.
- `list_for_facility(fid)` = the facility's own rows FIRST (id DESC, unchanged) + global rows **minus any catalog id the
  facility maps itself** (an own row shadows the global one, whatever form it names). A map lookup failure degrades to
  own rows — never blocks an order.
- Consequence to know: `_order_required`'s `configured` (= "this facility uses the gate") is now true wherever global
  rows exist. Only Peaks sites (already configured) and provider-claimed visits (affiliates — desired) ever reach that
  branch; every other clinic still returns `null` before it. Verified on dev: Peaks 1161 store lines (no catalog id)
  resolve exactly as before.
- `pricing.update_catalog` calls `on_product_renamed(old, new)` when `product` changes: rows follow the rename once no
  live size keeps the old name (a clash with a live row on the new name retires the old row). The page's **Orphans**
  card lists rows whose product left the catalog — the backstop.

**Page — `views/pricing/form-map.ejs`**, `page_catalog` key `PricingFormMap` (section pricing, read `View_Menu_Pricing`,
write `Write_Pricing`, `REQUIRES` / `WRITE_CAP` / `WRITE_ROUTES` entries), nav label "Intake Form Map", route in `app.js`,
`PERM_SCHEMA_VERSION` 25 → **26** (live sessions rebuild their perms; the link appears without re-login).
- Filter bar (category / subcategory / product search / market — defaults to **Human** / status — defaults to Active /
  affiliate / mapping state / image) + house data-table standard: sortable headers, funnel filters with
  sibling-narrowed counts (commented `gen_datatable` exception: selection checkboxes, editable pills, image control).
- Bulk bar over a selection SET that survives re-renders (`select all matching` spans the filtered list). The form
  picker offers published `category = 'Intake Form'` forms **plus uncategorized published forms** (prod's legacy
  "L3 - … - Peaks" questionnaires predate categories) labelled as such.
- API (`route_pricing.js`, all `Write_Pricing`, audited via `audit_logger.log_data_change`):
  `GET /api/pricing/form-map` → `{ available, products, orphans, counts, forms }`;
  `POST /form-map/assign { products:[name], form_ids:[id], mode: add|replace|none|clear, recency_months, is_required }`
  (products resolved to the catalog's own spelling — unknown names refused; forms must exist and be published; `add`
  drops the no-form marker, `none` retires the forms, `replace` = exactly these forms);
  `PUT /form-map/rows/:id { recency_months, is_required, label }`; `DELETE /form-map/rows/:id`;
  `POST /form-map/image { product, image_base64, mime_type, width_px, height_px }`; `POST /form-map/image/remove { product }`.
- **Images** reuse Mario's `pricing_images.set_image` with a NEW option `apply_to_product: true` (every live size of the
  product, any strength — beside his `apply_to_family` = same product + strength). Thumbnails come from the public
  `/api/public/pricing/img/<catalog_id>?v=<image_id>`; an `n/m` badge shows when only some sizes carry the picture.

**Tests:** `tests/unit/server/catalog_form_map.test.js` (grouping / orphans / counts, every `set_forms` mode and
validation, row edits, rename hook, image passthrough, and the `list_for_facility` shadowing + `resolve_required_forms`
through global rows), `pricing_images.test.js` (+2 for `apply_to_product`). Registry tests (`page_catalog`,
`page_registry`, `page_requires`, `sidebar_nav`, `write_gate`) pass with the new page.

## Rollout / remaining
- **Dev:** merge `feat/pricing-intake-form-map` into `dev` (it sits on top of Mario's affiliate merges); the migration is
  already applied to `liberty_link_dev`. Smoke on the dev slot: Pricing → Intake Form Map lists 408 products; assign a
  form; check `emed_catalog_required_form`; create an affiliate QR sale for a mapped product → visit lands in
  **Missing Forms** with that form due.
- **Prod (with the Affiliate Portal ship, not before):** the emed_sql migration ships through `push prod` (it is the only
  schema object; no data backfill). Code ships dark — until the table exists the module answers `[]` and the page
  shows the "table not on this database" banner. PERM 26 means a redeploy-time perm rebuild for live sessions.
- **Verified on dev (2026-09-17):** Arousal Melt Troche (8 sizes) → 2 forms; `product_required_form.resolve_required_forms(1967,
  [{catalog_id: 652}])` → both forms; an unmapped catalog id → `[]`; Peaks 1161 → own rows only; pill recency edit;
  pill removal; image upload → 8 sizes, thumbnail served; image removal. The example mapping rows on dev were left in
  place (Arousal Melt Troche → ED Injections Intake Form, 6 mo) — adjust or clear on the page.
- **Open / follow-ups:**
  1. `sex_restriction` on the page (column exists; the order-review rule reads it through `matched_mappings_for_lines`).
  2. A global **prescription-preset** twin (quick-adds per catalog row) so affiliate QR readiness stops depending on
     Mario's `template_facility_id` clone — today the template still supplies the quick-adds, the map supplies the forms.
  3. MOCT clinic portal moving to catalog-keyed order lines (then the global map covers it automatically).
  4. Mario: confirm the default form set for affiliate products and whether uncategorized "L3 - …" forms should be
     re-categorized as Intake Form in Form Builder.
- **Landmines:** never key global rows by store name (Peaks plan names would collide); never give global rows
  `quickadd_ids` (auto-prescribe would fire for every facility); an own Clinic Products row on a catalog id silently
  overrides the global rule for that facility — the page does not show facility overrides.
