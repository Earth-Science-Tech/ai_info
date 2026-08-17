# eMed Plans & Features — Index

The team-shared record of every feature/project and **where it is in the pipeline**. Any engineer's
Claude reads this to see what's in flight and to **take over** work. One file per feature in this folder
(`<slug>.md`, named for its `feat/<slug>` branch). Add/maintain a row here whenever you create a plan or
change its status. Full rules: [`skills/plan-tracking.md`](../skills/plan-tracking.md).

**Status legend:** `Not Started` → `In-Progress` → `Completed in Dev` → `Completed in Production`
(plus `On Hold`, `Abandoned` when needed).

| Status | Plan | Project | Branch | Developers | Updated |
|--------|------|---------|--------|------------|---------|
| Completed in Production | [Facility Scope Unification (FacilityGroups)](facility-scope-groups.md) | multi | `feat/patient-portal-secure-messaging` (1.0.205–1.0.207) | Nicholas Cardell | 2026-08-17 |
| Completed in Production | [Patient Portal + Secure Messaging (Phase 1, ships DARK)](patient-portal-secure-messaging.md) | multi | `feat/patient-portal-secure-messaging` (1.0.205) | Nicholas Cardell | 2026-08-17 |
| Completed in Production | [Sync Everything skill (pull all repos + reload)](sync-everything-skill.md) | ai_info | `main` (direct) | Nicholas Cardell | 2026-08-15 |
| Completed in Production | [Share Plan skill (email a plan to a teammate)](share-plan-skill.md) | ai_info | `main` (direct) | Nicholas Cardell | 2026-08-15 |
| Completed in Production | [eMed Orders Pharmacy Filter + Task Date-Sort Fix](emed-orders-pharmacy-and-task-sort.md) | multi | `feat/emed-orders-pharmacy-and-task-sort` | Nicholas Cardell | 2026-08-12 |
| Completed in Production | [Per-Page Read/Write Permissions](per-page-permissions.md) | emed_app | `feat/per-page-permissions` (1.0.201) | Nicholas Cardell | 2026-08-14 |

<!-- Add newest/most-active plans near the top. Keep each row to one line. -->
