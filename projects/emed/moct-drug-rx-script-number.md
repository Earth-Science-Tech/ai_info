# `moct_drug_rx.script_number` — when it's populated, and when it isn't

**One-line rule:** `moct_drug_rx.script_number` is **NULL for almost every first-time
prescription**. Do **not** use it to decide whether an Rx reached the pharmacy, or to look up the
Liberty ScriptNumber of a sent script. Resolve the ScriptNumber from the **ETL mirror**
(`view_emed_full_order`, or the per-pharmacy `view_{pfx}_full_order`) by **`RxTag = moct_drug_rx.id`**
(or `MocTag = moct_visit.id`).

## Why the column is almost always NULL

eMed does **not** learn the Liberty ScriptNumber when it sends an Rx. The flow is:

1. eMed generates the prescription PDF, stamps `moct_drug_rx.script_created`, and POSTs it to
   Liberty. Liberty **queues the PDF with no ScriptNumber** and returns an **empty body** (see
   [liberty-api-callback-contract.md](liberty-api-callback-contract.md) — a timeout is
   indistinguishable from success, so eMed can't read a number back even if it wanted to).
2. A **pharmacy tech** later opens the queued PDF and enters it into the Liberty pharmacy system.
   **That** is when Liberty assigns a ScriptNumber.
3. The number gets back to us only through the ETL: Liberty stores eMed's Meta tags on the script
   (`tag_moc` = visit id, `tag_rx` = `moct_drug_rx.id`), the ETL mirrors that into
   `{pfx}_rxqFullOrder`, and `view_emed_full_order` unifies all pharmacies as `MocTag`/`RxTag` →
   `ScriptNumber`. (`tag_rx`/`tag_moc` are indexed on each mirror table, so a lookup by RxTag is an
   index seek.) See [script-api-correlation-tags.md](script-api-correlation-tags.md) for how the
   Meta tags are written and correlated.

**So `moct_drug_rx.script_number` is populated only for eMed-INTERNAL "Refill"-button rows** — when
a Peaks/MOCT user clicks *Refill* on a prior script in eMed, the base ScriptNumber they're refilling
from is stamped onto the new row. First-time prescriptions never get one on the row.

## Measured (prod `liberty_link_stage`, 2026-08-18)

Of all signed `moct_drug_rx` rows (`script_created IS NOT NULL`, `is_invalid=0`):

| Scope | `script_number` populated | NULL |
|-------|---------------------------|------|
| All clinics | 6,368 (12%) | 45,248 (88%) |
| Helimeds (API refill user) | 20 (0.14%) | 14,067 (99.86%) |

The populated rows skew to `visit_type` `Generic`/`General` (eMed-internal refills), not first-time
orders. Meanwhile ~88% of Helimeds' signed rows **do** resolve a ScriptNumber via the `RxTag` mirror
linkage — the number exists, just not on the `moct_drug_rx` row.

## The gotcha that bit us

`/api/public/script-refill` **Option 1** (refill by `VisitId` + `DrugName`) filtered
`WHERE ... AND script_number IS NOT NULL AND script_number > 0`, assuming (per a stale code comment)
that "each matching row already has script_number, set when the original Rx was sent to Liberty."
That assumption is false, so Option 1 **404'd for ~88% of all scripts (99.86% of Helimeds')** even
though the prescription had been sent, dispensed, and had refills authorized — e.g. Helimeds visit
`1038986` / `moct_drug_rx` `1044855` → Liberty script `576210`, dispensed, 11 refills authorized, 0
used, but `script_number` NULL on the row.

**Fix (2026-08-18, branch `feat/script-refill-option1-scriptnumber`):** match on `drug_requested`
only, then resolve each matched row's ScriptNumber via `view_emed_full_order` by `RxTag`
(`moct_drug_rx.script_number` kept as a fast path). A matched row with no resolvable ScriptNumber
now returns a distinct **`409 { reason: "script_number_not_yet_assigned", retryable: true }`** — the
"pharmacy hasn't entered it yet / ETL lag" case — instead of a misleading 404. Pure resolver
`route_public.resolve_refill_targets()`; unit suite `tests/unit/server/script_refill_resolve.test.js`.

## Rule of thumb for future work

- Need "has this Rx reached the pharmacy?" or "what's its ScriptNumber?" → join the mirror on
  `RxTag = moct_drug_rx.id` (or `MocTag = visit id`), don't read `moct_drug_rx.script_number`.
- `moct_drug_rx.script_number` present = an eMed-internal refill's base number (a fast path), NOT a
  general "this was sent" signal. Its absence means nothing about whether the Rx was sent.
