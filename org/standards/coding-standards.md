# Coding Standards

## Project Structure

Recommended layout for all ETST projects:

```
project_root/
├── CLAUDE.md                    # AI context (architecture, protocols, gotchas)
├── README.md                    # Human-facing setup & overview
├── .gitignore
├── .env.example                 # Template for required env vars (no secrets)
├── .editorconfig                # Universal editor settings
├── Entry point file             # app.js / main.py — ONE clear entry
├── .claude/                     # Claude Code config
│   ├── settings.json            # Project-level permissions
│   └── commands/                # Shared slash commands
├── .github/                     # GitHub config
│   ├── workflows/               # CI workflows
│   └── dependabot.yml
├── server/                      # Backend logic (if applicable)
│   ├── <module>.js              # snake_case, one file per concern
│   ├── middleware/              # Cross-cutting concerns
│   └── routes/route_<domain>.js # HTTP routes grouped by domain
├── views/                       # Templates (if applicable)
│   ├── <feature>/              # kebab-case subdirs
│   └── partials/               # Reusable fragments
├── public/                      # Static assets
├── scripts/                     # Standalone scripts (ETL, CLI tools)
├── sql/                         # Database schemas
└── config/                      # Non-secret config
```

### Key Principles

1. **Flat over nested** — prefix naming over deep nesting
2. **Prefix-based grouping** — `route_*`, `table_*`, `shared_*`
3. **Feature directories only for views** — templates get subdirectories by feature
4. **One entry point** — single clear entry file at root
5. **Middleware is separate** — cross-cutting concerns in their own directory
6. **Scripts are standalone** — ETL and utilities in `scripts/`, not mixed with server code
7. **SQL schemas are shared** — can be a separate repo used as submodule

## Code Style & Tooling

### Formatting (automated)

| Language | Tool | Config file | Indent |
|----------|------|-------------|--------|
| JS/TS | Prettier | `.prettierrc` | 2 spaces |
| Python | Ruff | `ruff.toml` | 4 spaces |

### Linting

| Language | Tool | Config file |
|----------|------|-------------|
| JS/TS | ESLint | `eslint.config.js` |
| Python | Ruff | `ruff.toml` |

### EditorConfig (every repo)

```ini
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.py]
indent_size = 4

[*.md]
trim_trailing_whitespace = false
```
