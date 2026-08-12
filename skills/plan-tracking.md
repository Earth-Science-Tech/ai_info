# Skill: Plan Tracking (shared feature/plan records in `ai_info/plans/`)

## Trigger

- Starting non-trivial work: **"start a plan"**, "new feature", finishing **plan mode**, or cutting a
  `feat/*` branch for anything more than a one-line fix.
- **"update the plan"**, "mark this done in dev/prod", "what's the status of <feature>".
- **Taking over** someone else's work: "pick up <feature>", "what's left on <feature>".
- **Proactively:** whenever you begin, meaningfully advance, or ship a feature, create/update its plan
  record without being asked — that is how the team keeps a shared, handoff-ready history.

## Why this exists

Engineers run many Claude instances across machines and branches. A plan that lives only in one chat (or
one laptop's `.claude/plans/`) is invisible to everyone else. `ai_info/plans/` is the **team-shared,
version-controlled record** of every feature/project: what it is, which branch carries it, who worked on
it, and **where it is in the pipeline** — so any engineer's Claude can read the current state and take
over. It complements (does not replace):
- **Local memory** (`~/.claude/.../memory/`) — your *private* cross-session context.
- **Claude Code plan mode** (`.claude/plans/*.md`) — a *local* draft. When a plan-mode plan is approved
  for a feature, **persist a copy here** with the metadata below.

## Where plans live

- **`ai_info/plans/<slug>.md`** — one file per feature/project. `<slug>` = the feature-branch name minus
  `feat/` (e.g. branch `feat/per-page-permissions` → `plans/per-page-permissions.md`). This convention is
  what associates a plan with its branch.
- **`ai_info/plans/README.md`** — the **index**: one row per plan (status, project, branch, developers,
  updated). Scan it first when starting or taking over work. Keep it in sync whenever you add a plan or
  change a status.

## Plan file format

YAML frontmatter (machine-readable) + a markdown body. Template:

```markdown
---
title: <Human title>
slug: <kebab-slug matching the file name / feature branch>
status: In-Progress                 # see lifecycle below
project: emed_app                   # emed_app | emed_etl | emed_sql | multi
branches:                           # the feature branch(es) that carry this work
  - emed_app: feat/<slug>
developers:                         # GitHub handles — resolve names via team/roster.md
  - <github-handle>
prs: []                             # e.g. ["emed_app#412 (feat->main)"]; fill as they open
tags: []                            # optional: release tag(s) once shipped, e.g. ["1.0.190"]
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
related: []                         # optional [[other-slug]] links
---

# <Title>

## Status & history
- <YYYY-MM-DD> — Not Started → In-Progress (<handle>)
- <YYYY-MM-DD> — In-Progress → Completed in Dev (<handle>)

## Summary
What it is and why, in a few sentences. Enough for a new engineer to grasp the goal.

## Design / approach
Key decisions, architecture, the load-bearing rules. Link files as `repo/path.js:line`.

## Rollout / remaining
What ships when; what's left; landmines; how to validate. The takeover checklist.
```

Use **absolute dates** (convert "today"/"next week" — a stale relative date misleads later). Keep the
body focused; a plan can exceed the 200-line guideline for *other* ai_info files, but stay scannable.

## Status lifecycle (the four canonical states)

| Status | Meaning |
|--------|---------|
| **Not Started** | Planned/scoped, no code yet. |
| **In-Progress** | Actively being built (on its `feat/*` and/or `dev`). |
| **Completed in Dev** | Merged to `dev` / live on the Azure dev slot; validated there, **not yet in prod**. |
| **Completed in Production** | Shipped to prod (a `feat/* → main` PR merged + tagged). |

Optional extra states when reality needs them: **On Hold** (parked — mirrors an `emed_sql/migrations/wip/`
feature) and **Abandoned** (won't ship; say why). Never silently delete a plan — move it to Abandoned so
the history survives.

**Every status change appends a `Status & history` line** (date → new state, your handle) and updates
`updated:` + the index row. That append-only log is the handoff trail.

## What to do

1. **Starting work** → create `plans/<slug>.md` from the template (`status: Not Started` or `In-Progress`),
   add yourself to `developers`, add a row to `plans/README.md`.
2. **Advancing / merging to dev** → set `status: Completed in Dev`, append a history line, note the branch
   + any PRs.
3. **Shipping to prod** → set `status: Completed in Production`, add the release `tags`, append history.
   (The `push-prod` / `push-pr` skills point back here — update the plan as part of the release.)
4. **Taking over** → read `plans/README.md`, open the plan, follow its "Rollout / remaining", and add
   yourself to `developers` when you start contributing.
5. **Commit to `ai_info` `main`** (knowledge base — no PR), staging only your plan file(s) + the index:
   `git add plans/<slug>.md plans/README.md && git commit -m "plan: <slug> -> <status>"`. Never
   `git add -A` (other unrelated edits may be in the tree).

## Rules

- **One plan per feature/branch**, named for the branch. Don't fork a second plan for the same work.
- **Append-only history** — never rewrite past status lines; add new ones.
- **Keep developers + branch accurate** — this is what makes takeover possible. Resolve handles via
  [`team/roster.md`](../team/roster.md); never disambiguate a "Carlos" on first name alone.
- **The index is the front door** — a plan that isn't in `README.md` is effectively invisible.

## Applies to

- All eMed repos. The plan record is repo-agnostic (`project: multi` when it spans repos).
- Related: [push-prod.md](push-prod.md), [push-pr.md](push-pr.md) (status → Completed in Production),
  [open-pr.md](open-pr.md), [`org/rules/branch-and-database-gates.md`](../org/rules/branch-and-database-gates.md).
