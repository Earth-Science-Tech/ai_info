# Billing–Pricing Integration (FUTURE feature) — Requirements Notes

**Status: NOT BUILT.** This file is the running requirements backlog for the future automated
billing-pricing feature, collected from Mario Tabraue's directives as they are shared.
**Any Claude instance: append new billing-integration details Mario shares to this file** —
it is the reference the eventual feature will be planned from.

**Last updated:** 2026-07-06

---

## The vision (Mario, 2026-07-05/06)

1. A **universal (Standard) price list** — the Product Catalog — is used for ALL account
   negotiations, and most accounts are billed according to this standard pricing.
2. Some accounts negotiate **Special Pricing on certain items only**. They receive a price
   sheet for those items; **everything else remains at standard pricing**.
3. When the billing feature is created, ALL pricing (standard + special) will be stored in
   eMed, and the billing module will follow defined flows to return pricing to the proposed
   **invoice / dispense report** that gets billed.
4. The catalog is the **source of truth for billing/pricing** — the same source that produces
   the customer-facing price sheets. No parallel/duplicate price stores.

## Pricing resolution (future flows)

- Check for **Prescriber-specific** price lists, then **Clinic-specific** lists, then fall
  back to the Standard catalog price. (An engine implementing this shape already exists —
  see "Existing engine" below.)
- Special pricing sheets carry a **proposal → final lifecycle**: a sheet is marked *proposal*
  or *final*; **final requires an effective date** so billing knows when the new pricing takes
  effect. A proposal agreed without changes is finalized (with effective date) at that time.
  Both states produce a **PDF** shared with the customer.
- Special pricing is matched to a **facility** (existing customer, `emed_facility.id`) or a
  **CRM lead** (`emed_crm_lead.id`, prospect not yet a customer) that converts later.
- Sheet supersession/versioning semantics (which final sheet wins on a given invoice date)
  are deliberately **undecided** — define them in the billing project.

## Unit-basis nuance (Mario, 2026-07-06) — CRITICAL

Pricing is **not uniform in its unit basis**:
- Sometimes priced **by the vial size** (e.g., per 1 mL / 2 mL / 5 mL vial), and
- Sometimes priced **by the total MGs being dispensed** (total API quantity),
- (Catalog data also contains per-each, per-jar, per-kit, per-troche, per-syringe,
  per-bottle(30 ct), per-pack, per-set bases — 13 distinct `price_basis` values in the
  2026 seed data.)

**Many more rules are coming** for how drugs are billed in accordance with the price list
AND the dispensed **quantity**. Expect per-basis quantity math (e.g., Liberty `Quantity` ×
metric price vs flat per-item price). Do NOT hardcode assumptions about a single pricing
basis anywhere.

## Checks and balances

The billing integration will include **particular checks and balances for accuracy**
(details to come). Context: today billing staff price manually and data-entry prices are
often inaccurate because speed trumps accuracy at intake — the whole point of the feature
is accuracy without human intervention. Design for validation/verification steps, not just
lookup.

## Existing engine + invoicing facts (verified against dev @ 59535fc, 2026-07-05)

- `server/billing.js` `resolve_price_plan()` already walks **Prescriber → Clinic → Standard**
  over `emed_price_plan` / `emed_price_plan_prescriber` (keyed by Liberty
  `DoctorId VARCHAR(50)`) / `emed_price_plan_clinic`, **per-pharmacy**, with per-drug
  item/metric prices, AWP/ACQ markup formulas, dispensing fees, min/max clamps.
- That engine powers the shipping **pre-auth estimates** today. **Invoicing bypasses it**:
  `invoice.create_invoice` uses the client-sent `final_price` verbatim ("Manual Entry") and
  the invoicing UI always sends it.
- The future integration must decide whether the new catalog/special-pricing store **feeds**
  `emed_price_plan_drug` or **replaces** the engine — undecided; both doors kept open.
- Key compatibility (already baked into the planned catalog schema): Liberty drug identity is
  `DrugId VARCHAR(50)` (NOT `GID`); pharmacy codes are an **open set** (`rxcs`|`mmed`|`mdvo`|
  future — never hardcode two); clinic identity anchors on `emed_facility.id` (clinic strings
  are display snapshots only).

## Prerequisite module (planned, ON HOLD pending team review — week of 2026-07-06)

The **Price Sheet Builder** module (Product Catalog + Special Pricing + sheet PDF + facility/
lead matching) is fully planned but not built. Spec: Mario's
`Documents\ETST\Price Sheet Builder Spec v2.md` (v2.1). Scope deliberately EXCLUDES all
billing flows above — schema seams only (`liberty_drug_id`, `liberty_pharmacy`,
`effective_date`, `final_price` snapshot, `scope_facility_id`/`scope_lead_id`).

## Data provenance note

The 849-row 2026 facility pricing seed was verified row-by-row against the source PDF
(2026-07-05). Lesson recorded: **the price list is thoroughly reviewed — entries that look
similar or duplicated are almost always genuinely distinct products** (e.g., "PT-141 Combo"
vs the plain composition troche). Never dedupe or "correct" list data without proof.
