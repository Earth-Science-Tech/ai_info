# emed_sql Schema Conventions

## File Naming

- `table_<group>.sql` — Table creation scripts
- `procedure_<name>.sql` — Stored procedures
- `migration_<description>.sql` — Schema changes and permission grants
- `indexes_<name>.sql` — Index definitions
- `trigger_<name>.sql` — Trigger definitions

## Table Naming

Use domain prefix: `moct_*`, `emed_*`, `rxcs_*`, `mmed_*`, `mdvo_*`, `woo_*`, `wpforms_*`

## Mandatory Fields

Every table must include: `id`, `sql_user`, `date_created`, `date_modified`, `is_invalid`

## Permission Grants

Every new table/view/procedure needs a `migration_grant_permissions_*.sql` file. See `org/rules/sql-safety.md`.
