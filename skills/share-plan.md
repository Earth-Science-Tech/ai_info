# Skill: Share Plan (email a plan to a teammate as PDF + .md)

## Trigger

When the user says **"share plan with &lt;name&gt;"**, **"email my plan to &lt;name&gt;"**, **"send this plan
to &lt;name&gt;"**, **"share plan &lt;slug&gt; with &lt;name&gt;"**, or similar — where `<name>` is a teammate
(e.g. "share plan with Mario", "share plan with Nick").

This lets any developer's Claude instance email the plan they're working on to another developer, so
work-in-progress can be handed off or reviewed. The email carries **two attachments**: a **formatted
PDF** (for human reading) and the **`.md` source** (to hand back to a Claude instance). It complements
[plan-tracking.md](plan-tracking.md): plan-tracking keeps the shared **record** in `ai_info/plans/`;
this skill **pushes** a copy to a specific teammate's inbox.

## What to do

### 1. Resolve the recipient → a real email (NEVER guess)

The team roster is [`team/roster.md`](../team/roster.md) (a markdown table; there is no JSON source —
parse the table). Match `<name>` to a row by full name, first name, GitHub handle, or **nickname/alias**
(the roster's **Nicknames & aliases** section — match case-insensitively).

- **"Nick" → Nicholas Cardell.** "Mario" → Mario Tabraue. "Jorge" → Jorge. "Jose" **or "Daniel"** → Jose
  Daniel Garcia Gonzalez (he goes by his middle name).
- **⚠ Two people named Carlos** — `carcuet` = **Carlos Cueto**, `Obregon1993` = **Carlos Obregon**.
  **"Carlos 1"/"Carlos1" → Cueto; "Carlos 2"/"Carlos2" → Obregon** (deterministic). If the user says just
  "Carlos", **ask which one** — never assume.
- **Read the email cell literally.** If it is a real address (e.g. `nicholas.cardell@rxcs.net`), use it.
  **If it is the placeholder `_(confirm)_` or blank, STOP** — that teammate's email is not on file.
  Tell the user, and offer to add it to `roster.md` if they provide it (then commit that roster edit to
  `ai_info` `main`). **Never derive an email from the name pattern** — the roster warns the pattern has
  exceptions (e.g. Jose is `Jose.Gonzalez@rxcs.net`; Chris Rose is on `etst.com`, not `rxcs.net`).
- **Recipients must be roster teammates.** This skill is for internal plan hand-off only — never email a
  plan to an address that isn't in the roster.

### 2. Resolve which plan to share

In priority order:
1. **Explicit** — the user named a slug/plan/file ("share plan `per-page-permissions` with Mario") →
   `ai_info/plans/<slug>.md`.
2. **Current branch** — if the git branch is `feat/<slug>`, use `ai_info/plans/<slug>.md`.
3. **This session's plan** — the plan actively being worked on in this conversation. If it isn't recorded
   in `ai_info/plans/` yet, **first persist it** via [plan-tracking.md](plan-tracking.md) (create
   `plans/<slug>.md` + index row, commit to `ai_info`), so the shared file matches the shared record.
   Then share that file.
4. **By developer** — if still ambiguous, resolve the current user (`git config user.email` →
   roster handle) and list their plans (`developers:` contains their handle), most-recently-updated first,
   and ask which one.

If no plan file exists and the user just wants to send an ad-hoc plan from the conversation, write it to a
`.md` first (prefer creating a real tracked plan; otherwise a temp file in the scratchpad) and share that.

### 3. Preview and confirm, then send

Show a one-line preview and get a yes before sending (email is outbound and can't be unsent):

```
Share plan "<title>" (plans/<slug>.md, as PDF + .md) → <Full Name> <<email>>, from <your name>. Send? (y/n)
```

If the user's request already said to just send it (e.g. "share plan with Mario, send it" / "no confirm"),
skip the prompt.

### 4. Render the PDF + send (self-contained; do NOT use `email_azure.js`)

The sender is a version-controlled script in this folder: **[`share_plan_send.js`](share_plan_send.js)**.
It reads the plan `.md`, renders it to a formatted **PDF** (`emed_app/server/pdf_html.js` →
`to_base64_pdf`), and emails **both the PDF and the `.md`** via MS Graph — from the dev's own mailbox,
auto-falling back to the system mailbox. PDF is best-effort: on any failure it still sends the `.md`.

Run it **from the `emed_app` directory** (so `.env`, `pdf_html`, and node deps resolve), with `NODE_PATH`
pointing at emed_app's `node_modules`, and inputs passed as **environment variables**. Use the **Bash
tool**:

```bash
cd "<path-to>/emed_app"
NODE_PATH="$PWD/node_modules" \
TO_EMAIL="mario.tabraue@rxcs.net" TO_NAME="Mario Tabraue" \
FROM_EMAIL="$(git config user.email)" FROM_NAME="$(git config user.name)" REPLY_TO="$(git config user.email)" \
PLAN_FILE="../ai_info/plans/<slug>.md" PLAN_TITLE="<plan title>" NOTE="" \
node ../ai_info/skills/share_plan_send.js
```

- `FROM_EMAIL`/`FROM_NAME`/`REPLY_TO` come from the **sending** dev's git identity (as above), so the
  mail is from them and replies reach them.
- `PLAN_FILE` is relative to `emed_app/` (the cwd). `NOTE` is an optional one-line message.
- The script prints a result JSON — **report it to the user**: recipient, the attachment names
  (`<slug>.pdf`, `<slug>.md`), any `pdfNote` (PDF fell back to md-only), and any system-sender fallback.
- **Run the script file, not a big inline `node -e`/heredoc** — piping the ~100-line program over stdin
  proved unreliable.

## Why it's built this way (do not "simplify" these)

- **Self-contained Graph send, NOT `emed_app/server/email_azure.js`.** `email_azure` computes
  `test_mode = is_local_host()` **at module load**, and on any machine with `IS_LOCAL_HOST=1` its `send()`
  **silently redirects the recipient to `DEV_EMAIL`/`nicholas.cardell@rxcs.net`** — so a teammate would
  never receive the plan. It also `require`s `./sql` (a DB side-effect). This script avoids both while
  reusing the same app registration and attachment shape.
- **PDF via `server/pdf_html.js` (`to_base64_pdf`, html-pdf/PhantomJS).** It returns base64 directly (the
  exact shape a Graph `fileAttachment` needs) and is already used in prod. **PDF is best-effort**: if it
  throws, the script still sends the `.md` (the essential artifact) and notes the failure — never let a PDF
  hiccup block the hand-off.
- **Inline markdown→HTML converter (no markdown lib is installed).** `marked`/`markdown-it` aren't deps, so
  a compact converter handles the plan-template subset (frontmatter, headings, lists, tables, code, links,
  quotes) for both the PDF and the inline email body. If a real markdown lib is ever added to `emed_app`,
  swap it in.
- **From the dev's own mailbox, auto-falling back to `noreply@rxcompoundstore.com`.** The shared app
  registration can send as tenant user mailboxes (verified — a self-send went out `from` the dev with no
  fallback); if it ever lacks send-as rights for a dev, the script retries from the system mailbox.
  `replyTo` is always the sending dev.
- **Recipient always from the roster; never guessed.** Wrong emails "drive alert delivery" (roster's own
  warning). A `_(confirm)_` cell means STOP, not improvise.

## Applies to

- All eMed repos, all developer Claude instances (propagated via the nested import in
  `org/rules/org-defaults.md`). The sender script `share_plan_send.js` ships alongside this skill in
  `ai_info/skills/`.
- Requires `emed_app/.env` with the `AZURE_*` creds and `emed_app`'s node deps (`@azure/identity`,
  `@microsoft/microsoft-graph-client`, `html-pdf`) — all present for anyone who runs emed_app locally.
- Related: [plan-tracking.md](plan-tracking.md), [`team/roster.md`](../team/roster.md).
