# eMed ETL Overview

emed_etl runs four pipeline families on Prefect (`prefect.yaml`):

1. **Peaks Curative ETL** — operational, every 30 min
2. **Liberty Pharmacy ETL** — operational, every 15–60 min per table
3. **Stage → Warehouse Clone** — analytics load, nightly 01:00 ET
4. **Warehouse dbt Build** — analytics transform, nightly 02:00 ET

## 1. Peaks Curative ETL
- **Source:** peakscurative.com WordPress (WooCommerce + WPForms)
- **Target:** Azure SQL `liberty_link_stage` → eMed API
- **Schedule:** Every 30 minutes
- **Purpose:** Convert e-commerce orders + patient questionnaires into medical visits

**Flow:**
1. Fetch WooCommerce orders (last 2 days)
2. Fetch WPForms questionnaires with field mappings (last 2 days)
3. Match orders to questionnaires by email/order ID
4. Call eMed API (`POST /api/public/moct-visit`) to create visits
5. Update Advanced Shipment Tracking

**Key flows (`flows/emed_etl/`):**
- `peaks_etl_woo_orders_flow.py` — Fetch WooCommerce orders
- `peaks_etl_wpforms_flow.py` — Fetch questionnaires
- `peaks_update_moct_flow.py` — Transform and create visits
- `peaks_update_ast_flow.py` — Shipment tracking
- `peaks_etl_orchestrator_flow.py` — Combined Peaks orchestrator

## 2. Liberty Pharmacy ETL
- **Source:** Liberty RX pharmacy database
- **Target:** Azure SQL `liberty_link_stage`
- **Schedule:** Per-table cadence (15–60 min)
- **Purpose:** Transfer pharmacy operational data
- **Multi-tenant:** Supports `rxcs` (Rx Compound Store) and `mmed` (Mister Meds) via `table_prefix`

**Key flows:**
- `flows/emed_etl/liberty_run_etl_flow.py` — Transfer a single configured table
- `flows/emed_etl/liberty_etl_config.json` — Table transfer configuration
- `flows/emed_etl/run_all_etl_flow.py` — Combined Liberty + Peaks runner per tenant

## 3. Stage → Warehouse Clone
- **Source:** `liberty_link_stage`
- **Target:** `etst_warehouse.stg.*`
- **Schedule:** Nightly 01:00 ET (`Clone-Prod-to-Warehouse-Stage`)
- **Mechanism:** Azure SQL elastic query (server-side cross-DB copy)
- **Behavior:** Source schemas flatten into `stg`; only tables that already exist in `stg` are loaded; exclusions in `clone_prod_to_warehouse_stage_exclusions.json`.

**Key files:**
- `flows/emed_etl/clone_prod_to_warehouse_stage.py`
- `flows/utilities/db_clone.py` — shared with dev-DB clone
- `flows/utilities/generate_warehouse_stg_ddl.py` — emits warehouse `stg` DDL from live source metadata

## 4. Warehouse dbt Build
- **Project:** `dbt/` (`etst_warehouse`, dbt-sqlserver adapter)
- **Schedule:** Nightly 02:00 ET (`Warehouse-DBT-Build`), runs after the clone
- **Command:** `dbt deps && dbt build` via `prefect_dbt.PrefectDbtRunner`
- **Output schemas:**
  - `stg.stg_*` — cleanup views over raw clones
  - `core.dim_*` / `core.fct_*` — dimensional model (tables)
  - `mart.*` — denormalized reporting marts (tables)

**Key files:**
- `flows/emed_etl/dbt_warehouse_build.py` — Prefect flow wrapping `dbt deps` + `dbt build`
- `dbt/dbt_project.yml`, `dbt/profiles.yml`, `dbt/macros/generate_schema_name.sql`
- `dbt/models/sources.yml`, `dbt/models/{staging,core,marts}/`

See [emed-etl/warehouse.md](../emed-etl/warehouse.md) for the full warehouse reference.

## SMS Integration (separate from the ETL families)
- `flows/sms/sms_fetch_message_history.py` — RingCentral message history (every 5 min)
- `flows/sms/sms_send_pending.py` — Send pending SMS messages (every 1 min)
- `flows/emed_etl/peaks_etl_sms_missing_intake_forms.py` — Daily intake-form reminders

## Job Servers
- **Rx Compound Store server** (`rxcs-jobserver-workqueue`, table_prefix='rxcs')
- **Mister Meds server** (`mmed-jobserver-workqueue`, table_prefix='mmed')

## Gotchas

- [Partial-data window](etl-partial-data-window.md) — `rxcs_rxqFullOrder` / `mmed_rxqFullOrder` rows are inserted in stages. There's a window where ScriptNumber and Quantity are present but Patient, Drug, Prescriber, and Clinic fields are NULL. Views over these tables produce empty strings (not nulls) for the computed Patient/Doctor/Clinic fields, which silently defeats `value || fallback` checks. Read the gotcha doc before writing code that consumes these tables.
