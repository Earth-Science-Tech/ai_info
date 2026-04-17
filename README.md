# ai_info - Shared AI Knowledge Repository

**Organization:** Earth Science Tech, Inc. (ETST)
**Purpose:** Centralized, version-controlled knowledge base for all Claude AI instances across the engineering team.

## What This Is

This repo is the shared brain for our team's Claude Code instances. It contains:

- **Standards** — Coding conventions, SQL rules, security protocols
- **Skills** — Reusable task instructions (e.g., "push prod", "create table")
- **Project Knowledge** — Architecture, patterns, and context for each project
- **Company Info** — Subsidiary company details and integration points
- **Rules** — Files auto-loaded by Claude Code to enforce org-wide behavior

Claude instances automatically read from this repo (via `@import` in project CLAUDE.md files) and automatically commit new knowledge back when they learn something useful.

## Quick Setup

### For a new engineer

```powershell
# 1. Clone alongside existing projects (must be a sibling of emed_app, emed_etl, emed_sql)
cd "C:\Users\<username>\OneDrive - Earth Science Tech, Inc\Desktop\eMed"
git clone https://github.com/Earth-Science-Tech/ai_info.git

# 2. Run the setup script
.\ai_info\scripts\setup.ps1
```

### For an existing engineer

Same steps. The setup script is non-destructive and merges with existing configuration.

## How It Works

### Reading (automatic)

Each project's `CLAUDE.md` contains `@import` directives that pull in relevant knowledge from this repo:

```markdown
@../ai_info/org/rules/org-defaults.md
@../ai_info/skills/push-prod.md
```

When you start Claude Code in any project, the shared knowledge loads automatically.

### Writing (automatic)

Claude instances are instructed (via `org/rules/knowledge-sharing.md`) to automatically commit and push new knowledge here when they discover something worth sharing — a new skill, a convention, a gotcha, etc.

All commits go directly to `main`. No PRs needed. Git history is the audit trail.

## Directory Structure

```
ai_info/
├── org/           # Organization-wide standards, security, infrastructure, rules
├── projects/      # Per-project knowledge (emed, emed-app, emed-etl, emed-sql)
├── skills/        # Reusable Claude task instructions
├── companies/     # Subsidiary company profiles
├── team/          # Onboarding and dev environment guides
├── commands/      # Shared .claude/commands/ definitions
├── mcp/           # Future MCP server integration
└── scripts/       # Setup and sync scripts
```

## Commit Convention

Use prefixes for easy filtering in `git log`:

- `knowledge:` — New facts, architecture, patterns
- `skill:` — New or updated skill instructions
- `update:` — Edits to existing content
- `fix:` — Corrections to inaccurate information

## Team Access

All admin and dev team members have Write (push) access. No branch protection on `main`. Everyone is trusted to commit directly.
