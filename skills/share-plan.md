# Skill: Share Plan (email a plan .md to a teammate)

## Trigger

When the user says **"share plan with &lt;name&gt;"**, **"email my plan to &lt;name&gt;"**, **"send this plan
to &lt;name&gt;"**, **"share plan &lt;slug&gt; with &lt;name&gt;"**, or similar — where `<name>` is a teammate
(e.g. "share plan with Mario", "share plan with Nick").

This lets any developer's Claude instance email the plan they're working on to another developer, so
work-in-progress can be handed off or reviewed. It complements [plan-tracking.md](plan-tracking.md):
plan-tracking keeps the shared **record** in `ai_info/plans/`; this skill **pushes** a copy to a
specific teammate's inbox.

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
  exceptions (e.g. Jose is `Jose.Gonzalez@rxcs.net`, not `jose.garcia@...`).
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
`.md` first (prefer creating a real tracked plan; otherwise a temp file in the scratchpad) and attach that.

### 3. Preview and confirm, then send

Show a one-line preview and get a yes before sending (email is outbound and can't be unsent):

```
Share plan "<title>" (plans/<slug>.md) → <Full Name> <<email>>, from <your name>. Send? (y/n)
```

If the user's request already said to just send it (e.g. "share plan with Mario, send it" / "no confirm"),
skip the prompt.

### 4. Send via Microsoft Graph (self-contained — do NOT use `email_azure.js`)

Send from the **emed_app** directory so the shared Azure app-registration creds
(`AZURE_TENANT_ID` / `AZURE_CLIENT_ID` / `AZURE_CLIENT_SECRET`, in `emed_app/.env`) and node deps
resolve. Pass all dynamic values as **environment variables** (avoids quoting/escaping bugs), and run the
script below via the **Bash tool**:

```bash
cd "<path-to>/emed_app"
TO_EMAIL="mario.tabraue@rxcs.net" TO_NAME="Mario Tabraue" \
FROM_EMAIL="$(git config user.email)" FROM_NAME="$(git config user.name)" REPLY_TO="$(git config user.email)" \
PLAN_FILE="../ai_info/plans/<slug>.md" PLAN_TITLE="<plan title>" NOTE="" \
node - <<'NODE'
require('dotenv').config();               // loads emed_app/.env for AZURE_* creds
require('isomorphic-fetch');
const fs = require('fs');
const { ClientSecretCredential } = require('@azure/identity');
const { Client } = require('@microsoft/microsoft-graph-client');
(async () => {
  const e = process.env;
  if (!e.AZURE_TENANT_ID || !e.AZURE_CLIENT_ID || !e.AZURE_CLIENT_SECRET) {
    console.error('MISSING_AZURE_CREDS: set AZURE_TENANT_ID/CLIENT_ID/CLIENT_SECRET in emed_app/.env'); process.exit(2); }
  if (!e.TO_EMAIL || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e.TO_EMAIL)) { console.error('BAD_RECIPIENT: '+e.TO_EMAIL); process.exit(2); }
  const md = fs.readFileSync(e.PLAN_FILE, 'utf8');
  const fname = e.PLAN_FILE.split(/[\\/]/).pop();
  const b64 = Buffer.from(md, 'utf8').toString('base64');
  const esc = x => String(x == null ? '' : x).replace(/[&<>]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;'}[c]));
  const html = `<div style="font-family:Arial,sans-serif;font-size:14px;color:#222">
    <p><strong>${esc(e.FROM_NAME || 'A teammate')}</strong> shared an eMed plan with you via Claude Code.</p>
    ${e.NOTE ? `<p style="white-space:pre-wrap">${esc(e.NOTE)}</p>` : ''}
    <p><strong>Plan:</strong> ${esc(e.PLAN_TITLE || fname)} &nbsp;(also attached as <code>${esc(fname)}</code>)</p>
    <hr>
    <pre style="white-space:pre-wrap;font-family:Consolas,monospace;font-size:12px;background:#f6f6f6;padding:12px;border-radius:6px">${esc(md)}</pre>
    <p style="color:#888;font-size:12px">Sent by the eMed &quot;share plan&quot; skill. Reply goes to ${esc(e.REPLY_TO || e.FROM_NAME || 'the sender')}.</p></div>`;
  const cred = new ClientSecretCredential(e.AZURE_TENANT_ID, e.AZURE_CLIENT_ID, e.AZURE_CLIENT_SECRET);
  const client = Client.initWithMiddleware({ authProvider: { getAccessToken: async () =>
    (await cred.getToken('https://graph.microsoft.com/.default')).token } });
  const msg = (sender) => ({ message: {
    subject: `[eMed Plan] ${e.PLAN_TITLE || fname} — shared by ${e.FROM_NAME || 'a teammate'}`,
    body: { contentType: 'HTML', content: html },
    toRecipients: [{ emailAddress: { address: e.TO_EMAIL, name: e.TO_NAME || undefined } }],
    from: { emailAddress: { address: sender } },
    replyTo: e.REPLY_TO ? [{ emailAddress: { address: e.REPLY_TO, name: e.FROM_NAME || undefined } }] : undefined,
    attachments: [{ '@odata.type':'#microsoft.graph.fileAttachment', name: fname, contentType:'text/markdown', contentBytes: b64 }]
  }, saveToSentItems: 'true' });
  const SYSTEM = 'noreply@rxcompoundstore.com';
  const primary = e.FROM_EMAIL || SYSTEM;   // send from the dev's own mailbox when the tenant allows it
  try {
    await client.api(`/users/${primary}/sendMail`).post(msg(primary));
    console.log(JSON.stringify({ success:true, from: primary, to: e.TO_EMAIL }));
  } catch (err) {
    const denied = err.statusCode === 403 || /access|denied|ErrorAccessDenied/i.test(err.message || '');
    if (denied && primary !== SYSTEM) {           // no send-as rights → fall back to the proven system mailbox
      try { await client.api(`/users/${SYSTEM}/sendMail`).post(msg(SYSTEM));
        console.log(JSON.stringify({ success:true, from: SYSTEM, to: e.TO_EMAIL, note:'fell back to system sender (no send-as for '+primary+')' })); }
      catch (err2) { console.error('SEND_FAILED_FALLBACK: '+(err2.message||err2)); process.exit(1); }
    } else { console.error('SEND_FAILED: '+(err.message||err)); process.exit(1); }
  }
})();
NODE
```

Report the result JSON to the user (who it went to, and whether it fell back to the system sender).

## Why it's built this way (do not "simplify" these)

- **Self-contained Graph send, NOT `emed_app/server/email_azure.js`.** `email_azure` computes
  `test_mode = is_local_host()` **at module load**, and on any machine with `IS_LOCAL_HOST=1` its `send()`
  **silently redirects the recipient to `DEV_EMAIL`/`nicholas.cardell@rxcs.net`** — so a teammate would
  never receive the plan. It also `require`s `./sql` (a DB connection side-effect). This inline sender
  avoids both while reusing the same app registration and attachment shape.
- **From the dev's own mailbox, auto-falling back to `noreply@rxcompoundstore.com`.** The shared app
  registration can send as tenant mailboxes; if it lacks send-as rights for a specific dev, the script
  retries from the proven system mailbox. `replyTo` is always the sending dev, so replies reach them
  regardless of which mailbox sent it.
- **Recipient always from the roster; never guessed.** Wrong emails "drive alert delivery" (roster's own
  warning). A `_(confirm)_` cell means STOP, not improvise.

## Applies to

- All eMed repos, all developer Claude instances (propagated via the nested import in
  `org/rules/org-defaults.md`).
- Requires `emed_app/.env` with the `AZURE_*` creds (present for anyone who runs emed_app locally) and
  `emed_app`'s node deps installed.
- Related: [plan-tracking.md](plan-tracking.md), [`team/roster.md`](../team/roster.md).
