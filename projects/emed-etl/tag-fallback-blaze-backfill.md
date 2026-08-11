# Tag-Fallback: Blaze backfill incident (2026-08-07..11) and fix

> **2026-08-11 ROOT CAUSE (supersedes the share theory below):** the hangs were
> **catastrophic regex backtracking**, not the image share. RXCS script 377546's
> hardcopy (`124179.pdf`) is a 4-drug Blaze batch whose 4th META tag is truncated
> by the signature block (`{[META][MOC:][BLAZE:174058]` — no closing `}`).
> `meta_tag._META_TAG_RAW`'s ambiguous `(?:[^{}]|\s)*?` went exponential on the
> unclosed opener → `find_meta_blocks` CPU-pinned for hours, deterministically, on
> that one batch (confirmed with `faulthandler` on the job server). Fixed in
> emed_etl PR #62 (`\{\[META\][^{}]*\}` + regression test). Share reads and pypdf
> parses were verified fast. Lessons: never put an ambiguous alternation under a
> quantifier (ReDoS); a hang is invisible to failure-count bail-outs; a spinning
> regex holds the GIL, so only subprocess isolation can timeout-guard it; and
> Prefect's deployment concurrency limit leaks under hung runs (45 concurrent
> despite limit=1 + CANCEL_NEW).

## What happened

The `Tag-Fallback-{RXCS,MMED,MDVO}` deployments run Blaze multi-tag batch
disambiguation (`flows/emed_etl/blaze_disambiguation.py`) + note-fallback tagging
every 10 minutes. From 2026-08-07 ~13:00Z, RXCS run durations snowballed from
~112 min to **17 hours** by that evening; on 2026-08-10 the pile-up recurred
(~18-20 concurrent runs) until a mass-cancel at 20:50Z. The last completed run
spent 2h17m examining 200 batches and stamped **zero** tags, ending with a Liberty
TCP reset that instantly failed the remaining 155 batches. The RXCS schedule was
deactivated on the Prefect server as an emergency stop.

## Root causes (compounding)

1. **No examined-stamp**: unresolved batches re-qualified every run, iteration was
   deterministic (ScriptNumber asc) and `max_batches` truncated — every run re-read
   the SAME first N batch PDFs; the other ~12.6k batches were never reached. The
   backfill could not complete at any cadence.
2. **No deployment concurrency limit**: runs >10 min on a 10-min schedule stacked
   without bound; each concurrent run slowed the rest (Liberty SQL + UNC PDF share
   contention), which stacked more runs — a self-amplifying snowball.
3. **Per-batch Liberty connections**: dominant per-batch cost, and (via ODBC
   pooling) they turned one TCP reset into a run-long cascade of instant failures
   ("Invalid cursor state" at SQLPrepare = dead pooled connection being reused).

## The fix (emed_etl PR #61 + emed_sql migration)

- `blaze_checked_date` examined-stamp on `{prefix}_hardcopy_tag_log` (emed_sql
  migration `2026-08-10_add_blaze_checked_date_hardcopy_tag_log.sql`, commit
  7cb2f05). Examined batches are skipped for a recheck window
  (`emed_etl_flag.blaze_disambiguation_recheck_days`, default 30 days). The skip
  is **batch-level in Python**, never row-level in SQL — a partial sibling set can
  force wrong matches (the complete-batch rule in the module header).
- One **bulk** Liberty hardcopy-path lookup per run instead of per batch.
- Abort the batch loop after 5 consecutive failures (dead connection).
- Progress logging every 50 batches (previously silent for hours).
- `prefect.yaml`: `concurrency_limit: {limit: 1, collision_strategy: CANCEL_NEW}`
  on all three Tag-Fallback deployments — an overdue tick is cancelled, not queued.

## Gotchas worth keeping

- **A >interval flow with no concurrency limit is a time bomb.** Any Prefect
  deployment whose runtime can exceed its schedule interval needs
  `concurrency_limit` (usually 1 + CANCEL_NEW), or load makes it self-amplify.
- **pyodbc pooling hands dead connections back** after a network reset — a
  reconnect-per-item loop does NOT recover. Either bulk the work onto one
  connection or bail out after consecutive failures.
- **Redeploying a deployment re-activates its schedule** from prefect.yaml — if a
  schedule was manually deactivated as an emergency stop, `prefect deploy` turns
  it back on.
- Yield remains crosswalk-bound (~356 genuine `emed_drug_liberty_xref` rows for
  RXCS): the fix makes the backfill *finish*; it does not raise the match rate.

## Rollout state (SHIPPED 2026-08-11 ~02:30Z)

- emed_sql migration: applied to **both** `liberty_link_dev` and
  `liberty_link_stage` (`apply_migration.py --db both`, emed_sql commits 7cb2f05 +
  151115a; file now in `migrations/applied/`).
- emed_etl PR #61: **merged** to main (merge commit 6ae59e7).
- `prefect deploy` run for all three Tag-Fallback deployments: concurrency_limit=1
  + CANCEL_NEW confirmed on the server, schedules active again (RXCS had been
  manually deactivated during the incident; the deploy re-activated it).
- `emed_etl_flag` at incident time: `blaze_disambiguation_enabled=1`,
  `max_batches=200`, `lookback_days=3650`. With the fix, `max_batches` can go back
  up once a supervised run confirms sane per-batch cost.
