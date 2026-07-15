# ETL Gotcha: NOT EXISTS Doesn't Dedupe Within an INSERT Batch

**Discovered:** 2026-07-15 production incident (Run-All-ETL-RXCS down ~7 hours).

## The pattern

Several ETL stored procedures use this idempotency guard:

```sql
INSERT INTO target (...)
SELECT ... FROM source e
WHERE NOT EXISTS (SELECT 1 FROM target f WHERE f.key = e.key)
```

`NOT EXISTS` only checks rows **already committed in the target** — it cannot
see other rows in the same `INSERT ... SELECT` batch. If the source hands the
statement two rows with the same key, **both insert**. Any unique index on the
target then rejects the entire statement, the transaction rolls back (including
CATCH-block `sql_log` inserts, so the failure is invisible in `sql_log` — a
*gap* in the log means failing runs), and everything queued behind the insert
stays blocked.

## The fix

Rank the source and insert only the first row per key:

```sql
;WITH src AS (
    SELECT ..., ROW_NUMBER() OVER (
        PARTITION BY <full identity key, NULL-safe>
        ORDER BY e.id            -- keep the oldest, deterministic
    ) AS rn
    FROM source e
    WHERE ... AND NOT EXISTS (...)
)
INSERT INTO target (...) SELECT ... FROM src WHERE rn = 1
```

NULLs group together in `PARTITION BY` (unlike `=` in a WHERE/JOIN), so this is
naturally NULL-safe — pair it with a NULL-safe `NOT EXISTS`
(`f.col = e.col OR (f.col IS NULL AND e.col IS NULL)`).

## Where it bit us (2026-07-15)

Duplicate rows in the Liberty mirror `rxcs_rxqScriptTransaction` (same
`cScriptTransactionId` inserted twice, seconds apart — likely overlapping sync
runs or a retry-after-commit) propagated through `usp_etl_rxcs_rxqFullOrder`
(same target-only guard → ~1,515 duplicated keys in `rxcs_rxqFullOrder`) into
`usp_etl_moct_order_tracking`, where the filtered unique index
`UX_moct_order_tracking_pickup_key` (added 2026-07-08 as a regression tripwire)
rejected the batch and blocked ~2,664 pending tracking rows for both
pharmacies. Fixed by the ROW_NUMBER pattern in
`emed_sql/migrations/applied/2026-07-15_fix_usp_etl_moct_order_tracking_intrabatch_dedup.sql`.

## Second lesson: draining a blocked backlog can spam customers

When a consumer keys off an "unsent" flag (`tracking_sent = 0`), unblocking a
long-stuck insert dumps the whole backlog into the outbound path at once —
here, ~1,693 orders (some shipped in January) would have been re-pushed to the
Peaks AST plugin and re-notified customers. Drain + suppress in ONE
transaction: `EXEC` the fixed proc, then pre-mark rows older than a cutoff
(~14 days) as sent, so concurrent orchestrator runs can't grab stale unsent
rows in between. See
`emed_sql/migrations/applied/2026-07-15_drain_tracking_backlog_premark_stale_sent.sql`.

## Open follow-ups

- Dedupe the mirror tables (`rxcs_rxqScriptTransaction`: 350 dup keys / 430
  excess rows; `rxcs_rxqFullOrder`: ~1,515 dup pairs) and consider unique
  indexes so new dups fail loudly at the source.
- Apply the ROW_NUMBER pattern to `usp_etl_{rxcs,mmed,mdvo}_rxqFullOrder`
  (same target-only `NOT EXISTS`).
- Root-cause why the Python Liberty sync double-inserts (dup rows are seconds
  apart → concurrent flow runs or a retry whose first attempt committed);
  consider a Prefect concurrency limit per table sync.
