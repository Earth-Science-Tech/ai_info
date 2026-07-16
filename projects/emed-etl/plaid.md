# Plaid Bank Feed (balances + transactions)

**Added:** 2026-07-16 · **Owner:** Carlos Cueto

Pulls bank account balances and transactions from Plaid into the warehouse for the
finance dashboard. Sits alongside the Stripe and Propelr feeds.

## Pieces

| Piece | Where |
|-------|-------|
| Flow | `emed_etl/flows/plaid/plaid_balances_transactions_flow.py` (`plaid-balances-transactions`) |
| Link helper (CLI) | `emed_etl/scripts/plaid_get_access_token.py` — Hosted Link → access token → optional `--register` of the Secret block |
| Warehouse DDL | `emed_sql/warehouse/stg_plaid_balances_transactions.sql` (hand-applied to `etst_warehouse`, idempotent) |
| Deployment | `Plaid-Balances-Transactions` in `emed_etl/prefect.yaml`, daily 1:40 AM ET (before the 2 AM dbt build) |
| Tables | `stg.plaid_account_balances` (append-only snapshot per run), `stg.plaid_transactions` (rolling-window replace) |

## Auth model (differs from Stripe)

One team-wide pair `plaid-client-id` / `plaid-secret`, plus **one access token per
Item** (= one institution login, which can hold several bank accounts). Secret
blocks: `plaid-access-token-<alias>` (plain `plaid-access-token` for the `default`
alias). The alias is our label; it lands in `account_alias`, while the true Plaid
`item_id` is the natural-key discriminator. Currently linked: `chase`.

## Load strategy

- **Balances**: `/accounts/balance/get` (forced-refresh), one snapshot row per
  account per run stamped with a shared `as_of`. Dashboards take latest per account.
- **Transactions**: `/transactions/get` over a rolling posted-date window (default
  30 days; `--all` = 730). Landed as a **full-window delete + reinsert per item** —
  NOT a keyed upsert — because Plaid mutates history in place: pending transactions
  post under a NEW `transaction_id` and removed pendings vanish from the feed.

## Gotchas (all hit for real on 2026-07-16)

1. **Plaid ids are case-sensitive; SQL Server default collation is not.** A real
   999-row Chase pull contained 11 pairs of transaction ids differing only in letter
   case → duplicate-key errors on the unique index. All Plaid id columns
   (`item_id`, `account_id`, `transaction_id`, `pending_transaction_id`,
   `institution_id`) use `COLLATE Latin1_General_100_BIN2`. Joining them to a
   CI-collated column elsewhere needs an explicit `COLLATE`.
2. **`days_requested` is fixed at link time and defaults to 90.** An Item linked
   without `transactions: {days_requested: 730}` in `/link/token/create` will only
   ever serve ~90 days of history, no matter what window you request later. The
   helper script now sets 730. Fixing an already-linked Item requires re-linking.
3. **Re-linking creates a NEW Item (new `item_id`, new access token).** After a
   re-link: delete the old item's rows from both stg tables (the window delete keys
   on `item_id`, so the old rows would double-count), and call `/item/remove` with
   the OLD access token — orphaned Items keep billing (Transactions is per-Item).
   The Dashboard's Item Debugger can only inspect Items, not remove them.
4. **`/transactions/get` pagination is not stable.** The first call can trigger a
   background Item refresh, shifting offsets between pages (duplicates/leaks). The
   flow dedupes by `transaction_id` and restarts pagination if `total_transactions`
   changes mid-pull.
5. **Amount sign convention is the opposite of Stripe:** positive = money OUT
   (debit), negative = money IN.

## Linking a new bank login

```bash
cd emed_etl
python -m scripts.plaid_get_access_token --register <alias>   # e.g. rxcs-chase
# open the printed Hosted Link URL, complete the bank OAuth; script polls,
# exchanges, and saves the plaid-access-token-<alias> Secret block
```
Then add the alias to the deployment's `accounts` list in `prefect.yaml`,
`prefect deploy -n Plaid-Balances-Transactions`, and backfill once:
`python -m flows.plaid.plaid_balances_transactions_flow <alias> --all`.
