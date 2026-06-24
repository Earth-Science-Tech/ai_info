# eMed Database Schema Overview

## Databases

| Database | Purpose | Owner |
|----------|---------|-------|
| `liberty_link_stage` | Operational data shared by emed_app + emed_etl | emed_app + emed_etl |
| `etst_warehouse` | Analytics / reporting warehouse, loaded nightly from `liberty_link_stage` and modeled with dbt | emed_etl |

Both live on `liberty-link.database.windows.net`. See [emed-etl/warehouse.md](../emed-etl/warehouse.md) for the warehouse layer.

## Operational DB: liberty_link_stage

### Table Prefixes (82+ tables)

| Prefix | Count | Domain | Key Tables |
|--------|-------|--------|------------|
| `moct_*` | 25 | Core medical office | `moct_visit`, `moct_person`, `moct_drug_rx`, `moct_questionnaire`, `moct_order_tracking` |
| `rxcs_*` | 19 | Rx Compound Store | Pharmacy data + pricing |
| `emed_*` | 15 | eMed platform | Users, email, SMS, billing, pricing, invoicing |
| `mmed_*` | 13 | Mister Meds | Pharmacy data |
| `woo_*` | 4 | WooCommerce | Order staging from WordPress |
| `wpforms_*` | 2 | WPForms | Patient questionnaire staging |
| Other | 4+ | System | `sessions`, `etl_metadata`, `sql_log`, `blaze_patients` |

### Core Tables

**moct_visit (main visit/order table)** — The central table; represents a patient consultation/order. Links to moct_person (patient), moct_drug_rx (prescriptions), moct_questionnaire (intake forms).

**moct_person (patient info)** — Patient demographics. Linked from moct_visit.

**moct_drug_rx (prescriptions)** — Prescription records tied to visits.

**moct_order_tracking (shipment tracking)** — Advanced Shipment Tracking data for orders.

### Views (19)

Prefixed by domain: `view_emed_*`, `view_mmed_*`, `view_moct_*`, `view_rxcs_*`, `view_peaks_*`, `view_woo_*`

### Stored Procedures (18)

- `usp_etl_*` — ETL merge/transform operations
- `usp_insert_*` — Data insertion helpers
- `usp_normalize_*` — Data normalization
- `usp_refresh_*` — View/cache refresh

## Warehouse DB: etst_warehouse

Loaded nightly from `liberty_link_stage` by the `Clone-Prod-to-Warehouse-Stage` Prefect deployment, then transformed by `Warehouse-DBT-Build` (dbt-sqlserver).

| Schema | Layer | Materialization | Source of objects | Examples |
|--------|-------|-----------------|--------------------|----------|
| `stg`  | raw clones + dbt staging | tables (raw) + views (`stg_*`) | clone flow + dbt | `stg.woo_orders` (raw), `stg.stg_woo_orders` (view) |
| `core` | dimensions + facts | tables | dbt | `core.dim_date`, `core.fct_order` |
| `mart` | reporting marts | tables | dbt | `mart.mart_daily_orders` |

Raw `stg` table DDL is owned by `emed_sql` migrations; `stg_*` views and all `core`/`mart` objects are owned by the dbt project (`emed_etl/dbt/`).

### Warehouse access

| User | Access |
|------|--------|
| `emed_etl` | Read/write across `etst_warehouse` — runs the nightly clone and dbt build |
| `emed_reporting_user` | **Read-only** — `core` + `mart` (schema-level) plus object-level SELECT on 6 `stg.emed_*` reporting tables (`emed_invoice`, `emed_invoice_line_item`, `emed_invoice_notes`, `emed_cost_adjustment`, `emed_cost_adjustment_report`, `emed_dispense_report`). No other `stg` access, none to `liberty_link_stage`. New `core`/`mart` models are picked up automatically; a new `stg` reporting table needs its own explicit grant. Full matrix → [org/security/sql-permissions.md](../../org/security/sql-permissions.md). |

Full user matrix: [org/security/sql-permissions.md](../../org/security/sql-permissions.md).

## Detailed Schema

For complete column-level schema (all tables, views, procedures with SQL source):
- Run: `python python/extract_schema.py` from emed_app root
- Read: `emed_app/sql/info.claude`
