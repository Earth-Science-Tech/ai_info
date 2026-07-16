# Plaid Bank Feed (balances + transactions)

**Added:** 2026-07-16 · **Owner:** Carlos Cueto · **Updated:** 2026-07-16 (registry + /transactions/sync)

Pulls bank account balances and transactions from Plaid into the warehouse for the
finance dashboard. Sits alongside the Stripe and Propelr feeds.

## Pieces

| Piece | Where |
|-------|-------|
| Flow | `emed_etl/flows/plaid/plaid_balances_transactions_flow.py` (`plaid-balances-transactions`) |
| Link helper (CLI) | `emed_etl/scripts/plaid_get_access_token.py` — Hosted Link → access token → Secret block + registry upsert |
| Item registry | `etst_warehouse.dbo.etst_fin_plaid_item` — one row per bank login; DDL in `emed_sql/warehouse/etst_fin_plaid_item.sql` |
| Warehouse DDL | `emed_sql/warehouse/stg_plaid_balances_transactions.sql` (hand-applied, idempotent) |
| Deployment | `Plaid-Balances-Transactions` in `emed_etl/prefect.yaml`, daily 1:40 AM ET (before the 2 AM dbt build) |
| Feed tables | `stg.plaid_account_balances` (append-only snapshot per run), `stg.plaid_transactions` (kept in step via sync deltas) |

## Auth model (differs from Stripe)

One team-wide pair `plaid-client-id` / `plaid-secret`, plus **one access token per
Item** (= one institution login, which can hold several bank accounts). Tokens live
ONLY in Prefect Secret blocks (`plaid-access-token-<alias>`); the registry stores the
block **name**, never the token. The alias lands in `account_alias`; the true Plaid
`item_id` is the natural-key discriminator. Linked: `chase` (Chase, 24mo history),
`boa` (Bank of America, ~18mo — institutions serve what they have).

## How the nightly sync works

- **Registry-driven fan-out**: the flow reads active rows (`sync_enabled=1`,
  `is_invalid=0`, matching environment) from `dbo.etst_fin_plaid_item` — the
  deployment's `accounts` param stays `null`. One task per Item.
- **Balances**: `/accounts/balance/get`, one snapshot row per account per run
  (`as_of`-stamped, append-only; multiple runs/day = multiple snapshots — take
  `MAX(as_of)` per day for trends).
- **Transactions**: `/transactions/sync` deltas against the cursor stored on the
  registry row — added/modified upserted by `transaction_id`, removed deleted.
  NULL cursor = full-history pull (initial link, `reset_cursor=true`, or re-link).
- **Atomicity**: snapshot + upserts + removals + cursor update commit in ONE DB
  transaction, so the cursor can never diverge from the data. Failures write
  `last_error_code/_message` to the registry row (watch for `ITEM_LOGIN_REQUIRED`
  = bank OAuth consent expired → re-link with the helper).

## Gotchas (all hit for real on 2026-07-16)

1. **Plaid ids are case-sensitive; SQL Server default collation is not.** A real
   999-row pull had 11 id pairs differing only in letter case → unique-index
   violations. All Plaid id columns use `COLLATE Latin1_General_100_BIN2`; joins
   to CI-collated columns need an explicit `COLLATE`.
2. **`days_requested` is fixed at link time and defaults to 90.** The helper sets
   730; an Item linked without it only ever serves ~90 days. Fix = re-link.
3. **Re-linking creates a NEW Item** (new `item_id` + token). The helper's registry
   upsert handles it (overwrites item_id, resets cursor); still **purge the old
   item's stg rows** (they double-count under the same alias) and `/item/remove`
   the old token — orphaned Items keep billing. The Dashboard Item Debugger can
   only inspect, not remove.
4. **Amount sign convention is the opposite of Stripe:** positive = money OUT.
5. Pending transactions are included (`pending=1`) and post later under a NEW
   `transaction_id` (sync removes the pending row). Don't key anything long-lived
   to a pending row's id.

## Linking a new bank login

```bash
cd emed_etl
python -m scripts.plaid_get_access_token --register <alias>   # e.g. mmed-wells
# open the printed Hosted Link URL, finish the bank OAuth; the script saves the
# Secret block AND upserts the registry - the nightly flow picks it up, no deploy
```
`--backfill <alias>` registers an already-linked Item (existing Secret block) into
the registry without re-linking. Manual full re-pull:
`python -m flows.plaid.plaid_balances_transactions_flow <alias> --reset-cursor`.
