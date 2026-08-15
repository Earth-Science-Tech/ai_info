# Team Roster — ETST Developers

GitHub org: **`Earth-Science-Tech`**. Use this to map GitHub usernames to real people so
you never misattribute work or grant the wrong person production access. Last updated 2026-08-15.

## Developers

| Full name | GitHub username | Email | Title | Notes |
|-----------|-----------------|-------|-------|-------|
| **Nicholas Cardell** | `nicholas-cardell` | nicholas.cardell@rxcs.net | Senior Staff Engineering Manager & Engineering Lead | Org owner. Production gatekeeper. |
| **Chris Rose** | `earth-science-dev` | chris.rose@etst.com | CTO, Earth Science Tech | Org owner — set up the GitHub org/subscription. Does not commit code. As an org owner *can* bypass branch protection (latent gatekeeper), though unused day-to-day. |
| **Mario Tabraue** | `mariotabraue` | mario.tabraue@rxcs.net | COO, Earth Science Tech | Also does CRM / pricing feature work in the repos. |
| **Carlos Cueto** | `carcuet` | carlos.cueto@rxcs.net | Senior Database Engineer | Production gatekeeper (esp. prod DB / emed_sql). `maintain` role on eMed (deploy tags). **Not** the same person as Carlos Obregon — see gotcha below. |
| **Carlos Obregon** | `Obregon1993` | Carlos.Obregon@rxcs.net | Senior SW Engineer | Regular developer, **not** a gatekeeper. **Not** the same person as Carlos Cueto — see gotcha below. |
| **Jose Daniel Garcia Gonzalez** | `etst-josegonzalez` | Jose.Gonzalez@rxcs.net | SW Engineer | **Backup production gatekeeper** (added 2026-07-17) — can merge to prod, cut deploy tags, and run prod DB migrations. Purpose: offload Mario's PRs (not enforceable to Mario-only). `maintain` role on eMed. |
| **Jorge Trigoura** | `jtrigourarxcs` | jorge.trigoura@rxcs.net | Web Developer | |

> **Emails:** the pattern is `firstname.lastname@rxcs.net` — but confirm rather than assume, there are exceptions: **Jose** is `Jose.Gonzalez@rxcs.net` (uses *Gonzalez*, not his middle surname *Garcia*), and **Chris Rose** is on the **`etst.com`** domain (`chris.rose@etst.com`), not `rxcs.net`. All emails above are confirmed as of 2026-08-15; they drive alert/plan delivery (see the `share-plan` skill), so keep them accurate.

**Production gatekeepers** (merge to prod `main`, cut deploy tags, change prod DB): **Nicholas
Cardell**, **Carlos Cueto**, and **Jose Daniel Garcia Gonzalez** (backup). See
[../org/rules/branch-and-database-gates.md](../org/rules/branch-and-database-gates.md).

**GitHub org owners** (can bypass branch protection): **Nicholas Cardell** (`nicholas-cardell`)
and **Chris Rose** (`earth-science-dev`). Everyone else is a regular org member, bound by the
branch/database gates.

## ⚠️ Gotcha: there are two people named "Carlos"

- **Carlos Cueto** = `carcuet` — senior DB engineer, a **production gatekeeper** (can push to
  `main` / prod DB).
- **Carlos Obregon** = `Obregon1993` — a regular developer, **not** a gatekeeper.

When someone says "Carlos" in the context of production, database, or merge approval, it means
**Carlos Cueto (`carcuet`)**. Do not confuse the two, and never grant `Obregon1993`
production access on the assumption that "Carlos" = the gatekeeper. We also disambiguate them verbally
as **Carlos 1** (= Carlos Cueto) and **Carlos 2** (= Carlos Obregon) — see Nicknames & aliases below.

## Nicknames & aliases

Resolve these when a teammate is referred to by a nickname (used by skills like `share-plan` and
`plan-tracking`, and for author attribution). Match case-insensitively; the canonical person +
GitHub handle is what to act on.

| Goes by / alias | Person (canonical) | GitHub |
|-----------------|--------------------|--------|
| Nick | Nicholas Cardell | `nicholas-cardell` |
| Daniel | Jose Daniel Garcia Gonzalez (goes by his middle name) | `etst-josegonzalez` |
| Carlos 1 / Carlos1 | Carlos Cueto | `carcuet` |
| Carlos 2 / Carlos2 | Carlos Obregon | `Obregon1993` |

- **"Carlos" alone is ambiguous.** It defaults to **Carlos Cueto** only in a production/DB/merge
  context (per the gotcha above); anywhere else, **ask which Carlos** or use the Carlos 1 / Carlos 2
  aliases. Never guess.
- Add new aliases here as they come up, rather than hard-coding them into a skill.

## Related

- Who can merge/deploy where: [../org/rules/branch-and-database-gates.md](../org/rules/branch-and-database-gates.md)
