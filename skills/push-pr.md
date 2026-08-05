# Skill: Push PR (review → fix → merge → ship named PRs to production)

## Trigger

When the user says **"push pr <numbers>"** — e.g. **"push pr 223 253 323"**, **"push pr 231 emed_sql#56"**,
**"push pr 240 as 1.1.0"**. The word after `push` is `pr` (mirrors **"push prod"**).

This skill takes a **specific list of open PRs**, reviews them thoroughly (security- and
irreversibility-weighted), fixes what it safely can, merges the good ones to `main`, applies their SQL
migrations to production in dependency order, updates the in-app Change Log, and cuts the production tag —
**as automatically as possible**, so the operator isn't approving PRs one at a time.

### How this differs from the neighbouring skills

| Phrase | What it does |
|--------|--------------|
| **"push pr N …"** (this skill) | Review + fix + **merge these specific PRs** to `main`, apply their migrations, then release to prod. Write path. |
| **"push prod"** ([push-prod.md](push-prod.md)) | Release whatever is **already on `main`** to prod (no PR handling). This skill *reuses* push-prod's release tail. |
| **"review pr"** ([review-pr.md](review-pr.md)) | **Read-only** cross-repo review. Never merges. This skill uses its checklist as a base. |

### Argument syntax

- **Bare number** (`223`) → a PR in the **eMed** app repo (`Earth-Science-Tech/eMed` = `emed_app`). This is the default because that's where COO/feature PRs land.
- **`repo#num`** to target another repo: `emed_sql#56` (or `sql#56`), `emed_etl#12` (or `etl#12`).
- **`as x.x.x`** or a trailing bare **`x.x.x`** (e.g. `push pr 240 as 1.1.0`) → cut this **explicit** version. Otherwise the version is `git describe --tags --abbrev=0` with the **patch** incremented.

Repo → GitHub slug map: `emed_app`→`Earth-Science-Tech/eMed`, `emed_sql`→`Earth-Science-Tech/emed_sql`,
`emed_etl`→`Earth-Science-Tech/emed_etl`. Always pass `--repo <slug>` to `gh` so it works from any directory.

---

## Automation posture (the operator's standing choices)

This skill is deliberately **hands-off**. Defaults, set by the operator when the skill was created:

1. **Fully automatic through tag + deploy.** One invocation runs review → auto-fix → merge → migrations →
   changelog → tag → deploy, with **no per-PR approval**. The operator reads the final report after it ships.
2. **Pause and ask ONLY in these two cases** (batch all asks into as few `AskUserQuestion` prompts as possible):
   - **(a) An irreversible / destructive production migration** — see the destructive-DDL gate in Phase 4.
   - **(b) A real security or money/PHI-integrity finding whose *correct fix is genuinely unclear.*** This is
     the "senior dev decides" case: lower-level authors (e.g. Mario) often can't produce the right fix, so the
     reviewer owns it — but only escalate when *you* are not confident what the right fix is.
3. **Everything else is handled without asking.** A fixable finding gets **fixed** (committed to the PR's own
   branch so it rides in the merge). A PR that won't merge cleanly, has real CI breakage, or carries an
   unresolved HIGH risk that can't be auto-fixed is **held out of the batch** — the *other* PRs still ship, and
   the held PR is reported at the end. Prefer **hold-one-and-continue** over aborting the whole run.
4. **Abort the whole run only** if an unresolved HIGH-severity / irreversible risk can't be isolated to a
   single held PR (e.g. it lives in shared release infrastructure).

> Guiding principle the operator gave: *most bugs are recoverable, so don't over-gate them — but weight review
> hard toward the things that can't be undone.* Ship confidently on reversible changes; slow down and verify
> (or escalate) on the irreversible ones.

---

## Step -1: Authority gate (run FIRST — hard stop)

Only a **production gatekeeper** may complete this skill (merge to `main`, apply prod migrations, cut deploy
tags). Per [`org/rules/branch-and-database-gates.md`](../org/rules/branch-and-database-gates.md) and
[`sql-safety.md`](../org/rules/sql-safety.md), the gatekeepers are **Nicholas Cardell** (`nicholas-cardell`),
**Carlos Cueto** (`carcuet`), and **Jose Daniel Garcia Gonzalez** (`etst-josegonzalez`).

```bash
gh api user --jq .login          # operating GitHub identity
git -C emed_app config user.email
```

If the login is **not** one of the three gatekeepers, **STOP**. Do not merge or push. Fall back to the
read-only **"review pr"** skill, produce the review, and tell the user to hand the merge/deploy to a
gatekeeper. Urgency never overrides this.

If it *is* a gatekeeper, continue — the rest of the skill assumes production authority.

---

## The irreversibility lens (what to weight in review)

Classify every finding on **two axes: severity × reversibility.** A reversible bug (wrong label, a
soft-deletable row, an additive column, a read-only page) is low-priority even if real — it can be fixed in the
next patch. Concentrate scrutiny, verification effort, and any escalation on the changes that **can't be undone
once they reach production**. In this codebase those are:

- **Money movement** — charges, refunds, account credit, invoice-balance math, batch charging
  (`payments_*`, `invoice.js`, `route_payments*`). A wrong charge/refund/credit moves real customer money.
  History here: the account-credit double-mint (#164). Verify the ledger math.
- **Pharmacy / Liberty writes** — `emed.sign_prescriptions`, submit/refill/patient-create, pharmacy routing,
  the Pre-Clarification gate, the Liberty outbox (`liberty.js`, `emed.js`, `preclar_*`, `*_outbox*`).
  **An Rx sent to a pharmacy cannot be unsent.** Also watch the "timeout looks like success" trap — mutations
  must decide failure from the callback `error`, never from an empty `data`.
- **Destructive production DB migrations** — `DROP`/`ALTER … DROP`/`TRUNCATE`/`DELETE`/`NOT NULL`-on-existing.
  Irreversible data loss on `liberty_link_stage`. (Handled by the Phase 4 gate.)
- **Auth / MFA / session / permission grants** — lockout, privilege escalation, and clinic-scope changes that
  can **leak PHI across clinics** (`auth.js`, `mfa.js`, `permissions.js`, `permission_catalog.js`, roles).
- **Unauthenticated surface** — `route_public.js`, webhook receivers, the public API, capture links. Exposure
  or abuse of anything reachable without a session.
- **PHI exposure** — patient data in logs, API responses, PDFs, or crossing a clinic boundary.
- **Data-destroying app operations** — hard `DELETE` where soft-delete (`is_invalid`) is the rule; writes that
  `NULL` out a populated field without a `COALESCE` anti-wipe fallback.
- **Outbound blasts** — SMS/email campaign sends, unsubscribe/ASM compliance (past near-miss: ASM opt-outs).

Reversible-and-lower-priority (ship confidently, note but don't gate): UI/EJS tweaks, additive tables/columns
with grants, reporting/read-only pages, soft-deletable CRUD, copy changes.

---

## Phase 0 — Resolve the PRs and preflight (autonomous)

### 0.1 Parse the request into a work list

Produce a list of `{repo, number}` plus an optional explicit version. Bare numbers = `emed_app`.

### 0.2 Fetch each PR

```bash
gh pr view <n> --repo <slug> --json \
  number,title,author,headRefName,baseRefName,state,isDraft,mergeable,mergeStateStatus,\
labels,files,body,url,additions,deletions,changedFiles,statusCheckRollup,commits
gh pr diff <n> --repo <slug>
```

Immediately **hold and report** (do not fail the batch) any PR that is: already merged/closed, a draft, or —
for an `emed_app` PR — **based on `dev` instead of `main`** (a `dev`-based PR is not a shippable promotion;
per the release model, shippable features branch off `main`). See [branch-and-database-gates.md](../org/rules/branch-and-database-gates.md) → "Release model" and [open-pr.md](open-pr.md).

### 0.3 Repo/tree preflight

- `emed_app` and `emed_sql` are on `main` and up to date (`git -C <repo> fetch origin && git -C <repo> status -sb`).
- The **tracked** working tree of any repo you'll switch branches in must be clean (untracked strays are fine).
  If there are uncommitted **tracked** modifications, `git stash` them first and restore after — never merge or
  branch-switch over dirty tracked state (this is how unstaged edits get destroyed).
- Confirm `gh` auth (Step -1 already did) and that `emed_sql/.env` has prod+dev admin creds (`apply_migration.py` needs them).

### 0.4 Discover each PR's migration dependency

For each `emed_app` PR, read the **"Schema changes"** section of its body (the repo's PR template): it names
the `emed_sql/migrations/…/<file>.sql` migration(s) and the emed_sql PR/commit that carries them. Record, per
shipping PR: the migration file path(s), which emed_sql PR/commit they live in, and where they've been applied
(dev only vs dev+prod). If the body says "no schema change," trust but verify against the diff (a new
table/column reference in the code with no declared migration is a **finding**, not a pass — see sql-safety
"Cross-repo" rule). The migration must be in prod **before or with** the code going live.

---

## Phase 1 — Deep review (autonomous; fan out for scale)

Review each PR against the **[review-pr.md](review-pr.md) checklist** (security, SQL safety, naming, code
quality, docs) **plus the irreversibility lens above**, which takes precedence when ranking.

**Orchestration.** When there is more than one PR, or any single diff is large, run the review as a
**Workflow** rather than inline — it is faster and more thorough, and this environment is set up for it:

- **Fan out** one reviewer per PR (and, for large PRs, per dimension: money/billing · pharmacy-writes ·
  auth/PHI · unauth-surface · migrations · general-quality). Each returns structured findings
  `{pr, file, line, category, severity, reversibility, summary, proposed_fix, fix_confidence}`.
- **Adversarially verify** every finding whose `reversibility = irreversible` OR `severity = HIGH`: spawn an
  independent skeptic prompted to *refute* it (is it actually reachable? actually irreversible? actually
  wrong?). Drop findings the skeptic refutes. This keeps plausible-but-wrong findings from blocking a merge.
- **Synthesize** a per-PR verdict: `SHIP` / `FIX-THEN-SHIP` / `HOLD` / `ESCALATE`.

For a single small PR, an inline review is fine — but still apply the two-axis ranking and verify the
irreversible/HIGH findings before acting on them.

Also pull CI: `gh pr checks <n> --repo <slug>`. A failure that implies **real breakage** → `HOLD` that PR
(not a pause; the operator did not opt to be asked about CI). A clearly **flaky/unrelated** failure → note it
and proceed (gatekeeper judgment; owners can bypass required checks).

---

## Phase 2 — Auto-fix or escalate (semi-autonomous)

For each **confirmed** finding, decide by `fix_confidence`:

### Fix it yourself (the default) when the correct fix is clear

1. Check out the PR branch **in its repo** (tree must be clean per 0.3):
   ```bash
   gh pr checkout <n> --repo <slug>
   ```
2. Make the fix. Match surrounding style. Add/adjust a test when the finding is behavioural.
3. Commit with a conventional message crediting yourself as the fixer:
   ```bash
   git commit -m "fix(<scope>): <what and why> (review of #<n>)"
   ```
4. Push to the **same** PR branch so the fix rides into the merge (never open a competing branch):
   ```bash
   git push origin <headRefName>
   ```
5. Re-verify the fix (re-run the relevant reviewer / the test). Never push a fix to a branch **after** its PR
   has merged — fixes go on **before** Phase 3.

The reviewer owns these fixes because the PR author frequently can't produce them. Keep each fix focused on the
finding; don't fold in unrelated cleanups.

### Escalate (ask the operator) — only the two standing cases

Accumulate and present together via **one** `AskUserQuestion` when:

- **(b) fix is unclear** — a genuine security or money/PHI-integrity finding where you are **not confident**
  what the correct fix is. Present: the finding, why it's irreversible/serious, and 2–3 concrete fix options
  (recommended first). The operator's answer either supplies the fix (you apply it) or says "hold this PR."
- **(a) destructive migration** — surfaced in Phase 4, asked there.

If an escalation isn't resolved (or the operator says hold), **HOLD that PR** and continue with the rest.

Anything that is neither cleanly fixable nor one of the two ask-cases, and is genuinely risky → **HOLD** and
report; do not silently ship it.

---

## Phase 3 — Merge the approved PRs to `main` (autonomous)

Merge order: **emed_sql migration PRs first** (so the migration files land on `emed_sql` `main`), then
`emed_app` PRs, then any `emed_etl` PRs. Respect any explicit **"Depends on #X"** in a body.

Use a **merge commit, NOT a squash** — the feature's commits are already on `dev` via the preview merge, so a
merge commit keeps `main` and `dev` sharing commit identity and the `sync-main-to-dev` back-merge stays a clean
no-op (a squash diverges and conflicts). Delete the merged branch.

```bash
gh pr merge <n> --repo <slug> --merge --delete-branch
```

If `gh` reports the PR is **not mergeable** (conflicts), **HOLD** it (per posture #3) and continue — do not
force anything. After merging, bring the merged code local:

```bash
git -C emed_app  checkout main && git -C emed_app  pull origin main
git -C emed_sql  checkout main && git -C emed_sql  pull origin main   # if any emed_sql PR merged
```

**emed_etl note:** an `emed_etl` PR still needs review+merge here, but it deploys via Prefect on the next
scheduled run — it does **not** ride the eMed tag. Merge it, then exclude it from the tag/deploy phases and
say so in the report.

---

## Phase 4 — Apply the migrations to prod, in order (autonomous; destructive gate)

This mirrors [push-prod.md](push-prod.md) Phase 2 Step 0, extended to be cross-repo-PR aware.

### 4.1 Assemble & guard the pending set

The migration files declared by the shipping PRs must now exist in `emed_sql/migrations/pending/` (they moved
`wip/ → pending/` when the promotion PR opened, or were committed to `emed_sql` `main` directly). Pull confirmed
in Phase 3.

**Guard against strays** (eMed's recurring landmine): `pending/` must hold **only** the migrations for the PRs
in *this* batch. Compare `ls emed_sql/migrations/pending/*.sql` against the files you recorded in 0.4. Any
`pending/` file **not** part of this ship → move it back to `wip/` (`git mv`) before applying, or it will ride
along. Never blind-glob `pending/*.sql`.

### 4.2 Drift check (authoritative, live-DB)

```bash
cd emed_sql
python python/check_migration_drift.py --json
```

If it reports **UNCOVERED** drift (dev-ahead schema no `pending/`/`wip/` migration covers): **HARD STOP, do not
hand-reverse-engineer.** Recover deterministically — `python python/check_migration_drift.py --scaffold`,
review each draft, apply to dev (`apply_migration.py … `), commit to emed_sql, then resume. (Drift classified
`wip`-parked or prod-ahead is expected, not a stop.)

### 4.3 Destructive-DDL gate (ALWAYS pause — standing case (a))

Read every migration you're about to apply. If any contains **`DROP TABLE` / `DROP COLUMN` / `ALTER … DROP` /
`TRUNCATE` / `DELETE FROM` / `ALTER COLUMN … NOT NULL` on an existing populated column** — or anything else not
safely reversible on `liberty_link_stage` — **STOP and `AskUserQuestion`**, quoting the exact statements and the
blast radius, even in fully-auto mode. Only proceed on explicit confirmation; otherwise HOLD that migration's PR
out of the batch (and, if the code depends on it, hold that code PR too).

### 4.4 Apply in dependency order

Apply **only the confirmed files**, in order (explicit "depends on" first; otherwise ascending by the
`YYYY-MM-DD` filename date). Each applies to **dev first, then prod**, regenerates both snapshots, and
auto-moves `pending/ → applied/`:

```bash
cd emed_sql
python python/apply_migration.py migrations/pending/<file>.sql --db both --confirm   # repeat per file, in order
python python/check_migration_drift.py     # re-verify: no uncovered drift
```

If any migration fails, **stop the migration loop** — do not continue and do not tag. Report which file failed.
(Applying migrations touches only the DB via the emed_sql admin creds; it makes **no** pharmacy/Liberty calls.)

### 4.5 Commit emed_sql

```bash
cd emed_sql
git add migrations/ prod/ dev/
git commit -m "chore(sql): apply <n> migration(s) for PRs <list> to prod and dev"
git push origin main
```

---

## Phase 5 — Change Log, tag, deploy (autonomous — reuses push-prod's tail)

Run from **`emed_app/`**. `main` is now clean and carries the merged PRs.

### 5.1 Determine the version

Explicit `as x.x.x` if given; else `git describe --tags --abbrev=0` with the patch bumped. **No `v` prefix** —
`1.0.4` triggers the deploy, `v1.0.4` does not.

### 5.2 Change Log entry (before the release commit — see [push-prod.md](push-prod.md) Step 0.5)

```bash
cd emed_app
node scripts/changelog.js scaffold <new-version>   # prepends a DRAFT to data/changelog.json
```

Then **curate** the drafted entry in `data/changelog.json`: rewrite each bullet into plain, user-facing
language; set a one-line `summary`; **scrub PHI/secrets** (patient names/DOBs, patient↔drug links, card/payment
IDs, keys/connection strings, internal specifics). **Keep the author names** — the scaffold resolves git
identities to real names via `team/roster.md` (never disambiguate a "Carlos" on first name alone). This is
where COO/author credit is preserved. Stage the file (`git add data/changelog.json`) — it ships in the tag.

### 5.3 Release commit + tag + deploy

```bash
cd emed_app
git add data/changelog.json           # + any review-fix files already merged are on main; stage only intended files, never `git add -A` blindly
git commit -m "chore(release): <new-version> — <one-line summary of the PRs shipped>"
git push origin main
git tag -a <new-version> -m "<release summary: PRs #.. #.. — headline features>"
git push origin <new-version>          # pushing the tag to origin triggers the Azure deploy
```

Pushing a branch to `main` does **not** deploy; only the `x.x.x` **tag** does. Never `git push --force` to `main`.

### 5.4 Post-deploy issue bookkeeping (non-fatal)

```bash
cd emed_app
node scripts/close_resolved_issues.js <prev-tag>..HEAD    # closes emed_issue rows/GitHub issues referenced by `fixes emed-issue#N`
```

If it errors, surface it but don't treat the release as failed.

---

## Phase 6 — Report

Output one consolidated report:

```
## push pr — <new-version>

Shipped (merged + deployed):
- eMed #223 "<title>" — <SHIP | fixed N findings before merge> · authors: <…>
- eMed #253 "<title>" — <…>
Held (NOT shipped, with reason):
- eMed #323 "<title>" — HELD: merge conflict with main / failing CI / unresolved HIGH risk <…>
Migrations applied to prod (in order): <file1>, <file2>  (or "none")
Escalated to you: <what was asked and the decision>  (or "none")
Version tagged: <new-version> → Azure deploy triggered (gh run watch to follow)
Issues closed: <#…>  (or "none")
```

Be honest: name every held PR and why, every escalation, and every migration. If CI on the deploy is still
running, say so — don't claim "live" before it is.

---

## Critical rules

- **Authority gate is absolute** — non-gatekeepers get a read-only review and a hand-off, never a merge/deploy.
- **Weight review by reversibility.** Fix reversible bugs and move on; verify/escalate the irreversible ones.
- **Only two things pause the run:** a destructive prod migration, or a security/integrity fix you're unsure of.
  Everything else is fixed or held — never a per-PR "is this ok?" prompt.
- **Hold-one, ship-the-rest** beats aborting. A held PR must never block the others.
- **Fixes go on the PR branch before merge**, credited to the reviewer. Never push to a branch after it merges.
- **Merge commits, not squashes**, into `main` (keeps `main`↔`dev` in sync).
- **Only the declared migrations ship.** Guard `pending/` against strays; never blind-glob.
- **`--db both --confirm`**, dev-first, in dependency order; a failed migration stops the run.
- **Tag `x.x.x`, no `v`**; the tag push (to `origin`) is what deploys.
- **Never `git add -A` blindly** — the working tree has untracked strays; stage only intended files.
- Merging and deploying make **no** pharmacy/Liberty calls — but the *code* being shipped might, which is
  exactly why the pharmacy-write lens matters at review time.

## Applies to

- **emed_app** (`Earth-Science-Tech/eMed`) — the primary target; feature/COO PRs and the tag-based deploy.
- **emed_sql** (`Earth-Science-Tech/emed_sql`) — migration PRs and the prod-DB apply step.
- **emed_etl** (`Earth-Science-Tech/emed_etl`) — reviewed + merged here, but deploys via Prefect, not the tag.
- Reuses: [review-pr.md](review-pr.md), [push-prod.md](push-prod.md), [open-pr.md](open-pr.md),
  [create-table.md](create-table.md), [`org/rules/sql-safety.md`](../org/rules/sql-safety.md),
  [`org/rules/branch-and-database-gates.md`](../org/rules/branch-and-database-gates.md).
