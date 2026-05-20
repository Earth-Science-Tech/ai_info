# Skill: Resolve Issue

## Trigger

When the user says **"resolve issue N"**, **"close issue N"**, **"mark issue N as wontfix"**, **"issue N is a duplicate of M"**, or similar phrasings about an in-app `emed_issue` row.

This is for **manual** closure — when there's no `fixes emed-issue#N` commit (because the fix was a config change, a duplicate of another issue, or a "won't fix" decision). Commit-driven closure is automatic via the `push prod` skill.

## What to Do

### 1. Confirm the action

Echo back to the user what you're about to do, in one line:

```
Closing emed_issue#42 as `wontfix` with notes "Out of scope; tracked separately under #51". Proceed?
```

If the user already provided id + status + notes in their message, skip the confirmation and proceed. If anything is ambiguous, ask.

### 2. Run the resolver script

From the `emed_app` directory (so `.env` loads):

```bash
cd emed_app
node scripts/resolve_issue.js <id> <status> [notes...]
```

Where `<status>` is one of `resolved`, `wontfix`, `duplicate`.

Example:

```bash
node scripts/resolve_issue.js 42 wontfix Out of scope; tracked separately under #51
```

The script:
- Updates `emed_issue` row: status, `resolved_by_app_user`, `resolved_at`, optional `resolution_notes`
- Skips rows already in a closed status (idempotent)
- If `github_issue_number` is populated and `GITHUB_TOKEN` is set, posts a comment and closes the GitHub Issue too
- Prints a summary

### 3. Report the outcome

Relay the script's output to the user. If it skipped the row (already closed), say so. If GitHub closed succeeded, mention that. If GitHub close failed, recommend they close it manually on github.com.

## Status meanings

- **resolved** — fixed (use this when there's no commit but the underlying issue is gone, e.g. a config tweak)
- **wontfix** — deliberately not fixing (out of scope, by design, etc.)
- **duplicate** — same problem already tracked elsewhere; reference the other issue in notes

## When NOT to use this skill

- A code change fixed it → put `fixes emed-issue#N` in the commit message and let `push prod` handle it. Don't run this skill manually for those.
- The user wants to bulk-close — this skill handles one at a time. For bulk operations, write an ad-hoc query.
- The user wants to re-open a closed issue — there's no UI for that; tell them to update the row directly.

## Applies To

- emed_app (script lives in `emed_app/scripts/`)
- Requires `emed_app/.env` configured with DB and (optionally) GitHub credentials
