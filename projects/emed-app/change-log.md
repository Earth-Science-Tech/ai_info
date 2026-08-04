# eMed Change Log (in-app production release history)

An Admin-only page at **`/admin/change-log`** that lists every production version with its **date,
version, who pushed it, curated bullet points** (features / enhancements / bug fixes / removed), and
the **developers who worked on each feature**. Answers "what shipped in the version that just went
live, and who did it?" without reading git. Sensitive detail is scrubbed by construction.

## Where the data lives

- **`emed_app/data/changelog.json`** — a git-tracked JSON array, **newest first**. One object per
  production version. It is **NOT** under `public/` (that's served statically with no auth), so it's
  read server-side and only reachable behind the Admin gate.
- Read in `app.js` (`GET /admin/change-log`, `auth.login` + `auth.perm('View_Menu_Admin')`) and passed
  to the view via `html_data(req, { releases })`. A missing/bad file renders an empty state, never 500.

Entry shape:
```json
{ "version": "1.0.176", "date": "2026-08-03", "pushed_by": "Nicholas Cardell",
  "summary": "one-line headline", "authors": ["Full Name", ...],
  "changes": [ { "type": "feature|enhancement|bugfix|removed|other", "text": "...", "authors": ["Full Name"] } ] }
```
The version-level `authors` is the union of contributors (a "Contributors" line on the card); per-`change`
`authors` credit the specific feature. Values are HTML-escaped in the view (`<%= %>`).

## How entries are produced

`emed_app/scripts/changelog.js` (git-only — no DB, no `.env`, never blocks a deploy):

- **`scaffold <new-version>`** — run during **push prod, before the release commit** (see
  `skills/push-prod.md` → Step 0.5). Prepends a DRAFT entry: fills version/date/`pushed_by`, and drafts
  `changes[]` from `<last-tag>..HEAD` commit subjects grouped by conventional-commit type, each bullet
  pre-filled with its commit author(s). Claude then rewrites the bullets into plain, user-facing
  language, sets `summary`, and **scrubs PHI/secrets** — keeping the author names. Committed with the
  release, so it ships inside the tag. Idempotent (re-running the same version replaces the top entry).
- **`backfill [--force]`** — one-time seed of prior releases from annotated tag messages (subject +
  paragraph bullets) with version-level authors from each tag's commit range. Best-effort: older
  entries are as terse as their tag messages. Already run; not re-run per release.

## Author resolution (git → real names)

Git identities vary (real names, but squash-merges show a GitHub handle like `mariotabraue`). The script
reads **`ai_info/team/roster.md`** and maps GitHub handle → full name (also matches an exact full name,
and a handle pulled from a `…@users.noreply.github.com` email). Unmatched authors fall back to their raw
git name — **a contributor is never dropped**. **Never disambiguate on first name alone** — the roster
documents two people named Carlos (`carcuet` = Carlos Cueto vs `Obregon1993` = Carlos Obregon). Bot
co-authors (Claude/Anthropic/`[bot]`) are filtered. If ai_info isn't a sibling, it degrades to raw names.

## Access & PHI

- Reuses **`View_Menu_Admin`** (Admin only; SuperUser is excluded). No new permission flag, so no
  re-login/perm-cache gotcha.
- Curated content only: never patient names/DOBs, patient↔drug links, SSNs, card/payment identifiers,
  secrets/keys, or internal specifics. Developer names are the one identifier intentionally kept.

## Files

- Page route: `emed_app/app.js` (`GET /admin/change-log`).
- View: `emed_app/views/admin/change-log.ejs` (timeline of release cards, client-side search).
- Sidebar link: `emed_app/views/partials/sidebar.ejs` (Admin block).
- Generator: `emed_app/scripts/changelog.js`. Data: `emed_app/data/changelog.json`.
- Release step: `skills/push-prod.md` → "Step 0.5 — Update the in-app Change Log".
