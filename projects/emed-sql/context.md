# emed_sql - SQL Schemas Context

## Overview
- **Purpose:** SQL schema definitions for the eMed platform
- **Repo:** https://github.com/Earth-Science-Tech/emed_sql
- **Branch:** `main`
- **Database:** liberty_link_stage @ liberty-link.database.windows.net
- **Usage:** Git submodule in emed_etl; schema docs copied to emed_app

## File Organization (flat, prefix-based)

| Prefix | Purpose | Examples |
|--------|---------|---------|
| `table_*.sql` | Table creation (10 files) | `table_moct_tables.sql` |
| `procedure_*.sql` | Stored procedures (2 files) | `procedure_etl_merge.sql` |
| `migration_*.sql` | Schema migrations + GRANTs (3 files) | `migration_grant_permissions_*.sql` |
| `indexes_*.sql` | Index scripts (1 file) | `indexes_performance.sql` |
| `trigger_*.sql` | Trigger definitions (1 file) | `trigger_date_modified.sql` |
| `create_emed_*_user.sql` | DB user creation | `create_emed_app_user.sql` |

## Critical Protocols

1. **All tables must include mandatory fields** (id, sql_user, date_created, date_modified, is_invalid)
2. **All new objects need GRANT statements** (see `skills/create-table.md`)
3. **Migrations are additive** — never destructive without a plan
