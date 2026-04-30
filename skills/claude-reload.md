# Skill: Claude Reload

## Trigger

When the user says **"claude reload"** (or close variants: "reload claude", "reload context", "reload claude.md", "reload imports").

## Why This Exists

CLAUDE.md and its `@import` files are loaded by Claude Code only at conversation start. If the user (or another teammate) adds a new skill, rule, or context file to ai_info mid-conversation, the running Claude instance won't automatically pick it up. Running `/clear` would force a reload but throws away all working context — losing whatever the user was teaching Claude in this session.

This skill provides a **soft reload**: re-read every file in the CLAUDE.md import chain via the Read tool. The freshly-read content lands in conversation context and takes precedence over the older copy from session start, without losing any of the in-flight work.

## What to Do

### 1. Locate the project CLAUDE.md

Start from the current working directory and walk up until a `CLAUDE.md` is found. If none exists, output `No CLAUDE.md found in current project` and stop.

### 2. Read the project CLAUDE.md

Use the Read tool on the project's `CLAUDE.md`.

### 3. Parse and re-read every @import

Every line of the form `@<path>` is an import. Resolve the path **relative to the location of the file containing the import**, then Read each one. Issue all the Read calls in parallel for speed.

If an imported file itself contains `@<path>` lines, recurse one more level. Don't go deeper than 2 levels — the ai_info structure is flat by convention.

### 4. Skip what's already auto-injected

- **MEMORY.md** at `~/.claude/projects/<encoded>/memory/MEMORY.md` — the harness re-injects this every turn. Re-reading wastes context; skip it.
- **Per-turn system reminders** — also auto-injected; skip.

### 5. Confirm to the user

Output exactly this, nothing else:

```
Reloaded <N> files:
- <relative path 1>
- <relative path 2>
- ...

Updated skills/rules will apply for the rest of this conversation.
```

No preamble, no trailing offer to do something else.

## Limitations (state these if the user asks "did it work?")

- **Not a true system-prompt reload.** Claude cannot re-trigger the harness's startup injection. The skill works by re-reading files as tool results, which functionally lets new instructions take effect because recent context dominates.
- **Cannot reload via this skill** (these need a true `/clear` or VS Code reload):
  - `settings.json` and `settings.local.json`
  - Hooks
  - Slash commands in `.claude/commands/`
  - MCP server definitions
  - Permissions and environment variables
  - The harness's global `~/.claude/CLAUDE.md` injection
- **Removed rules linger.** The original CLAUDE.md content from session start is still in Claude's context. If a rule was *deleted* between session start and reload, Claude may still partially follow the old version. This skill is best for *adding* new skills/rules, not for retracting them.
- **Chicken-and-egg.** A Claude instance that started before this skill was added won't recognize the trigger phrase — that first reload has to be invoked by manually telling Claude "re-read the CLAUDE.md and all its @imports." After that one-time bootstrap (or any `/clear`), `claude reload` works as a trigger going forward.

## Example

User: `claude reload`

Claude (after parallel Read calls):

```
Reloaded 11 files:
- emed_app/CLAUDE.md
- ai_info/org/rules/org-defaults.md
- ai_info/org/rules/sql-safety.md
- ai_info/org/rules/knowledge-sharing.md
- ai_info/projects/emed/architecture.md
- ai_info/projects/emed-app/context.md
- ai_info/skills/push-prod.md
- ai_info/skills/create-table.md
- ai_info/skills/review-pr.md
- ai_info/skills/claude-title.md
- ai_info/skills/claude-reload.md

Updated skills/rules will apply for the rest of this conversation.
```

## Applies To

- All projects, all Claude Code instances. Imported by every project's `CLAUDE.md`.
