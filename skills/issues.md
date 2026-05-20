# Skill: Issues (Read the In-App Issue Queue)

## Trigger

When the user says **"show me open issues"**, **"what issues are open?"**, **"list issues"**, **"read issue N"**, **"what's in the issue queue?"**, or similar.

This skill is the entry point for the user's "spin up parallel Claude sessions per issue" workflow — each session reads from the SQL `emed_issue` table, picks an issue, and works on a fix.

## What to Do

### 1. Decide the query shape

Default behavior: list **open + triaged + in_progress** issues, ordered by status then `date_created DESC`.

If the user named filters in their request, honor them:
- "show open bugs" → status='open' AND category='bug'
- "issues from MOCT users" → submitted_by_role='MOCT'
- "what about issue #42?" → fetch by id (use the detail query below)
- "all resolved issues this week" → status='resolved' AND date_created >= 7 days ago

### 2. Run a one-shot Node script

Use the `mssql` + `dotenv` pattern from `reference_run_sql.md`. Run from `emed_app/` so `.env` loads. Don't reach into the running app's connection pool.

```bash
cd emed_app
node -e "
require('dotenv').config();
const sql = require('mssql');
(async () => {
  const pool = await sql.connect({
    user: process.env.DB_USER, password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER, database: process.env.DB_NAME,
    options: { encrypt: true, enableArithAbort: true, trustServerCertificate: false }
  });
  const r = await pool.request().query(\`
    SELECT id, title, category, severity, status,
           submitted_by_app_user, submitted_by_role,
           github_issue_number, github_issue_url,
           page_url, date_created,
           LEFT(description, 500) AS description_preview
    FROM emed_issue
    WHERE is_invalid = 0
      AND status IN ('open', 'triaged', 'in_progress')
    ORDER BY
      CASE status WHEN 'open' THEN 1 WHEN 'triaged' THEN 2 ELSE 3 END,
      date_created DESC
  \`);
  console.log(JSON.stringify(r.recordset, null, 2));
  await pool.close();
})().catch(e => { console.error(e); process.exit(1); });
"
```

For a single issue by id (full detail including console errors and full description), select all columns + LEFT JOIN attachments by count.

### 3. Present the result

Format the result as a compact summary the user (or you, in a follow-up session) can act on:

```
Open issues (3):

#42  [bug]      Visit page crashes when status is empty
     by alice (MOCT) · 2026-05-04 · /moct/visit/123
     "Clicking 'Save' on a visit with empty status throws TypeError..."

#43  [feature]  Bulk-export prescriptions to CSV
     by bob (Billing) · 2026-05-05
     "Could we add a CSV export button on the invoices page..."

#44  [bug]      ScriptSure modal stuck on loading spinner
     by carol (Prescriber) · 2026-05-06
     "The modal opens but the spinner never goes away..."
```

Keep titles short, lead with the id and category, and put the description preview on its own line so the user can scan.

### 4. Suggest next steps if appropriate

- If the user says "let's work on #42", read the full row (status, console errors, attachments) and discuss the fix approach.
- If they say "just give me the list", stop after step 3.

## Important Notes

- The SQL `emed_issue` row is the **source of truth** — always trust it over the GitHub mirror, since a GitHub create can fail without affecting the SQL row.
- Don't fetch attachment payloads (NVARCHAR(MAX) base64) in list queries — they bloat the result. Fetch them via `/api/issues/:id/attachment/:att_id` when actually needed.
- Console errors live in `console_errors_json` as a JSON array. Parse and pretty-print when discussing a specific issue.

## Applies To

- emed_app (`emed_issue` and `emed_issue_attachment` tables)
- Requires `emed_app/.env` with DB credentials
