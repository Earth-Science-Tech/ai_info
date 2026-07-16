# Team Roster — ETST Developers

GitHub org: **`Earth-Science-Tech`**. Use this to map GitHub usernames to real people so
you never misattribute work or grant the wrong person production access. Last updated 2026-07-16.

## Developers

| Full name | GitHub username | Title | Notes |
|-----------|-----------------|-------|-------|
| **Nicholas Cardell** | `nicholas-cardell` | Senior Staff Engineering Manager & Engineering Lead | Org owner. Production gatekeeper. |
| **Chris Rose** | `earth-science-dev` | CTO, Earth Science Tech | Org owner — set up the GitHub org/subscription. Does not commit code. As an org owner *can* bypass branch protection (latent gatekeeper), though unused day-to-day. |
| **Mario Tabraue** | `mariotabraue` | COO, Earth Science Tech | Also does CRM / pricing feature work in the repos. |
| **Carlos Cueto** | `carcuet` | Senior Database Engineer | Production gatekeeper (esp. prod DB / emed_sql). **Not** the same person as Carlos Obregon — see gotcha below. |
| **Carlos Obregon** | `Obregon1993` | Senior SW Engineer | **Not** the same person as Carlos Cueto — see gotcha below. |
| **Jose Daniel Garcia Gonzalez** | `etst-josegonzalez` | SW Engineer | |
| **Jorge Trigoura** | `jtrigourarxcs` | Web Developer | |

**GitHub org owners** (can bypass branch protection): **Nicholas Cardell** (`nicholas-cardell`)
and **Chris Rose** (`earth-science-dev`). Everyone else is a regular org member, bound by the
branch/database gates.

## ⚠️ Gotcha: there are two people named "Carlos"

- **Carlos Cueto** = `carcuet` — senior DB engineer, a **production gatekeeper** (can push to
  `main` / prod DB).
- **Carlos Obregon** = `Obregon1993` — a regular developer, **not** a gatekeeper.

When someone says "Carlos" in the context of production, database, or merge approval, it means
**Carlos Cueto (`carcuet`)**. Do not confuse the two, and never grant `Obregon1993`
production access on the assumption that "Carlos" = the gatekeeper.

## Related

- Who can merge/deploy where: [../org/rules/branch-and-database-gates.md](../org/rules/branch-and-database-gates.md)
