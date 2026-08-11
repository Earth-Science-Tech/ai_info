# Run-All-ETL: silent task failures + the 'None' last_id watermark bug

**Diagnosed 2026-08-11** (MDVO incident). Two compounding gotchas, both fixed — documented
here because either one can bite again in a different shape.

## Incident summary

`Run-All-ETL-MDVO` showed **Completed** on every run while
`usp_etl_mdvo_rxqFullOrder` had not executed since go-live (2026-08-03). Result:
`mdvo_rxqFullOrder` frozen at 26 rows for 8 days while `mdvo_rxqScriptTransaction`
kept syncing — new Meduvo scripts (e.g. ScriptNumber 1000027) existed in the
transaction mirror but never appeared in `view_mdvo_full_order` or
`moct_order_tracking`.

## Gotcha 1 — `str(None)` poisons the etl_type=2 watermark

`etl_metadata.last_id` is NVARCHAR. The metadata writer did `str(new_last_id)`, so a
run that ends with `total_rows == 0` and no prior watermark stored the **literal
string `'None'`**. That string is truthy, so the `if last_id` guard passed and
`int('None')` raised `ValueError: invalid literal for int() with base 10: 'None'`
on every subsequent run — deterministic, so Prefect's `retries=3` never helped.

**When it triggers:** an etl_type=2 table (`rxqShipment`, `rxqShipmentScriptNumber`,
`rxqQueue`, `rxqWorkflowLocation`) that is **empty at the source on first sync** —
i.e. a brand-new pharmacy tenant that hasn't shipped anything yet. Expect this
class of failure at every tenant go-live if running pre-fix code.

**Fix (2026-08-11, `fix/etl-metadata-none-lastid`):** `_update_etl_metadata` stores
NULL for a missing id; `_get_last_id` returns `int` or `None`, treating any
non-numeric stored value as "no watermark". Same fix applied to the legacy
`scripts/liberty_run_etl.py`, which shares the bug and could re-poison prod if run
manually. Prod rows cleaned by hand (`UPDATE etl_metadata SET last_id = NULL WHERE
last_id = 'None'`).

## Gotcha 2 — Prefect 3 does NOT fail a flow when submitted tasks fail

This is the part that generalizes beyond this bug (verified against Prefect 3.6.16
source):

1. **Flow state comes only from the flow function.** Unlike Prefect 2, task
   failures never influence the flow run's final state. If the flow function
   returns without raising, the run is Completed.
2. **A failed future inside `wait_for` doesn't raise on a direct call.** The
   downstream task is parked in `Pending(name="NotReady")` — not Failed — and a
   direct (non-`.submit()`) call then returns `None` without raising
   (`task_engine.py`: `result()` with neither `_return_value` nor `_raised` set).
3. **The `None` return value propagates the silence.** Later steps chained via
   `wait_for=<that None>` have no upstream dependency at all, so they run
   normally.

Net effect in `run_all_etl`: two failed `sync_table` tasks silently skipped the
`rxqFullOrder` proc, then the metadata proc / hardcopy tagging / `moct_order_tracking`
all ran anyway, and the flow finished green.

**Rule of thumb:** in Prefect 3, if a flow submits tasks and must fail when they
fail, it has to **resolve the futures itself** — `wait(futures)` then check
`future.state.is_completed()` (or call `future.result()`), and raise.

**Fix:** `run_all_etl` now waits on all sync futures after submission and raises
`RuntimeError` naming the failed tables before the stored-procedure chain, so a
sync failure = a red flow run, and the spine never builds on a partial mirror.

## How to spot a recurrence

- A tenant's `etl_metadata` rows with `date_modified` frozen days in the past while
  the flow runs green → some task is failing silently.
- `SELECT * FROM etl_metadata WHERE last_id = 'None'` should always return 0 rows
  post-fix; any hit means pre-fix code wrote to prod (check for stray manual runs
  of old `scripts/` code).
- Mirror table row counts diverging from their downstream product
  (`{prefix}_rxqScriptTransaction` growing while `{prefix}_rxqFullOrder` is static).

## Related

- Tenant onboarding checklist: [../emed-etl/context.md](context.md) — add "verify
  etl_metadata after first Run-All-ETL run" to any new-pharmacy go-live.
- Prior LastModified-freeze pattern (different mechanism, same "mirror silently
  stale" symptom): the refresh-diff pass in `liberty_run_etl_flow.py`.
