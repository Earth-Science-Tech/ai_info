# Team Roster — ETST Developers

GitHub org: **`Earth-Science-Tech`**. Use this to map GitHub usernames to real people so
you never misattribute work or grant the wrong person production access. Last updated 2026-07-16.

## Developers

| Full name | GitHub username | Role / notes |
|-----------|-----------------|--------------|
| **Nicholas Cardell** | `nicholas-cardell` | Engineering lead & most senior developer. Production gatekeeper. |
| **Carlos Cueto** | `carcuet` | Senior database engineer. Production gatekeeper (esp. prod DB / emed_sql). |
| **Carlos Obregon** | `Obregon1993` | Developer. **Not** the same person as Carlos Cueto — see gotcha below. |
| **Jose Daniel Garcia Gonzalez** | `etst-josegonzalez` | Developer. |
| **Jorge Trigoura** | `jtrigourarxcs` | Developer. |
| **Mario Tabraue** | `mariotabraue` | Developer (CRM / pricing feature work). |
| **Chris Rose** | `earth-science-dev` | **CTO.** Org owner — set up the GitHub org/subscription. Does not commit code. As an org owner this account *can* bypass branch protection (latent gatekeeper), though unused day-to-day. |

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
