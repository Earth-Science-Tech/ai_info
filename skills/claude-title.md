# Skill: Claude Title

## Trigger

When the user says **"claude title"** (or close variants like "claude, title", "title this chat", "what's this convo about").

## Why This Exists

The user runs multiple VS Code Claude Code chat windows in parallel. Window titles get truncated, and long conversations may drift from their original topic. This skill produces a quick orientation card so the user can identify the chat at a glance.

## What to Do

Output exactly two things, in this order, and nothing else:

### 1. Title

A single line, **5–10 words**, that captures what this conversation is *currently* about. If the topic shifted mid-conversation, prefer the **most recent substantive topic** over the original one — that is what the user is actively working on.

Format:
```
**Title:** <concise descriptive title>
```

### 2. Three-Bullet Summary

Exactly **three bullets**. Each bullet is one short sentence (≤ 20 words). Cover:

- **Bullet 1** — the goal or problem being worked on
- **Bullet 2** — the key decisions, files, or approach taken so far
- **Bullet 3** — current status / what's next / any blocker

Format:
```
**Summary:**
- <bullet 1>
- <bullet 2>
- <bullet 3>
```

## Rules

- **No preamble.** Don't say "Here's your title…" — just emit the Title and Summary.
- **No trailing follow-up.** Don't ask "Want me to do X next?" — this skill is a read-out, not a continuation.
- **Be specific.** Name the actual feature, file, table, or component (e.g., `route_public.js`, `moct_visit`, "Magic Link MFA"). Generic titles like "API work" or "Bug fixing" are useless.
- **Reflect reality.** Base the summary only on what actually happened in the conversation — don't invent context from project memory that wasn't discussed.
- **No emojis** unless the user has asked for them in this conversation.

## Good Example

```
**Title:** Add invoice PDF export to billing route

**Summary:**
- Goal: let admins download invoices as PDFs from the billing dashboard.
- Added a new GET handler in route_billing.js using pdfkit; reused emed_invoice_line_item view.
- Working end-to-end locally; need to test against staging before "push prod".
```

## Bad Example (don't do this)

```
Here's a title for our great conversation! 🎉

**Title:** Working on stuff

**Summary:**
- We talked about some things.
- Made some changes to some files.
- More work to do.

Let me know if you'd like me to continue!
```

## Applies To

- All projects, all Claude Code instances. Imported by every project's `CLAUDE.md`.
