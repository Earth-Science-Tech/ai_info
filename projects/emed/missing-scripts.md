# Possible Missing Scripts page (`/admin/missing-scripts`)

**TL;DR:** An admin tool that surfaces eMed-signed prescriptions that never reached /
were never confirmed at the pharmacy, and lets staff reconcile them. Two detection
modes: **(1) Transmission failures** — scripts eMed never successfully transmitted
(keyed off `emed_liberty_write_log`); **(2) Not received at pharmacy (orphans)** — signed
scripts with no pharmacy linkage (no `tag_rx`, no `moct_order_tracking`, no
`moct_script_link`). Staff **link** an orphan to the pharmacy script that fulfilled it
(writes `moct_script_link`; the ETL applies the tag on its next run → tracking flows to
the clinic), or **dismiss** a reviewed false-positive. There are bulk accelerators for
both linking and dismissing. Permissions: `View_Menu_Missing_Scripts` (read),
`Write_Redrive_Scripts` (re-send), `Write_Link_Scripts` (link + dismiss).

Files: `emed_app/server/missing_scripts.js` (all logic), `server/routes/route_missing_scripts.js`
(`/api/missing-scripts/*`), `views/admin/missing-scripts.ejs` (whole UI). SQL:
`emed_sql` migrations `2026-07-29_add_moct_script_link.sql`,
`2026-07-30_add_moct_orphan_dismissal.sql`, `2026-07-29_fix_refill_moc_rx_tagging.sql`.

---

## Why the pharmacy mirror is NOT the delivery signal

The Liberty mirrors (`{rxcs,mmed,mdvo}_rxqFullOrder`) only hold **processed** scripts (rows
with a real Liberty `ScriptNumber`); the ETL even DELETEs escript-only rows. A
successfully-delivered new script legitimately does **not** appear in the mirror until the
pharmacy imports/fills it (days later). So "absent from mirror" massively over-reports.

- **Tab 1 (Transmission failures)** keys off **`emed_liberty_write_log`, per-drug.** Every
  sign submits via `liberty.js api()` and is logged (`kind='sign_prescription'`,
  `ref_type='drug_rx'`, `ref_id=<moct_drug_rx.id>`, `outcome IN ('success','failure')`).
  "Delivered" = a success row exists for that `drug_rx`. The one gap the durable
  [outbox]([[project_liberty_write_outbox]]) can't catch is `NEVER_SENT` — signed but
  `api()` was never called (nothing to enqueue). See `webhook_system.md` /
  `liberty-api-callback-contract.md` for the write path.

## The linkage gap Tab 2 exists to fix

Even when a script IS at the pharmacy, the **eMed↔pharmacy link is only ~70% reliable** and
is worst for **Externally Prescribed** GLP-1 orders (Valhalla Vitality) and refills. Tags
(`tag_moc`/`tag_rx`) are set by ETL procs `usp_etl_{rxcs,mmed,mdvo}_rxqFullOrder_metadata`,
which for new scripts depend on the pharmacy capturing the eMed PDF's `{[META][MOC][RX]}`
into a NOTE — unreliable for auto-flowed externally-prescribed scripts. **Dominant real
cause:** the pharmacy REJECTS the eMed script (e.g. Tirzepatide sig/notes rules) and
**re-keys it via BLAZE**, a fresh script carrying NO eMed tag → the eMed order is orphaned,
the clinic gets no tracking. (A second, now-fixed cause was refill mis-tagging — see
[[project_refill_tagging_fix]].) So the orphan list is the **real** missing-tracking
worklist, not noise.

## Linking — `moct_script_link` (the fix mechanism)

An operator picks the pharmacy `ScriptNumber` that actually fulfilled an orphan; the app
writes a row to the eMed-authored table **`moct_script_link`** (`pharmacy, script_number,
fill_number → visit_id, rx_id, clinic_order_id`; UNIQUE `(pharmacy, script_number,
fill_number) WHERE is_invalid=0`; grants SEL/INS/UPD `emed_app`, SEL `emed_etl`). An
**additive join block** in the 3 metadata ETL procs (mirrors the `moct_refill_lut` block)
stamps `tag_moc/tag_rx/tag_order` onto the matching mirror row on the next ETL cycle; then
`usp_etl_moct_order_tracking` flows tracking → the public Script API serves it → the clinic
sees tracking. **Linking sends nothing to any pharmacy** — it only records the mapping.
`create_link` **UPSERTs** on the unique key. "APPLIED" ⇔ mirror `tag_rx == moct_script_link.rx_id`
(the "Linked scripts" tab shows APPLIED vs PENDING so operators watch links flip after ETL,
~15–60 min).

## Fuzzy drug matching

eMed names differ from Liberty's (`Insulin Syringe` vs `INSULIN SYRG MIS 1ML/31G`;
pharmacy names are by **concentration**, e.g. `TIRZEPATIDE 15MG/ML SOLUTION`, so the eMed
dose is invisible on the pharmacy side). `drug_score(a,b)` normalizes (strip strengths/units,
expand abbreviations, drop stopwords) and scores token Dice + an active-ingredient boost.
Thresholds: ≥0.6 strong, ≥0.3 partial. Used to rank Link-modal candidates and to power the
bulk auto-matcher.

## Bulk auto-match (link accelerator)

`suggest_auto_links` proposes high-confidence 1:1 links: an orphan with exactly ONE
**unclaimed** same-patient pharmacy script within ±4 days that strongly drug-matches. A
script can fulfill only one order, so candidate collisions are handled: same-drug duplicate
orders collapse to the closest (the rest are left to dismiss); different-drug collisions go
to manual. Operator reviews the list, unchecks any, and links in one batch (`/link-bulk`,
250-row client chunks, audited per link).

## Dismissing false-positives — `moct_orphan_dismissal`

Not every orphan is fixable: dummy/test data, won't-be-fulfilled, and **excess duplicates**.
Dismissing writes a **soft, reversible** row to **`moct_orphan_dismissal`** (`drug_rx_id,
visit_id, reason, note, app_user`; UNIQUE `drug_rx_id WHERE is_invalid=0`; grants SEL/INS/UPD
`emed_app`). Dismissed orphans drop out of `list_orphans` + the auto-suggesters; a "Show
dismissed" toggle + Undo restore them. Test orders (patient name contains "test"/"testing";
`moct_visit.is_test` is NOT reliably set for them) are hidden by default with an
"Include test orders" toggle.

### Bulk auto-dismiss duplicates (dismiss accelerator)

`suggest_auto_dismissals` proposes **provable excess-duplicate** orphans for one-click batch
dismissal (`/dismiss-bulk`). An orphan qualifies iff the **same human** already has a
**different order for the exact same drug+dose+fill that is linked** to a pharmacy script,
AND the orphan is **not itself linkable** (no unclaimed script it should link to instead).
Rationale: the pharmacy filled that drug once (the linked sibling); this extra identical copy
can never be fulfilled. **Safety keys (do not weaken these):**

- **Dose-INCLUSIVE, exact drug key** (`drug_strict_key`, e.g. `TIRZEPATIDE50MG`) — NOT the
  fuzzy/dose-stripped link key. A `75mg` order must never be dismissed as a dup of a linked
  `100mg` (that would hide a genuine missing script). Dose-escalation cases are spared.
- **Name+DOB patient key** (`person_key`), NOT `person_id` — the same human routinely has
  several `moct_person` records, and `person_id` would miss cross-record duplicates.
- **Fill-aware** — a refill (fill>0) is never a dup of the original (fill 0).
- **Not-linkable gate** — if an unclaimed matching pharmacy script exists, prefer linking.

## Key gotchas

- **Pending-link window (Link modal):** a candidate's "already linked?" state must consider
  `moct_script_link` (the `link_rx` / `claimed_rx` flags from `list_patient_scripts`), not
  only the mirror `tag_rx` — the ETL doesn't stamp `tag_rx` for ~15–60 min after linking, so
  a just-linked script would otherwise look available and get silently re-assigned (the modal
  now dims claimed candidates and confirms before re-assigning).
- **Deploy topology:** the feature is shipped via **dev-SHA tags** (see
  [[reference_branch_model]]); `main` is kept level with `dev` after each release
  (fast-forward). Prod DB = `liberty_link_stage`. Validate read paths with
  `DB_NAME=liberty_link_stage node scripts/run_query.js`.
- **Everything read-only except link/dismiss/redrive.** Link and dismiss send nothing to any
  pharmacy; only `Write_Redrive_Scripts` re-transmits (guarded + confirmed + audited).

_Deep history + exact tag numbers live in the team's private memory; this doc is the durable
shared summary._
