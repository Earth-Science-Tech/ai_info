# Public Script API — correlation tags on `/escript` & `/scripts`

**As of 2026-07-31 (emed_app PR #298, tag 1.0.170):** the two public prescription-status
endpoints return **five correlation tags** so external clinics can reconcile a pharmacy
script back to their own order or our visit.

| Field | View column | Meaning |
|---|---|---|
| `OrderTag` | `tag_order` (`clinic_order_id`) | **The clinic's own order id** they sent us — the most reliable correlation key. |
| `eScriptTag` | `tag_escript` | The eScript number/identifier. |
| `BlazeTag` | `tag_blaze` | The clinic's Blaze order id (e.g. a Blaze re-entry after an eMed script was rejected). |
| `MocTag` | `tag_moc` (`moct_visit.id`) | Our internal MOCT visit id — same `VisitId` returned by `POST /moct/visit`. |
| `RxTag` | `tag_rx` (`moct_drug_rx.id`) | Our internal drug-Rx id for the specific line. |

All five come from `view_*_full_order` (→ `{rxcs,mmed,mdvo}_rxqFullOrder.tag_*`, populated by the
`usp_etl_*_rxqFullOrder_metadata` procs). They are **best-effort** — any may be `null`, and
`MocTag`/`RxTag`/`OrderTag` are hand-entered or ETL-derived, so treat them as hints, not
guarantees. See [[reference_moctag_rxtag_linkage]] for how MocTag/RxTag are linked and how to
durably null a bad link.

## What changed

`eScriptTag`, `RxTag`, `OrderTag` were **already returned** (just undocumented). `MocTag` +
`BlazeTag` were being **explicitly stripped** in `route_public.js` (`get_escript` / `get_scripts`)
— originally to avoid confusing users. PR #298 stopped stripping them and documented all five in
the in-app API docs (`views/partials/api-docs-content.ejs` → `/escript` Response Fields). The
change is **additive / non-breaking** (new fields only) and needed **no schema change** — the view
already exposes the columns. Endpoints stay clinic-scoped (`emed.can_view_rx`); tags are opaque
correlation ids, not new PHI.

Canonical, always-current field list lives in the in-app API docs at `/api-documentation`
(Pharmacy API → `GET /escript`).
