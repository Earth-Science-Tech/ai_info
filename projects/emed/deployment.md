# eMed Deployment

## Production Deployment

**Platform:** Azure App Service
**URL:** emed.azurewebsites.net
**CI/CD:** GitHub Actions (`.github/workflows/deploy-azure.yml`)
**Trigger:** Git tag matching `[0-9]+.[0-9]+.[0-9]+` (NO `v` prefix)

## Branches, slots & release lanes

- `main` = **production** (ships on an `x.x.x` tag). `dev` = open integration/preview, auto-deploys to the
  Azure **dev slot** (`deploy-azure-dev.yml`). There is no `master`.
- Prod ships the **tagged commit on `main`**. `main` is advanced either by a gatekeeper-merged
  `feat/* → main` PR (**feature-promotion lane** — use this to ship a subset while unready work waits on
  `dev`) or, when *all* of `dev` is production-ready, by fast-forwarding `main` to the `dev` SHA
  (**batch lane**).
- Full model + gates: [../../org/rules/branch-and-database-gates.md](../../org/rules/branch-and-database-gates.md).

## Quick Deploy ("push prod")

See `skills/push-prod.md` for the full workflow. A gatekeeper runs it on a clean, up-to-date `main` after
the promotion PR is merged (or after the batch fast-forward):
1. Commit any remaining changes
2. Push to `main`
3. Create the tag (auto-increment patch or explicit version — `x.x.x`, no `v` prefix)
4. Push tag → triggers Azure production deployment

## ETL Deployment

ETL scripts run on job servers (Windows Task Scheduler or Prefect):
- **Rx Compound Store server** — rxcs pharmacy data
- **Mister Meds server** — mmed pharmacy data
- **Meduvo server** — mdvo pharmacy data (pending provisioning)
- **Schedule:** Every 30 minutes

## Database Changes

Schema changes flow through **emed_sql migrations**, never hand-run against prod (see
`skills/create-table.md` + [../../org/rules/sql-safety.md](../../org/rules/sql-safety.md)):
1. Write an idempotent migration (with GRANTs) and apply it to `liberty_link_dev`. While the feature is
   unready, park the migration in `emed_sql/migrations/wip/`.
2. When the feature's `feat/* → main` PR opens, move the migration `wip/ → pending/` and name it in the
   PR's **Schema changes** section.
3. `push prod` (run by a gatekeeper) applies **only the migration file(s) the shipping PR declares** to
   `liberty_link_stage` via `apply_migration.py --db both --confirm`, regenerates the `prod/`/`dev/`
   snapshots, and auto-moves the file to `applied/`. It never scans `wip/`.

## Rollback

- **App:** Redeploy a previous git tag
- **Database:** Schema changes should be additive; destructive changes need a migration plan
- **ETL:** Revert the Python script changes and redeploy to job servers
