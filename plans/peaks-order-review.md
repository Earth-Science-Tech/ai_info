---
title: Peaks order review lane (Needs Clarification before prescriber / pharmacy)
slug: peaks-order-review
status: Completed in Production
project: emed_app
branches:
  - emed_app: feat/order-review-lane
developers:
  - nicholas-cardell
prs: ["emed_app#669 (feat->main, merged 2026-09-05)"]
tags: ["1.0.311"]
created: 2026-09-05
updated: 2026-09-05
related: [peaknow-portal-integration, refill-aware-intake]
---

# Peaks order review lane

## Status & history
- 2026-09-05 — Not Started → In-Progress (nicholas-cardell): design agreed with Nick (rules in code, not the
  Pre-Clarification Gate; flag ALL weight-loss step orders and ALL TriMix orders for now, plus any checkout
  note); `server/order_review.js` + hook in `advance_ready_visit`; tests.

- 2026-09-05 — In-Progress → Completed in Production (nicholas-cardell): PR #669 merged (merge commit), tagged **1.0.311**, Azure deploy
  succeeded 04:54 UTC. Rules v1 live: weight-loss step (all), TriMix (all), customer note. 113 tests green across the intake suites.

## Summary
Some Peaks / PeakNow orders should be seen by Peaks STAFF before a prescriber or the pharmacy: the
customer may have picked the wrong weight-loss program step, TriMix orders may or may not carry the
reversal syringe/drug (new subscriptions do, single orders reportedly do not), and a customer note at
checkout is invisible to the pipeline. Instead of auto-advancing to Pending Consultation / Approved
Refills / Approved OTC, such a visit stops in **Needs Clarification** with an **Order Review** note
listing exactly what to check. Nothing else is skipped: quick-add prescriptions, refill detection and
the intake-form gate have all run by then.

## Design / approach
- **Rules in code** (`server/order_review.js`, `RULES` array; each rule = key, label, `test(order)` →
  detail strings). Mario's Pre-Clarification Gate was considered and rejected for this: it holds
  individual prescriptions at pharmacy submission (after signature), with DB-driven rules and the
  deliberately distinct "Held" vocabulary. These checks are order-level, pre-prescriber, and rare to change.
- **Hook**: `product_required_form.advance_ready_visit`, after "every line prescribed" and "no forms due",
  before the refill/OTC/consult classification. Every path funnels there (webhook ingest, portal form
  completion, staff Re-process). `review_before_advance` loads the staged order row (`line_items`,
  `customer_note`, `meta_data`), evaluates, and holds: guarded `UPDATE moct_visit … WHERE status='Received'`
  (OUTPUT … INTO — triggered table), `moct_notes` row type `Order Review`, the one-line visit note when
  empty (`Review: <labels>`, shows on the lists), history `Needs Clarification (Auto): <labels>`, status webhook.
- **Idempotent**: a visit with the auto history row is never re-held → staff workflow = review, then move
  forward manually OR set back to Received + "Re-process order" to let automation continue.
- **Fail-closed**: a review error leaves the visit in Received (`reason:'review_error'`); no staged order
  row = nothing to judge (advance continues, as before).
- Rules v1 (Nick 2026-09-05): weight-loss = name /GLP-1|GIP|tirzepatide|semaglutide|weight loss/ or product
  ids 2576/2577/19763/19765 (note names the plan step); TriMix = /tri-?mix/ (note says one-time /
  new subscription (scheme) / subscription renewal via `_wcsatt_scheme` + `_subscription_renewal`);
  customer note = non-blank `customer_note` quoted (≤1000 chars). Expected volume ≈ 15 of the first 91
  PeakNow orders (6 notes, 7 TriMix, 4 weight-loss).
- UI: `Needs Clarification` already exists everywhere (status options, list filter pills, prescriber views);
  the visit page's Notes card shows type `Order Review` with a terracotta "Review" badge.

## Rollout / remaining
1. Ship (no migration, no env). 2. Watch the first flagged orders with staff; tune rules later
   (e.g. skip TriMix renewals, or clear the weight-loss flag when the step matches the last fill).
