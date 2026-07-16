# Branch Access & Database Change Gates

**Effective 2026-07-16.** Set by Nicholas Cardell (engineering lead); Carlos Cueto
(senior DB engineer) is co-gatekeeper for production. Enforced via GitHub **classic
branch protection** on the `Earth-Science-Tech` org — this is live configuration, not
just convention.

## TL;DR

- **Dev is open. Production is gated.** Move fast in dev; only Nicholas & Carlos touch production.
- Anything wrong in dev is isolated and recoverable; anything wrong in prod reaches customers. The rules reflect that asymmetry.

GitHub usernames: **Nicholas = `nicholas-cardell`**, **Carlos = `carcuet`**.

## Merge / push matrix

| Repo | Branch | Who can merge / push | PR required? |
|------|--------|----------------------|--------------|
| **eMed** (emed_app) | `dev` | **All developers, directly** | **No** — push straight in, no approval |
| **eMed** (emed_app) | `main` (prod) | **Nicholas + Carlos only**, direct push | No (gated by identity) |
| **emed_sql** (prod DB schema) | `main` (prod) | **Nicholas + Carlos only**, direct push | No (gated by identity) |
| **emed_etl** (prod ETL) | `main` (prod) | All devs **via PR + 1 approval**; Nicholas + Carlos push directly (PR bypass) | **Yes**, except N + C |
| **ai_info** | `main` | Everyone, directly | No (knowledge base) |

All branches block force-pushes and deletions.

## Rules for Claude instances

1. **eMed `dev`:** commit and push directly. No PR, no approval, no waiting. This is the
   default integration branch for all feature work.
2. **eMed `main` / emed_sql `main` (production):** do **not** push or merge here unless the
   person you are working for is Nicholas or Carlos. Everyone else is blocked at the GitHub
   level. If another dev needs to ship to prod, the path is: land it on `dev`, then Nicholas
   or Carlos promotes to `main` (prod deploy is a git tag → Azure CI/CD — see the push-prod skill).
3. **emed_etl `main`:** open a PR and get 1 approval from any developer. (Nicholas & Carlos
   may push directly.) Note emed_etl auto-deploys to prod on the next scheduled Prefect run,
   so its `main` is production even though it isn't the database.
4. **emed_sql *is* the production database.** Any change that reaches `liberty_link_stage`
   (prod DB) — schema migrations, grants, data fixes — flows through emed_sql `main` and is
   therefore gated to Nicholas + Carlos.

## Database changes

- **Dev DB (`liberty_link_dev`) — open to all developers.** Any developer may write and apply
  migration files against dev. Develop schema changes on dev first, freely, without gatekeeping.
- **Prod DB (`liberty_link_stage`) — Nicholas + Carlos only.** A migration reaches prod only via
  the emed_sql `main` → push-prod flow, executed by Nicholas or Carlos.
- Standard flow: build on dev DB → write migration in emed_sql → Nicholas/Carlos apply to prod.
  See `sql-safety.md` and the emed_sql prod/dev split docs.

## Why this model

- The old flow required a PR + 1 peer approval for **every** merge into `dev`, which stalled
  features waiting on a reviewer. Removing it unblocks day-to-day work.
- Risk is contained: mistakes in `dev` / `liberty_link_dev` are isolated and recoverable, never
  customer-facing.
- Production (main branches + prod DB) stays tightly held by the two most senior owners, so an
  unreviewed change can never reach customers.
