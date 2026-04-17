# SQL Conventions

## Database Platform

- **Server:** Azure SQL Server (SQL Server compatible)
- **Database:** liberty_link_stage
- **Server Address:** liberty-link.database.windows.net

## Mandatory Table Fields

Every table MUST include:

```sql
CREATE TABLE <table_name> (
    id INT IDENTITY(1,1) PRIMARY KEY,
    -- ... table-specific columns ...
    sql_user NVARCHAR(100) DEFAULT SUSER_SNAME(),
    date_created DATETIME DEFAULT GETDATE(),
    date_modified DATETIME DEFAULT GETDATE(),
    is_invalid BIT DEFAULT 0
);
```

## Naming Conventions

| Object | Convention | Examples |
|--------|-----------|----------|
| Tables | `<domain>_<name>` | `moct_visit`, `woo_orders`, `rxcs_price_plan` |
| Views | `view_<domain>_<name>` | `view_moct_active_visits` |
| Stored Procs | `usp_<action>_<name>` | `usp_etl_merge_orders`, `usp_insert_visit` |
| Indexes | `IX_<table>_<columns>` | `IX_moct_visit_date_created` |
| Triggers | `TR_<table>_<action>` | `TR_moct_visit_update_modified` |
| Migration scripts | `migration_<description>.sql` | `migration_grant_permissions_moct_notes.sql` |

## Table Domain Prefixes

| Prefix | Domain | Description |
|--------|--------|-------------|
| `moct_*` | Core MOCT | Medical office consultation tracking |
| `emed_*` | eMed | Users, email, SMS, billing, pricing |
| `rxcs_*` | Rx Compound Store | Pharmacy data + pricing |
| `mmed_*` | Mister Meds | Pharmacy data |
| `woo_*` | WooCommerce | Staging tables for WordPress orders |
| `wpforms_*` | WPForms | Patient questionnaires |

## Key Rules

1. **Soft deletes only** — use `UPDATE is_invalid = 1`, never `DELETE` from the app layer
2. **No DDL from app users** — only the admin account can CREATE/ALTER/DROP
3. **Explicit permissions** — every new object needs GRANT statements (see sql-safety rule)
4. **Migrations are additive** — never destructive schema changes without a migration plan
