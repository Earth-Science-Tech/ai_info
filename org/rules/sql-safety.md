# SQL Safety Rules

## Mandatory Table Fields

ALL tables in the database MUST include these fields:

```sql
id INT IDENTITY(1,1) PRIMARY KEY,
sql_user NVARCHAR(100) DEFAULT SUSER_SNAME(),
date_created DATETIME DEFAULT GETDATE(),
date_modified DATETIME DEFAULT GETDATE(),
is_invalid BIT DEFAULT 0
```

## Least-Privilege Database Users

The platform uses two application-level database users. **Never use the admin account in application code.**

| User | Purpose | Used By |
|------|---------|---------|
| `emed_app` | Node.js web application | emed_app |
| `emed_etl` | Python ETL scripts | emed_etl |

## MANDATORY: Permission Grants for New Objects

**Every new table, view, or stored procedure requires explicit GRANT statements.** These users have NO default permissions.

### When creating a new table:
1. Create the table as normal
2. Determine which users need access (emed_app, emed_etl, or both)
3. Create a migration script: `migration_grant_permissions_<name>.sql`

### Template:
```sql
-- For emed_app (Node.js):
GRANT SELECT ON <table_name> TO emed_app;
GRANT INSERT ON <table_name> TO emed_app;
GRANT UPDATE ON <table_name> TO emed_app;

-- For emed_etl (Python ETL) - only if ETL accesses this table:
GRANT SELECT ON <table_name> TO emed_etl;
GRANT INSERT ON <table_name> TO emed_etl;
GRANT UPDATE ON <table_name> TO emed_etl;
```

### Permission Rules
- **Never grant DELETE to emed_app** — uses soft delete (`UPDATE is_invalid = 1`). Exception: `sessions` table
- **Never grant DDL** (CREATE, ALTER, DROP) — explicitly DENYed for both users
- **Grant DELETE to emed_etl** only for bulk delete-and-reload tables
- **Grant EXECUTE** on stored procedures to emed_etl if ETL calls them
- Temp tables (#TempXxx) don't need permissions

### Quick Decision Matrix

| Scenario | emed_app | emed_etl |
|----------|----------|----------|
| Table used by Node.js routes | SELECT, INSERT, UPDATE | — |
| Table used by ETL scripts | — | SELECT, INSERT, UPDATE |
| Table used by both | SELECT, INSERT, UPDATE | SELECT, INSERT, UPDATE, (DELETE if bulk reload) |
| New view | SELECT | SELECT (if ETL queries it) |
| New stored procedure | — | EXECUTE |
