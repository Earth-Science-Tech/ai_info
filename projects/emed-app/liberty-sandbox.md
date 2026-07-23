# Liberty Sandbox Mode

The eMed app can talk to a Liberty sandbox instance instead of prod when the operator opts in per run. Wired 2026-07 by Carlos Obregon; credentials from Chris at Liberty. This exists so we can exercise write flows (inventory push, prescription submit, patient create, and so on) end to end without touching Liberty production.

## Feature flag

The switch is a single env var read at startup in `server/liberty.js`:

- `LIBERTY_USE_SANDBOX=0` (or unset): the app talks to `api.libertysoftware.com` (prod) with the normal per-pharmacy credentials. Writes are gated by `shipping_api_disabled` (default true off-prod).
- `LIBERTY_USE_SANDBOX=1`: the app talks to `devapi.libertysoftware.com` with the sandbox credentials, and `shipping_api_disabled` is forced to false so writes actually go over the wire.

Opt in per run:

```
npm run start:dev           # current behavior, prod URL, writes disabled locally
npm run start:dev:sandbox   # LIBERTY_USE_SANDBOX=1, sandbox URL, writes fire
```

`start:dev:sandbox` uses `cross-env` so it works on Windows and POSIX.

## Env vars

Add these to `emed_app/.env`. Values are shared via Liberty out of band, never committed:

```
LIBERTY_USE_SANDBOX=0
LIBERTY_SANDBOX_URL=https://devapi.libertysoftware.com
RXCS_LIBERTY_SANDBOX_USER=
RXCS_LIBERTY_SANDBOX_PASS=
RXCS_LIBERTY_SANDBOX_NPI=
RXCS_LIBERTY_SANDBOX_API_KEY=
```

`.env.example` in the repo has these as placeholders.

## Auth quirk

Prod uses the `Customer` header as a pre-encoded string. Sandbox uses `base64(NPI:APIKey)` computed at request time by `sandbox_customer_header()` in `server/liberty.js`. Do not paste the sandbox `Customer` header directly; feed the NPI and API key and let the helper build it.

## What is in the sandbox

- ~4,633 drugs. Separate database, not a copy of prod.
- Real reference catalog (real names, real public NDCs like Metformin, Warfarin, Penicillin) so payload shapes are realistic.
- Explicit dummy rows for testing (e.g. `AAAC "TEST"` with NDC `00000000012`, `AAAD "TEST DRUG"` with NDC `01234567890`).

## Big gotcha: DrugId collisions across environments

Drug IDs are 4-char codes in both prod and sandbox and they overlap alphabetically, but the mapping DrugId -> drug is completely different. Concrete example:

- `AAAA` in sandbox is Metformin.
- `AAAA` in our prod is Sildenafil.

This is coincidence, not aliasing. Never assume a DrugId means the same thing across environments, and never test a prod-specific bug against a hardcoded DrugId assumption in sandbox.

## Pharmacy scope

Only `rxcs` sandbox credentials are provisioned right now. `mmed` and `mdvo` do not have sandbox creds; a `LIBERTY_USE_SANDBOX=1` call for those pharmacies will fail auth. If we ever need mmed/mdvo sandbox, ask Liberty to provision them.

## Safe defaults

- `LIBERTY_USE_SANDBOX` is 0 by default. `feat/inventory-bootstrap` did not change any prod URL constants.
- The Azure prod slot never sets `LIBERTY_USE_SANDBOX=1`. It stays a local/dev opt-in.
- The Azure dev slot writes to Liberty PROD (single Liberty instance behind the app for both slots) unless you flip sandbox mode there too. Carlos verified this on 2026-07-22 while validating the inventory reconciliation write-back.

## Related code paths

- `server/misc.js` `is_liberty_sandbox()` mirrors the pattern of `is_prod()` / `is_dev()`.
- `server/liberty.js`
  - URL selection: sandbox host wins when the flag is on.
  - `gen_fetch_info()` branches per pharmacy for sandbox vs prod creds.
  - `sandbox_customer_header()` builds the `Customer` header from NPI + API key.
- `package.json` scripts: `start:dev:sandbox` uses `cross-env LIBERTY_USE_SANDBOX=1`.

## When to reach for this

- Testing any Liberty write path (`push_inventory_snapshot`, `submit_prescription`, `create_patient`, `move_to_paid`, `clear_workflow_location`, refill create).
- Verifying pagination fan-out or `liberty_limiter.js` behavior without saturating prod Liberty.
- Reproducing a call that fails in dev slot against prod Liberty (isolate whether the bug is in our code or in the Liberty request shape).

## When to NOT reach for this

- If you only need to READ prod data (drug lookups, snapshot). Reads via the dev slot already hit prod Liberty; using sandbox will confuse you because the drug catalog is different.
- Anything involving mmed or mdvo until Liberty provisions their sandbox creds.
