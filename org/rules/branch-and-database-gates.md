# Branch Access & Database Change Gates

**Effective 2026-07-16; updated 2026-07-17** (added Jose as backup gatekeeper). Enforced via
GitHub branch protection + a tag ruleset on the `Earth-Science-Tech` org — this is live
configuration, not just convention.

## Production gatekeepers

The people allowed to merge to production, cut prod deploy tags, and change the prod database:

| Person | GitHub | Role |
|--------|--------|------|
| Nicholas Cardell | `nicholas-cardell` | Primary (eng lead, org owner) |
| Carlos Cueto | `carcuet` | Co-gatekeeper (esp. prod DB / emed_sql) |
| Jose Daniel Garcia Gonzalez | `etst-josegonzalez` | **Backup** (added 2026-07-17) |

Full team roster (and the two-Carlos gotcha) in [../../team/roster.md](../../team/roster.md).

> **Why Jose is a backup, and its limit.** Mario Tabraue (COO) produces a high volume of PRs
> that need fast production deploys; Jose was added to share that review-and-ship load so it
> doesn't bottleneck on Nicholas. **GitHub cannot restrict merge/deploy to a specific author's
> PRs** — so although the *intent* is "Jose primarily covers Mario's PRs," Jose technically holds
> full production authority (any PR). Treat "mainly Mario's PRs" as a trust/policy expectation,
> not an enforced rule.

## TL;DR

- **Dev is open. Production is gated.** Move fast in dev; only the three gatekeepers touch production.
- Anything wrong in dev is isolated and recoverable; anything wrong in prod reaches customers. The rules reflect that asymmetry.

## Merge / push matrix

| Repo | Branch | Who can merge / push | PR required? |
|------|--------|----------------------|--------------|
| **eMed** (emed_app) | `dev` | **All developers, directly** | **No** — push straight in, no approval |
| **eMed** (emed_app) | `main` (prod) | **Gatekeepers only** (Nicholas, Carlos, Jose), direct push | No (gated by identity) |
| **emed_sql** (prod DB schema) | `main` (prod) | **Gatekeepers only**, direct push | No (gated by identity) |
| **emed_etl** (prod ETL) | `main` (prod) | All devs **via PR + 1 approval**; Nicholas + Carlos push directly (PR bypass) | **Yes**, except N + C |
| **ai_info** | `main` | Everyone, directly | No (knowledge base) |

All branches block force-pushes and deletions.

## Production deploy tags (eMed → Azure)

A prod deploy of eMed is triggered by pushing a git tag matching `x.x.x` (e.g. `1.0.114`) →
Azure CI/CD. A **tag ruleset** on eMed restricts creating / updating / deleting `*.*.*` tags to
the `admin` + `maintain` repository roles and org owners — i.e. exactly the gatekeepers plus
Chris Rose (CTO/org owner). Carlos and Jose hold the `maintain` role on eMed for this purpose.
Regular `write` developers (Mario, Carlos Obregon, Jorge) **cannot** cut a deploy tag, so they
cannot trigger a prod deploy even by pushing a tag. (`maintain` does not grant them the ability
to edit branch protection, bypass the merge gate, or delete anything.)

## Rules for Claude instances

1. **eMed `dev`:** commit and push directly. No PR, no approval, no waiting. Default integration
   branch for all feature work.
2. **eMed `main` / emed_sql `main` (production):** do **not** push or merge here unless the person
   you are working for is a gatekeeper (Nicholas, Carlos, or Jose). Everyone else is blocked at the
   GitHub level. Path for others: land on `dev`, then a gatekeeper promotes to `main` and cuts the
   deploy tag (see the push-prod skill).
3. **emed_etl `main`:** open a PR and get 1 approval from any developer. (Nicholas & Carlos may push
   directly.) emed_etl auto-deploys to prod on the next scheduled Prefect run, so its `main` is
   production even though it isn't the database.
4. **emed_sql *is* the production database.** Any change that reaches `liberty_link_stage` (prod DB)
   — schema migrations, grants, data fixes — flows through emed_sql `main` and is gated to the
   gatekeepers.

## Database changes

- **Dev DB (`liberty_link_dev`) — open to all developers.** Any developer may write and apply
  migration files against dev. Develop schema changes on dev first, freely, without gatekeeping.
- **Prod DB (`liberty_link_stage`) — gatekeepers only** (Nicholas, Carlos, Jose). A migration reaches
  prod only via the emed_sql `main` → push-prod flow, executed by a gatekeeper. Jose runs prod
  migrations using the shared emed_sql prod admin credentials (held out-of-band, **never** committed
  to any repo). Caveat: migrations run under the shared admin `sql_user`, so they are not individually
  attributable to Jose in the DB audit trail.
- Standard flow: build on dev DB → write migration in emed_sql → a gatekeeper applies to prod.
  See `sql-safety.md` and the emed_sql prod/dev split docs.

## Enforcement note

GitHub **org owners can bypass branch protection.** Current org owners: `nicholas-cardell`
(Nicholas) and `earth-science-dev` (Chris Rose, CTO — does not commit). Everyone else is bound by
the rules above. `enforce_admins` is currently **off** on the gated branches; enable it if you ever
need a hard lock that even owners cannot bypass.

## Why this model

- The old flow required a PR + 1 peer approval for **every** merge into `dev`, which stalled
  features waiting on a reviewer. Removing it unblocks day-to-day work.
- Risk is contained: mistakes in `dev` / `liberty_link_dev` are isolated and recoverable, never
  customer-facing.
- Production (main branches, deploy tags, prod DB) stays held by a small set of trusted senior
  owners, so an unreviewed change can never reach customers.
