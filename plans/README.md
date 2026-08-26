# eMed Plans & Features — Index

The team-shared record of every feature/project and **where it is in the pipeline**. Any engineer's
Claude reads this to see what's in flight and to **take over** work. One file per feature in this folder
(`<slug>.md`, named for its `feat/<slug>` branch). Add/maintain a row here whenever you create a plan or
change its status. Full rules: [`skills/plan-tracking.md`](../skills/plan-tracking.md).

**Status legend:** `Not Started` → `In-Progress` → `Completed in Dev` → `Completed in Production`
(plus `On Hold`, `Abandoned` when needed).

| Status | Plan | Project | Branch | Developers | Updated |
|--------|------|---------|--------|------------|---------|
| In-Progress | [Prescriber & Clinic Portals + Rep Tools — Program (Facilities-Hub)](portal-foundations.md) | multi | `feat/portal-foundations` + `emed_sql feat/portal-foundations-schema` | Mario Tabraue | 2026-08-26 |
| Completed in Production | [Sync Pharmacy Facilities](pharmacy-facility-sync.md) | emed_app | `feat/pharmacy-facility-sync` (1.0.224) | Nicholas Cardell | 2026-08-22 |
| Completed in Production | [Facility Scope Unification (FacilityGroups)](facility-scope-groups.md) | multi | `feat/patient-portal-secure-messaging` (1.0.205–1.0.207, 1.0.211) | Nicholas Cardell | 2026-08-19 |
| Completed in Production | [Patient Portal + Secure Messaging (Phase 1, ships DARK)](patient-portal-secure-messaging.md) | multi | `feat/patient-portal-secure-messaging` (1.0.205) | Nicholas Cardell | 2026-08-19 |
| Completed in Production | [Sync Everything skill (pull all repos + reload)](sync-everything-skill.md) | ai_info | `main` (direct) | Nicholas Cardell | 2026-08-15 |
| Completed in Production | [Share Plan skill (email a plan to a teammate)](share-plan-skill.md) | ai_info | `main` (direct) | Nicholas Cardell | 2026-08-15 |
| Completed in Production | [eMed Orders Pharmacy Filter + Task Date-Sort Fix](emed-orders-pharmacy-and-task-sort.md) | multi | `feat/emed-orders-pharmacy-and-task-sort` | Nicholas Cardell | 2026-08-12 |
| Completed in Production | [Per-Page Read/Write Permissions](per-page-permissions.md) | emed_app | `feat/per-page-permissions` (1.0.201) | Nicholas Cardell | 2026-08-14 |

<!-- Add newest/most-active plans near the top. Keep each row to one line. -->

## Cross-team as-built briefings

Self-contained "what we actually built" write-ups meant for another team's Claude to study and compare
against a separate plan (broader than the terse status rows above):

- [Patient Portal + Facility Groups — As-Built Briefing](../projects/emed-app/patient-portal-and-facility-groups.md)
  — consolidates the two plans above with the cross-cutting release history, incidents/lessons, and the
  design decisions most likely to differ from an independent plan. (Written 2026-08-19 for Mario's review.)
