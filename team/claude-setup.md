# Claude Code Setup Guide

## How Shared Knowledge Works

Each project's `CLAUDE.md` contains `@import` directives that pull in shared knowledge from the `ai_info` repo:

```markdown
@../ai_info/org/rules/org-defaults.md
@../ai_info/org/rules/sql-safety.md
@../ai_info/org/rules/knowledge-sharing.md
@../ai_info/skills/push-prod.md
```

When you start Claude Code in any project, this shared knowledge loads automatically.

## Requirements

1. **ai_info repo must be cloned** as a sibling of the project repos:
   ```
   eMed/
   ├── emed_app/
   ├── emed_etl/
   ├── emed_sql/
   └── ai_info/     ← must exist here
   ```

2. **First-time approval:** Claude Code will prompt you to approve the `@import` file references on first use. Accept them.

## Setup Script

Run once after cloning ai_info:

```powershell
.\ai_info\scripts\setup.ps1
```

This copies:
- Rule files → `.claude/rules/` in each project
- Command files → `.claude/commands/` in each project

## Syncing Updates

When ai_info gets new content, sync it:

```powershell
# Pull latest
cd ai_info && git pull

# Re-copy rules and commands
.\scripts\sync-rules.ps1
```

Or use the `/sync-knowledge` command within any Claude Code session.

## Knowledge Sharing

Claude automatically commits new knowledge to ai_info when it discovers something useful (see `org/rules/knowledge-sharing.md`). You can also manually trigger this with the `/share-knowledge` command.

## Personal Preferences

Things specific to you (response style, editor preferences) go in Claude's local memory (`~/.claude/`), not in ai_info.
