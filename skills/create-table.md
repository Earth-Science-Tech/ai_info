# Skill: Create Table

## Trigger

When creating a new database table in the eMed platform.

## What to Do

### Step 1: Create the table

Write a `table_<name>.sql` file in the emed_sql repo with:
- All required mandatory fields (id, sql_user, date_created, date_modified, is_invalid)
- Table-specific columns
- Appropriate indexes

```sql
CREATE TABLE <domain>_<name> (
    id INT IDENTITY(1,1) PRIMARY KEY,
    -- table-specific columns here
    sql_user NVARCHAR(100) DEFAULT SUSER_SNAME(),
    date_created DATETIME DEFAULT GETDATE(),
    date_modified DATETIME DEFAULT GETDATE(),
    is_invalid BIT DEFAULT 0
);
```

### Step 2: Create permission grants

Write a `migration_grant_permissions_<name>.sql` file:

```sql
-- Determine which users need access:
-- Does the Node.js app use it? → Grant to emed_app
-- Do the Python ETL scripts use it? → Grant to emed_etl
-- Both? → Grant to both

GRANT SELECT ON <table_name> TO emed_app;
GRANT INSERT ON <table_name> TO emed_app;
GRANT UPDATE ON <table_name> TO emed_app;

-- Only if ETL also needs access:
GRANT SELECT ON <table_name> TO emed_etl;
GRANT INSERT ON <table_name> TO emed_etl;
GRANT UPDATE ON <table_name> TO emed_etl;
```

### Step 3: Update documentation

- Run `extract-schema` skill to refresh `sql/info.claude`
- Update relevant `info.claude` files in the project that uses the table

### Step 4: Share knowledge

If this table represents a new domain or significant feature, update `ai_info/org/infrastructure/azure-sql.md` with the new table prefix or domain.

## Rules

- Never grant DELETE to emed_app (soft delete only)
- Never grant DDL to application users
- Use domain prefix naming: `moct_*`, `emed_*`, `rxcs_*`, etc.
- Always include all 5 mandatory fields

## Applies To

- **emed_sql** — table and migration scripts
- **emed_app** — permission grants needed for Node.js access
- **emed_etl** — permission grants needed for ETL access
