# Knowledge Sharing Protocol

**CRITICAL:** Claude must follow this protocol automatically during normal work sessions.

## When to Share Knowledge (Triggers)

Automatically commit knowledge to the `ai_info` repo when ANY of these occur:

- You create a new multi-step skill or workflow (e.g., a deployment process, a debugging checklist)
- You discover a non-obvious pattern, convention, or gotcha that would benefit other team members
- You write a significant update to a project's CLAUDE.md or info.claude file
- You fix a bug that was caused by missing shared context ("if I had known X, I wouldn't have made this mistake")
- A new database table, API endpoint, or integration point is created
- Infrastructure or deployment processes change
- A new tool, library, or service is added to the stack

## When NOT to Share (Stays Local)

- Personal user preferences (response style, editor settings)
- In-progress debugging context or temporary task state
- Project-specific one-off fixes with no broader relevance
- Information that already exists in ai_info (check first!)

## How to Share (Step by Step)

1. **Pull latest:** `cd ../ai_info && git pull origin main`
2. **Find the right location:**
   - Org-wide standards/rules → `org/`
   - Project-specific → `projects/<project>/`
   - Reusable skill → `skills/`
   - Company info → `companies/`
3. **Check for duplicates:** Read the target file (if it exists) to update rather than duplicate
4. **Write or update** the appropriate markdown file
5. **Commit** with a prefixed message:
   - `knowledge: <description>` — new facts or patterns
   - `skill: <description>` — new or updated skill
   - `update: <description>` — edits to existing content
   - `fix: <description>` — corrections
6. **Push:** `git push origin main`
7. **Tell the user:** "Updated ai_info: [brief description]"

## Commit Message Format

```
knowledge: add Azure SQL connection pooling pattern

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Conflict Resolution

If `git push` fails due to conflicts:
1. `git pull --rebase origin main`
2. Resolve any merge conflicts
3. `git push origin main`

## Important

- Always commit directly to `main` — no branches or PRs needed
- Keep files concise (under 200 lines each)
- Use markdown with headers and bullet points
- Include enough context that a new team member can understand the knowledge without prior conversation
