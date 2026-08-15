---
title: Sync Everything skill (pull all repos + reload skills/plans mid-session)
slug: sync-everything-skill
status: Completed in Production
project: ai_info
branches:
  - ai_info: main (direct commits — knowledge base, no PR)
developers:
  - nicholas-cardell
prs:
  - "ai_info@<commit> (skill + sync_repos.sh + org-defaults nesting + .gitattributes)"
tags: []
created: 2026-08-15
updated: 2026-08-15
related: []
---

# Sync Everything skill

## Status & history
- 2026-08-15 — Not Started → **Completed in Production** (nicholas-cardell). Built
  `skills/sync-everything.md` + helper `skills/sync_repos.sh`, wired via nested `@import` in
  `org/rules/org-defaults.md`, pushed to ai_info `main`. Draft was adversarially reviewed by a
  Workflow (git-safety lens found no data-loss issues); fixed the 4 confirmed findings before shipping.

## Summary
`"sync everything"` — one phrase that (1) safely git-syncs all four eMed repos, (2) soft-reloads the
CLAUDE.md `@import` chain so newly-wired skills/rules take effect, and (3) makes the instance current on
every plan's status — without a `/clear`. So a long-running Claude picks up skills/plans other teammates
added after the session started. Requested by Nicholas 2026-08-15.

## Design / approach
- **Safe git (`sync_repos.sh`):** per repo, fetch + **fast-forward-only** pull of the CURRENT branch.
  NEVER merges/rebases/force/reset/stash/commit/branch-switch; skips + reports diverged / ff-blocked /
  no-upstream / detached / not-cloned; leaves untracked & uncommitted work untouched. Resolves the repos
  as siblings of `ai_info` (cwd-independent).
- **Full inventory every run:** the script always prints every `skills/*.md` and every `plans/*.md` with
  its `status:` — so awareness does NOT depend on this pull's delta (a skill already on disk from an
  out-of-band pull is still surfaced). The caller reconciles the inventory against what it already knows
  and Reads anything unfamiliar.
- **Reload uses a KNOWN chain, not a cwd walk-up:** re-read `emed_app/CLAUDE.md` (sibling of ai_info) +
  its `@import` chain (which pulls `org/rules/org-defaults.md`, where org-wide skills/rules are wired).
  A cwd walk-up would no-op at the `eMed/` umbrella root.
- **Additive-reload caveat:** a soft reload can add/update but NOT reliably retract a skill/rule deleted
  since session start (old text lingers); that needs a fresh session — documented in the skill.
- **Propagation:** nested `@../../skills/sync-everything.md` in `org/rules/org-defaults.md` (imported by
  all three repos' CLAUDE.md) → reaches every dev's Claude on an ai_info `git pull`.
- Added `ai_info/.gitattributes` (`*.sh text eol=lf`) so the helper runs under Git Bash on Windows.

## Review findings fixed (from the adversarial Workflow)
- HIGH — awareness only covered the pull delta → **full inventory every run**.
- MEDIUM — reload no-op at umbrella root (cwd walk-up) → **reload a known sibling chain (emed_app)**.
- LOW — silent offline fetch → **surface `WARN_FETCH_FAILED`**.
- LOW — missing additive-reload caveat → **added it** (mirrors claude-reload).

## Rollout / remaining
- Live for all instances on their next `ai_info` pull. Validated on this machine (all repos up to date;
  emed_etl correctly SKIP_NO_UPSTREAM — its feature branch's upstream was merged/deleted).
