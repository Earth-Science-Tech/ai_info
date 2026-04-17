# ai_info - Claude Code Context

This is the shared AI knowledge repository for Earth Science Tech (ETST). You are working directly on the knowledge base itself.

## What This Repo Is

A centralized, version-controlled knowledge base that all team members' Claude Code instances read from and write to. It contains org-wide standards, project-specific knowledge, reusable skills, and company information.

## How This Repo Integrates With Projects

Other projects (emed_app, emed_etl, emed_sql) import files from this repo using `@../ai_info/...` in their CLAUDE.md files. Changes here propagate to all projects on their next `git pull`.

## When Working On This Repo

- Keep files concise and scannable — these are loaded into Claude's context window
- Use markdown headers and bullet points for structure
- Don't duplicate information — link to the canonical source
- Test `@import` paths when adding new files (they resolve relative to the importing file)
- Commit directly to `main` with descriptive prefixed messages:
  - `knowledge:` for new facts
  - `skill:` for new task instructions
  - `update:` for edits
  - `fix:` for corrections

## File Organization

| Directory | Purpose | Audience |
|-----------|---------|----------|
| `org/standards/` | Coding conventions, commit format, SQL rules | All projects |
| `org/security/` | Env handling, SQL permissions, secrets | All projects |
| `org/infrastructure/` | Azure, CI/CD, deployment patterns | All projects |
| `org/rules/` | Auto-loaded rule files for `.claude/rules/` | Claude Code |
| `projects/` | Per-project architecture and context | Specific projects |
| `skills/` | Reusable task instructions | All projects |
| `companies/` | Subsidiary company profiles | All projects |
| `team/` | Onboarding and dev environment | Humans |
| `commands/` | Shared slash command definitions | Claude Code |
| `scripts/` | Setup and sync automation | Humans |

## Key Rule: Keep Files Under 200 Lines

Claude Code recommends CLAUDE.md files stay under 200 lines for optimal adherence. Apply this to all knowledge files — if a file grows beyond 200 lines, split it into focused sub-files.
