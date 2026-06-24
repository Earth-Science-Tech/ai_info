# SQL User Permissions

## Overview

The eMed platform uses least-privilege database users. Application code NEVER uses the SQL admin account.

## Users

| User | Database | Purpose | Permission Script | Used By |
|------|----------|---------|-------------------|---------|
| `emed_app` | `liberty_link_stage` | Node.js web application | `emed_sql/create_emed_app_user.sql` | emed_app |
| `emed_etl` | `liberty_link_stage`, `etst_warehouse` | Python ETL scripts; warehouse load + dbt build | `emed_sql/create_emed_etl_user.sql` | emed_etl |
| `emed_reporting_user` | `etst_warehouse` | Read-only on `core` + `mart` schemas, plus SELECT on 6 `stg.emed_*` reporting tables | `emed_sql/create_emed_reporting_user.sql` | BI / reporting / analytics tools |

### `emed_reporting_user` scope

Read-only consumer of the warehouse, intended for BI tools, dashboards, and ad-hoc analytics. Has **SELECT only**, scoped to `core`, `mart`, and a short allow-list of `stg.emed_*` reporting tables (verified against the live grants on 2026-06-23):

- ✅ `SELECT` on every object in `core` and `mart` (granted at the **schema level**, so new dbt models there are picked up automatically)
- ✅ `SELECT` on 6 **object-level** grants in `stg` — the eMed billing/dispense reporting tables BI consumes directly:
  - `stg.emed_cost_adjustment`
  - `stg.emed_cost_adjustment_report`
  - `stg.emed_dispense_report`
  - `stg.emed_invoice`
  - `stg.emed_invoice_line_item`
  - `stg.emed_invoice_notes`
- ✅ `CONNECT` on the database
- ❌ No access to the rest of `etst_warehouse.stg` (raw clones + dbt staging views such as `woo_*`, `propelr_*`, `moct_*` stay internal)
- ❌ No access to `liberty_link_stage` at all
- ❌ No INSERT/UPDATE/DELETE, no DDL, no EXECUTE

When adding a new dbt model in `core` or `mart`, no per-object grant is needed — the schema-level GRANT covers it. The `stg.emed_*` grants above are **object-level** (there is no schema-level grant on `stg`), so a new `stg` reporting table that BI must read needs its own explicit `GRANT SELECT ... TO emed_reporting_user`.

## Permission Grant Template

```sql
-- migration_grant_permissions_<table_name>.sql
-- Purpose: Grant permissions for <table_name> to application users
-- Created: <date>

-- For emed_app (Node.js web application):
GRANT SELECT ON <table_name> TO emed_app;
GRANT INSERT ON <table_name> TO emed_app;
GRANT UPDATE ON <table_name> TO emed_app;
-- NOTE: Do NOT grant DELETE to emed_app (uses soft delete)
-- EXCEPTION: Only the 'sessions' table has DELETE

-- For emed_etl (Python ETL scripts) - only if ETL accesses this table:
GRANT SELECT ON <table_name> TO emed_etl;
GRANT INSERT ON <table_name> TO emed_etl;
GRANT UPDATE ON <table_name> TO emed_etl;
-- Only grant DELETE if ETL does bulk clear-and-reload:
-- GRANT DELETE ON <table_name> TO emed_etl;

-- For stored procedures:
-- GRANT EXECUTE ON <procedure_name> TO emed_etl;

-- For views:
-- GRANT SELECT ON <view_name> TO emed_app;
-- GRANT SELECT ON <view_name> TO emed_etl;
```

## Rules

- **Never grant DDL** (CREATE TABLE, ALTER, DROP) — explicitly DENYed
- **Never grant DELETE to emed_app** — app uses soft delete (`UPDATE is_invalid = 1`)
- **DENY overrides GRANT** in SQL Server — DDL denials hold even if a role is added
- **Temp tables** (#TempXxx) don't need permissions — they work in tempdb automatically

## Decision Matrix

| Scenario | emed_app | emed_etl | emed_reporting_user |
|----------|----------|----------|---------------------|
| New table in `liberty_link_stage` used by Node.js routes | SELECT, INSERT, UPDATE | — | — |
| New table in `liberty_link_stage` used by ETL scripts | — | SELECT, INSERT, UPDATE | — |
| New table in `liberty_link_stage` used by both | SELECT, INSERT, UPDATE | SELECT, INSERT, UPDATE, (DELETE if bulk reload) | — |
| New view in `liberty_link_stage` | SELECT | SELECT (if ETL queries it) | — |
| New stored procedure | — | EXECUTE (if ETL calls it) | — |
| New `etst_warehouse.stg` raw table (clone target) | — | SELECT, INSERT, UPDATE, DELETE | — by default; object-level SELECT only if BI must read it directly (e.g. the `stg.emed_*` reporting tables) |
| New dbt model in `etst_warehouse.core` or `mart` | — | (owned by dbt build) | covered by schema-level GRANT |
