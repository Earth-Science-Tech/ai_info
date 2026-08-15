# Skill: Sync Everything (pull all repos + reload skills/plans mid-session)

## Trigger

When the user says **"sync everything"**, **"sync all repos"**, **"sync and reload"**, **"pull everything
and reload"**, or similar.

## Why this exists

Skills, rules, and plans live in the shared `ai_info` repo and are loaded into a Claude session **only at
start**. When a teammate adds a new skill or updates a plan mid-session, a running instance won't see it.
"Sync everything" **pulls all four eMed repos** and then **re-reads** the knowledge so a long-running
instance learns newly-added skills and stays current on every plan's status — without a `/clear` that
would throw away the working context. It is [claude-reload.md](claude-reload.md) **plus** a safe
cross-repo git sync **plus** plan/skill awareness.

## What to do

### 1. Sync the repos (safe git — fast-forward only)

Run the helper via the **Bash tool** (it resolves the four repos as siblings of `ai_info`, so cwd doesn't
matter):

```bash
bash "<path-to>/ai_info/skills/sync_repos.sh"
```

For each repo (ai_info first) it fetches and does a **fast-forward-only pull of the current branch**, then
prints a full **ai_info inventory** (every skill; every plan with its `status:`). Read the whole report.
Per-repo `status:` values:
- `PULLED N …` — updated; commit subjects (and, for ai_info, the changed `skills/`+`plans/`+`org/` files)
  are listed.
- `UP_TO_DATE` — nothing pulled (but still reconcile against the inventory — see Steps 3–4).
- `WARN_FETCH_FAILED` — offline/VPN; tell the user the sync couldn't reach origin and counts may be stale.
- `SKIP_DIVERGED` / `SKIP_FF_BLOCKED` / `SKIP_NO_UPSTREAM` / `SKIP_DETACHED_HEAD` / `NOT_CLONED` — **left
  untouched on purpose.** Surface each to the user (e.g. "emed_sql skipped — local changes; commit or
  stash, then re-run"). Do **not** force, merge, rebase, stash, reset, or switch branches to "fix" them.

Each repo syncs **whatever branch it is on** (devs are often on different `feat/*` branches). `ai_info` is
the one that carries skills/plans and is normally on `main`.

### 2. Reload skills & rules (soft reload — no `/clear`)

Re-read a **known** CLAUDE.md `@import` chain so newly-wired skills/rules take effect. **Do NOT use a cwd
walk-up** (claude-reload's default) — when this is run from the `eMed/` umbrella root there is no CLAUDE.md
there and the reload would silently no-op.

- Resolve **`emed_app/CLAUDE.md`** as a sibling of `ai_info` and **Read it plus every `@import` in its
  chain, recursing 2 levels, in parallel.** emed_app's chain imports `org/rules/org-defaults.md`, which is
  where org-wide skills/rules (including this one) are wired — re-reading it is what makes a newly-wired
  skill/rule take effect. (If `emed_app` isn't cloned, use `emed_sql/CLAUDE.md` or `emed_etl/CLAUDE.md` —
  all three import `org-defaults.md`.)
- If you're actively working **inside** a specific repo, reload that repo's CLAUDE.md chain too.
- Skip re-reading `MEMORY.md` and per-turn system reminders (the harness re-injects those).
- Say in the report **which** chain you reloaded.

### 3. Catch up on plans

- **Read `ai_info/plans/README.md`** (the index).
- The script's inventory lists **every plan with its `status:`**. Compare it to what you knew: for any
  plan whose status changed, that's new to you, or that the pull flagged as `A/M/R` under `plans/`,
  **Read that plan file** so you're current on it. (See [plan-tracking.md](plan-tracking.md) for the
  status lifecycle.)

### 4. Learn skills you don't already know

The script prints a full `skills:` inventory **every run** (not just this pull's changes). **Reconcile it
against the skills you already have loaded this session, and Read any skill file you don't already know** —
whether it was just pulled, renamed, or was already on disk from an earlier/out-of-band pull. Don't rely
only on the pull delta: a brand-new skill only auto-loads once it's wired into an `@import`, so reading it
here is what lets the current session use it immediately.

### 5. Report

Concise summary, honest about what was and wasn't done:

```
Synced 4 repos:
- ai_info    main   → pulled 2   (new skill: <name>; plan status change: <slug> → Completed in Dev)
- emed_app   feat/… → up to date
- emed_sql   main   → SKIPPED (local changes) — commit/stash and re-run
- emed_etl   feat/… → SKIPPED (no live upstream) — switch to main to update

Reloaded emed_app/CLAUDE.md + N imports (org-defaults etc.).
Plans: <N> tracked; current statuses in plans/README.md.
Skills learned this sync: <names>   (or "none new" — say "none new", not just "none", so it's clear
                                       you checked the full inventory, not that you skipped the check)
These additions/updates apply for the rest of this conversation.
```

If nothing changed anywhere and the inventory matches what you already knew, say "already fully in sync."

## Safety & limitations

- **Never** merges, rebases, force-pushes, resets, stashes, commits, or switches branches. Pulls are
  **`--ff-only`** on the current branch; anything that can't fast-forward is skipped and reported.
- **Never** touches untracked or uncommitted work — a repo whose local changes would block a fast-forward
  is skipped, not overwritten.
- **Read-only reload** — Steps 2–4 only Read files.
- **The soft reload is additive.** It can ADD or UPDATE skills/rules, but it cannot reliably **retract**
  one that was **deleted** since the session started — the old instructions linger in context even after
  the file and its `@import` are gone (and the pull physically deletes the file, which can make it *look*
  retracted when it isn't). If a skill/rule was removed and must stop applying, start a fresh session or
  `/clear`. (Same caveat as [claude-reload.md](claude-reload.md).)

## Applies to

- All eMed repos, all developer Claude instances (propagated via the nested import in
  `org/rules/org-defaults.md`). Ships with its helper `sync_repos.sh` in `ai_info/skills/`.
- Related: [claude-reload.md](claude-reload.md) (the reload half), [plan-tracking.md](plan-tracking.md)
  (plan statuses), [`team/roster.md`](../team/roster.md).
