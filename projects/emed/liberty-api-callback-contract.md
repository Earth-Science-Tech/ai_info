# Liberty API callback contract — a timeout is NOT a success

**One-line rule:** in `server/liberty.js`, every call through `module.exports(db).api(...)` gets a
`(data, error)` callback. **A write/mutation must decide success/failure from `error`, never from
`data` alone** — because Liberty returns an **empty body on success**, so `data === null` is
ambiguous (it means *either* "2xx success with empty body" *or* "timeout / network / HTTP error").

## Why this matters (the incident)

During the 2026-07-15 Liberty outage, MOCT visits were marked **"Approved by Prescriber" while the
prescription never reached the pharmacy** (e.g. visit 1038002 — had to be reverted and re-approved
by hand). Root cause: `submit_prescription` used a single-arg `(data) =>` callback and treated a
`null` response as success. Liberty's `/pendingscript` returns an empty body on success, so a
**timeout was indistinguishable from success** and returned `{success:true}` — the visit advanced,
the PDF was saved, `script_created` was stamped, but nothing was sent.

## The contract (defined in `server/misc.js` `api_call`)

```
fn_data(data, error)
  • HTTP 2xx success:        error = null.  data = parsed JSON, or null if the body was empty.
  • timeout / network / 4xx-5xx / bad JSON:  error = a non-null Error, data = null.
```

`api_call` enforces a hard per-call timeout (default 90s, `API_CALL_TIMEOUT_MS`) and normalizes an
abort into `Error("Request timed out after …ms")`. `liberty.js` `api()` forwards `(data, error)`
straight through to your callback. So the disambiguation you need is already handed to you — the
only bug is *ignoring the second argument*.

## The rule for new/edited Liberty calls

**Mutations (POST/PUT/DELETE — empty body means success):** you MUST branch on `error` first.

```js
module.exports(db).api('/endpoint', 'POST', (data, error) => {
    if (error) { resolve({ success:false, error: error.message, data:null }); return; }
    if (data && data.message) { resolve({ success:false, error:data.message, data }); return; }
    resolve({ success:true, data });          // genuine 2xx (possibly empty body)
}, payload);
```

**GETs:** safer by nature (you need positive data to report success, so `if(!data) → failure`
already fails safe on a timeout), but prefer to still read `error` so the message says "timed out"
rather than "no data", and — importantly — **paginators must not silently drop a timed-out page.**
A dropped overflow page = silent partial data reported as complete (this is the same class the
2026-07-02 load-control work fixed for the ready-queue paginator via `_incomplete`/`_failedPages`).

## Audit status (2026-07-24)

All **mutations** now key failure off `error`:
- `submit_prescription`, `submit_refill`, `update_patient` — fixed in prod tag **1.0.112**
- `create_patient`, `clear_workflow_location` — fixed by the Liberty write-outbox work
- `post_shipment`, `mark_picked_up`, `cancel_pickup`, `mark_returned`, `get_inventory_snapshot` —
  already correct (retrofitted for the POP/shipping flows)

All **GET** callers fail safe (require positive data for success). **Two residual GET gaps** (read
path, low severity — flagged, not yet fixed):
1. `find_patient` drops `error` → a timeout reads as "not found", so `find_or_create_patient` can
   create a **duplicate patient**. Bounded: a full outage also fails `create_patient`, so it only
   bites on an intermittent blip.
2. `get_prescriptions_by_patient` overflow-page fetch drops `error` → a timed-out page 2+ is
   silently skipped while still returning `success:true` (only patients with >100 scripts, during a
   Liberty hiccup).

## Related

- Durable retry so a genuinely-failed write isn't lost: `emed_liberty_outbox` + `liberty_outbox_worker.js`
  (retries are command-level and idempotent via `emed.redrive_unsent_scripts()` — re-reads DB state
  and only submits `moct_drug_rx` rows still lacking `script_created`, so a re-drive after a
  timeout-that-landed converges to a no-op — never a raw payload replay).
- Forensics for every write: `emed_liberty_write_log` (hook in `api()`).
- Load control / lanes / paginator `_incomplete` reporting: the 2026-07-02 Liberty load-control work.
