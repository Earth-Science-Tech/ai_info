# SQL User Permissions

## Overview

The eMed platform uses least-privilege database users. Application code NEVER uses the SQL admin account.

## Users

| User | Purpose | Permission Script | Used By |
|------|---------|-------------------|---------|
| `emed_app` | Node.js web application | `emed_sql/create_emed_app_user.sql` | emed_app |
| `emed_etl` | Python ETL scripts | `emed_sql/create_emed_etl_user.sql` | emed_etl |

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

| Scenario | emed_app | emed_etl |
|----------|----------|----------|
| New table used by Node.js routes | SELECT, INSERT, UPDATE | — |
| New table used by ETL scripts | — | SELECT, INSERT, UPDATE |
| New table used by both | SELECT, INSERT, UPDATE | SELECT, INSERT, UPDATE, (DELETE if bulk reload) |
| New view | SELECT | SELECT (if ETL queries it) |
| New stored procedure | — | EXECUTE (if ETL calls it) |
