# Skill: Extract Schema

## Trigger

When the user says **"update your database knowledge"** or when database schema changes are detected.

## What to Do

1. Run the schema extraction script from emed_app root:
   ```bash
   python python/extract_schema.py
   ```
2. Read the updated output: `sql/info.claude`
3. Confirm to user: "Updated database schema documentation"

## What It Generates

The `extract_schema.py` script connects to Azure SQL and generates `sql/info.claude` containing:
- All table schemas with columns, data types, nullability, defaults
- Primary keys, foreign keys, and indexes
- All views with column definitions and SQL source
- All stored procedures with parameters and SQL source

## When to Run

- After creating new tables, views, or stored procedures
- After schema migrations
- When the user asks about table structure and info.claude might be stale
- Periodically to keep documentation current

## Applies To

- **emed_app** — script lives in `python/extract_schema.py`, output goes to `sql/info.claude`
