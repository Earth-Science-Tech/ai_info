# SQL User Permissions

## Overview

The eMed platform uses least-privilege database users. Application code NEVER uses the SQL admin account.

## Users

| User | Database | Purpose | Permission Script | Used By |
|------|----------|---------|-------------------|---------|
| `emed_app` | `liberty_link_stage` | Node.js web application | `emed_sql/create_emed_app_user.sql` | emed_app |
| `emed_etl` | `liberty_link_stage`, `etst_warehouse` | Python ETL scripts; warehouse load + dbt build | `emed_sql/create_emed_etl_user.sql` | emed_etl |
| `emed_reporting_user` | `etst_warehouse` | Read-only access to `core` and `mart` schemas | `emed_sql/create_emed_reporting_user.sql` | BI / reporting / analytics tools |

### `emed_reporting_user` scope

Read-only consumer of the warehouse, intended for BI tools, dashboards, and ad-hoc analytics. Has **SELECT only** and **only on `etst_warehouse.core` and `etst_warehouse.mart`**:

- ✅ `SELECT` on every object in `core` and `mart` (granted at the schema level so new dbt models are picked up automatically)
- ❌ No access to `etst_warehouse.stg` (raw clones and dbt staging views are internal)
- ❌ No access to `liberty_link_stage` at all
- ❌ No INSERT/UPDATE/DELETE, no DDL, no EXECUTE

When adding a new dbt model in `core` or `mart`, no per-object grant is needed — the schema-level GRANT covers it.

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
| New `etst_warehouse.stg` raw table (clone target) | — | SELECT, INSERT, UPDATE, DELETE | — |
| New dbt model in `etst_warehouse.core` or `mart` | — | (owned by dbt build) | covered by schema-level GRANT |
