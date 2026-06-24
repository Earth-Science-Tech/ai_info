# etst_warehouse — Data Warehouse Reference

The `etst_warehouse` database is the analytics/reporting warehouse for the eMed platform. It is loaded nightly from `liberty_link_stage` (the shared operational DB) and modeled with dbt.

## Architecture

```
liberty_link_stage (operational, Azure SQL)
         │
         │  Clone-Prod-to-Warehouse-Stage  (Prefect, 01:00 ET nightly)
         │  flows/emed_etl/clone_prod_to_warehouse_stage.py
         ▼
etst_warehouse.stg.*           ← raw clones (schemas flattened)
         │
         │  Warehouse-DBT-Build  (Prefect, 02:00 ET nightly)
         │  flows/emed_etl/dbt_warehouse_build.py  →  `dbt deps && dbt build`
         ▼
etst_warehouse.stg.stg_*       ← cleanup views (rename/cast/trim)
etst_warehouse.core.dim_* / fct_*   ← dimensional model
etst_warehouse.mart.*          ← denormalized aggregates for reporting
```

## Schemas

| Schema | Layer        | Materialization | Owner            | Examples |
|--------|--------------|-----------------|------------------|----------|
| `stg`  | raw + staging | tables (raw) + views (`stg_*`) | clone flow (raw); dbt (views) | `stg.woo_orders` (raw), `stg.stg_woo_orders` (view) |
| `core` | dimensions + facts | tables | dbt | `core.dim_date`, `core.fct_order` |
| `mart` | reporting marts | tables | dbt | `mart.mart_daily_orders` |

The raw clone tables and dbt staging views live side-by-side in `stg`. The custom `generate_schema_name` macro (`dbt/macros/generate_schema_name.sql`) makes each model's `+schema:` literal — without it dbt would prefix the target schema (`core_stg`, etc.).

## Stage Clone (`clone_prod_to_warehouse_stage.py`)

- Uses Azure SQL **elastic query** so data flows server-side between the two DBs (no Python-side transfer).
- Source schemas in `liberty_link_stage` are **flattened**: `<any_schema>.<table>` lands as `etst_warehouse.stg.<table>`.
- A source table is loaded **only if** `stg.<table>` already exists in the warehouse. DDL is owned by the `emed_sql` migrations, not by this flow.
- Tables in `clone_prod_to_warehouse_stage_exclusions.json` are skipped.
- Collisions (two source schemas with the same table name) are skipped — operator must rename in the warehouse or exclude one source schema.
- Concurrency: 4 tables in parallel by default (`DEFAULT_CONCURRENCY = 4`).
- Shares the underlying clone primitives with `clone_prod_to_dev_database.py` via `flows/utilities/db_clone.py`.

### DDL generator
`flows/utilities/generate_warehouse_stg_ddl.py` emits a migration for warehouse `stg` tables based on live source metadata. Run this when a new source table needs to be added to the warehouse; commit the generated migration to `emed_sql`.

## dbt Project (`dbt/`)

| File | Purpose |
|------|---------|
| `dbt_project.yml` | Profile `etst_warehouse`; staging→view, core/marts→table |
| `profiles.yml` | Reads `ETST_WAREHOUSE_{SERVER,USER,PASSWORD}` via `env_var()` |
| `packages.yml` / `package-lock.yml` | dbt package deps (installed by `dbt deps`) |
| `macros/generate_schema_name.sql` | Don't prefix `+schema` with target schema |
| `models/sources.yml` | Declares `stg.*` raw tables as dbt sources |
| `models/staging/stg_*.sql` | Cleanup views (e.g., `stg_woo_orders`, `stg_woo_order_items`) |
| `models/core/dim_*.sql`, `fct_*.sql` | Dimensions and facts (`dim_date`, `fct_order`) |
| `models/marts/mart_*.sql` | Denormalized marts (`mart_daily_orders`) |

### Adding a new model
1. New source table? Add it to `models/sources.yml`.
2. Cleanup/rename/cast → write a `staging/stg_<source>.sql` view.
3. New dim or fact → write a `core/<dim_or_fct>.sql` table.
4. New aggregation → write a `marts/mart_<thing>.sql` table.
5. Add tests in the matching `_<layer>.yml`.

### Notes & gotchas
- `+persist_docs` is **off**: `dbt-sqlserver` does not implement `alter_relation_comment`, so enabling it errors on every staging view. Descriptions still show in `dbt docs serve` and YAML.
- dbt model `.sql` files **are** edit-allowed (transformations, not migrations). The `block_sql_creation` hook carves `dbt/` out specifically. Schema migrations still belong in `../emed_sql/migrations/`.

### Multi-source / multi-tenant facts (discriminator in the grain)

Facts that can hold rows from more than one source/tenant carry a **discriminator column that is part of the grain _and_ the surrogate key** — because the upstream natural keys are only unique *within* a source:

| Fact | Discriminator | Values | Surrogate key |
|------|---------------|--------|---------------|
| `core.fct_order` | `source_site` | `peaks_curative`, `peaknow` | `hash(source_site, order_id, line_item_id)` |
| `core.fct_payment_transaction` | `pharmacy` | `rxcs`, `mmed` | `hash(pharmacy, transaction_id)` |
| `core.fct_payment_action` | `pharmacy` | `rxcs`, `mmed` | `hash(pharmacy, transaction_id, action_seq)` |

**Why (the gotcha):** WooCommerce `order_id`s are per-install auto-increment sequences, so PeaksCurative order `1234` and PeakNow order `1234` are *different* orders sharing an id. Keying `fct_order` on `order_id` alone would collide and conflate them the moment a second storefront lands (the SK `unique` test breaks, or worse, rows silently merge). Same logic for `transaction_id` across pharmacies.

**Conventions:**
- Stamp the discriminator at the **staging boundary** as a literal — each `stg_*` view maps 1:1 to one source's physical table (`stg_woo_orders` → `'peaks_curative'`). When a second source lands, add its own staging models (`stg_pn_woo_*` → `'peaknow'`) and `UNION ALL` in the fact; don't re-key.
- Make every cross-table join inside the fact **source-aware** (`on a.order_id = b.order_id and a.source_site = b.source_site`), or the union cross-joins sources.
- Marts grain by the discriminator too (`mart_daily_orders` is per `(date_key, source_site)`); enforce uniqueness with a `dbt_utils.unique_combination_of_columns` test on the combo, and let consumers `SUM(...) GROUP BY date_key` to roll sources up.
- Adding the discriminator while there's still one source is **non-breaking** (a constant column / one-row-per-day) and far cheaper than retrofitting after the keyspace is polluted — do it early.

> `source_site` (storefront: peaks_curative / peaknow) and `pharmacy` (payment tenant: rxcs / mmed) are **different axes** — don't conflate them. The order↔payment join (`fct_payment_transaction.order_id`) crosses the two.

## Database Users

| User | Access | Used by |
|------|--------|---------|
| `emed_etl` | Full read/write on `etst_warehouse` (loads `stg.*`, dbt builds `stg.stg_*`, `core.*`, `mart.*`) | Clone flow + dbt build |
| `emed_reporting_user` | **Read-only** — `core` + `mart` schemas, plus SELECT on 6 `stg.emed_*` reporting tables | BI / reporting / analytics tools |

`emed_reporting_user` is the consumer-side identity for the warehouse. It is **not** used by emed_etl or emed_app — it exists so downstream reporting tools can connect to `etst_warehouse` without touching `liberty_link_stage` or the internal raw/staging objects in `stg`. Grants on `core` and `mart` are at the **schema level**, so new dbt models there are automatically readable without a follow-up migration.

It additionally has **object-level** `SELECT` on 6 eMed billing/dispense reporting tables in `stg` that BI consumes directly: `stg.emed_cost_adjustment`, `stg.emed_cost_adjustment_report`, `stg.emed_dispense_report`, `stg.emed_invoice`, `stg.emed_invoice_line_item`, `stg.emed_invoice_notes`. These are individual grants (there is no schema-level access to `stg`), so a new `stg` reporting table BI must read needs its own explicit grant. The rest of `stg` (`woo_*`, `propelr_*`, `moct_*`, and the `stg_*` views) is **not** readable by this user.

See [org/security/sql-permissions.md](../../org/security/sql-permissions.md) for the full user matrix.

## Prefect Deployments

Defined in `prefect.yaml`:

| Deployment | Entrypoint | Schedule (ET) | Tags |
|------------|-----------|---------------|------|
| `Clone-Prod-to-Warehouse-Stage` | `clone_prod_to_warehouse_stage.py:clone_prod_to_warehouse_stage` | `0 1 * * *` | `db`, `warehouse`, `utility` |
| `Warehouse-DBT-Build` | `dbt_warehouse_build.py:dbt_warehouse_build` | `0 2 * * *` | `db`, `warehouse`, `dbt` |

The dbt build flow uses `prefect_dbt.PrefectDbtRunner`, which emits a Prefect event per dbt node (model/test/source) — visible on the Events page filtered by `dbt` and surfaced as asset lineage.

## Secrets

Loaded into `os.environ` by `dbt_warehouse_build._set_dbt_env_vars()` so `profiles.yml`'s `env_var(...)` lookups resolve at invoke time:

- `emed-database-server` → `ETST_WAREHOUSE_SERVER` (stripped of `tcp:` prefix and `,port` suffix)
- `etst-warehouse-etl-user` → `ETST_WAREHOUSE_USER`
- `etst-warehouse-etl-password` → `ETST_WAREHOUSE_PASSWORD`

The clone flow uses the standard `emed-database-*` Prefect Secret blocks for the source side and `flows/utilities/db.get_warehouse_conn_str()` for the target side.

## Local dbt usage

```powershell
pip install dbt-sqlserver prefect-dbt
$env:ETST_WAREHOUSE_SERVER   = "liberty-link.database.windows.net"
$env:ETST_WAREHOUSE_USER     = "emed_etl"
$env:ETST_WAREHOUSE_PASSWORD = "<emed_etl password>"

cd dbt
dbt deps
dbt debug
dbt build
```

See `dbt/README.md` in the repo for the canonical setup steps.
