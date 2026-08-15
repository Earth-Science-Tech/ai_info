---
title: Share Plan skill (email a plan .md to a teammate)
slug: share-plan-skill
status: Completed in Production
project: ai_info
branches:
  - ai_info: main (direct commits — knowledge base, no PR)
developers:
  - nicholas-cardell
prs:
  - "ai_info@dd4b901 (skill + org-defaults nesting + plan-tracking xref)"
  - "ai_info@<roster+plan commit> (fill 4 missing emails, add this plan record)"
tags: []
created: 2026-08-15
updated: 2026-08-15
related: []
---

# Share Plan skill (email a plan .md to a teammate)

## Status & history
- 2026-08-15 — Not Started → **Completed in Production** (nicholas-cardell). Built `skills/share-plan.md`,
  propagated to all three repos via a nested `@import` in `org/rules/org-defaults.md`, pushed to ai_info
  `main`. Same day: filled the four missing roster emails and ran a self-send end-to-end test.

## Summary
A skill so any developer's Claude can email the plan they're working on to a teammate — for hand-off or
review. `"share plan with <name>"`. Complements `skills/plan-tracking.md`: plan-tracking keeps the shared
**record** in `ai_info/plans/`; share-plan **pushes a copy** to a teammate's inbox (with the `.md`
attached). Requested by Nicholas 2026-08-15.

## Design / approach
- **Recipient** resolved from `team/roster.md` (markdown table; no JSON source). Never guess an email —
  a `_(confirm)_` cell is a hard STOP. Two-Carlos gotcha → ask which. Recipients must be roster teammates
  (internal hand-off only).
- **Plan** resolved by: explicit slug > current `feat/<slug>` branch → `plans/<slug>.md` > this session's
  plan (persist via plan-tracking first) > by developer handle.
- **Delivery: self-contained MS Graph send**, run from `emed_app/` (uses the shared `AZURE_*` app-reg
  creds in `emed_app/.env` + emed_app's node deps). **Deliberately NOT `emed_app/server/email_azure.js`**:
  that module computes `test_mode = is_local_host()` (`IS_LOCAL_HOST===1`) at load and its `send()`
  silently redirects the recipient to `DEV_EMAIL`/Nick — a teammate would never receive the plan. Sends
  from the dev's own mailbox, auto-falling back to `noreply@rxcompoundstore.com` if the tenant lacks
  send-as rights; `replyTo` is always the sending dev.
- **Preview + confirm before send** by default (email is outbound/irreversible); skipped when the user
  says to just send.
- **Propagation:** nested `@../../skills/share-plan.md` in `org/rules/org-defaults.md` (imported by all
  three repos' CLAUDE.md), so teammates get it on an `ai_info` `git pull` — no emed_app/sql/etl edit.

## Rollout / remaining
- **Emails:** all four missing roster emails supplied 2026-08-15 (Mario `mario.tabraue@rxcs.net`, Chris
  `chris.rose@etst.com` — note `etst.com`, Carlos Obregon `Carlos.Obregon@rxcs.net`, Jorge
  `jorge.trigoura@rxcs.net`). So `"share plan with Mario"` now resolves.
- **Tunable defaults** (change if desired): preview-then-send (not immediate); from-dev-mailbox with
  system fallback.
- **emed_etl gap (minor):** `plan-tracking.md` is imported in emed_app + emed_sql but not emed_etl —
  share-plan reaches emed_etl (via org-defaults) but the plan-tracking concepts it references don't.
  Fix later by nesting plan-tracking in org-defaults or adding it to `emed_etl/CLAUDE.md`.
