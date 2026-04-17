# No Secrets Rule

## Never Commit Credentials

- Never commit `.env` files, API keys, passwords, connection strings, or tokens to any repository
- Every repo must have `.env` in `.gitignore`
- Every repo must have `.env.example` with all required variables and dummy/empty values

## .env Distribution Protocol

- `.env.example` is the source of truth for what variables exist
- Real `.env` values: distribute as an encrypted zip file
- Share the zip password through a separate channel (Signal, 1Password, etc.)
- Never send the zip and the password together
- CI/CD secrets go in GitHub Secrets — never in `.env` files

## What to Do If Secrets Are Committed

1. Rotate the compromised credential immediately
2. Use `git filter-branch` or BFG Repo-Cleaner to remove from history
3. Force-push the cleaned history
4. Notify the team
