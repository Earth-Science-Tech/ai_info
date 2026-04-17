# Documentation Protocol

## Required Files (Every Project)

| File | Purpose | Audience |
|------|---------|----------|
| `CLAUDE.md` | Architecture, non-obvious patterns, gotchas | AI (Claude Code) |
| `README.md` | Setup instructions, dependencies, deployment | Humans |
| `.env.example` | All required env vars with dummy values | Both |

## CLAUDE.md Guidelines

### What to include:
- Architectural decisions and non-obvious patterns
- Gotchas and known quirks
- Project-specific conventions that differ from org defaults
- Key commands if they're non-standard
- `@import` directives for shared ai_info knowledge

### What NOT to include:
- Boilerplate or padding
- Information that's in the README
- Things Claude can discover by reading the code
- Secrets or credentials

### Keep it focused:
- Under 200 lines for optimal Claude adherence
- Use markdown headers and bullet points
- Update timestamps when making changes

## Shared Knowledge (@import)

All project CLAUDE.md files should import shared knowledge from ai_info:

```markdown
# Shared Knowledge (ai_info)
@../ai_info/org/rules/org-defaults.md
@../ai_info/org/rules/sql-safety.md
@../ai_info/org/rules/knowledge-sharing.md
```

If ai_info is not cloned, add a comment with clone instructions:
```markdown
<!-- Clone ai_info if missing: git clone https://github.com/Earth-Science-Tech/ai_info.git ../ai_info -->
```

## .claude Directory

### Commit (shared):
- `.claude/settings.json` — project-level permissions
- `.claude/commands/` — shared slash commands

### Gitignore (personal):
- `.claude/settings.local.json` — machine-specific overrides
- `.claude/memory/` — auto-generated memory files
