# Hardcopy META-tag step: the `{prefix}-image-root` secret is REQUIRED per pharmacy

**Found 2026-09-17** (PeakNow order 113410: shipped by Meduvo, no tracking on the store, no MOC tag in eMed).

## What the step does

`tag_full_orders_from_hardcopy` (`flows/emed_etl/liberty_extract_rtf_flow.py`, part of every
`Run-All-ETL-<TENANT>` run) opens the pharmacy's hardcopy PDF for each new script — the eMed
prescription PDF Liberty stored — and copies the `[META]` MOC/RX tag out of it into
`{prefix}_rxqFullOrder.tag_moc / tag_rx`. That link is what makes tracking flow back to the
clinic order (AST push) and to the partner API. The PDF path is
`<image root>\<rxqImageControl.Directory>\<rxqImageControl.FileName>` (Directory is relative,
e.g. `2026\09\`). Liberty stores **no** image-root setting in its database; the root is the
standard Liberty install share on that tenant's Liberty server: `\\<server>\LCS\ImageCTL`.

## The rule

- The image root comes from the Prefect Secret block **`{prefix}-image-root`** (or env var
  `{PFX}_IMAGE_ROOT`). **Create it when a tenant is onboarded**, next to its
  `{prefix}-database-*` secrets. Values as of 2026-09-17:
  - `rxcs-image-root` = `\\LIBERTYSVRRXCS\LCS\ImageCTL` (server renamed from `\\libertyserver` on 2026-09-16)
  - `mmed-image-root` = `\\libertyserver\LCS\ImageCTL` (Mister Meds; host `libertyserver.localdomain`)
  - `mdvo-image-root` = `\\LIBERTYSVRMDUVO\LCS\ImageCTL` (Meduvo; host 192.168.10.185)
- The code keeps a **per-tenant** fallback map (`DEFAULT_IMAGE_ROOTS`) and `resolve_image_root()`
  warns when it has to use it; a prefix with no entry gets **no root and skips the step loudly**.
  It must never fall back to *another* tenant's server (emed_etl fix of 2026-09-17).

## Why it matters — what happened

Until 2026-09-17 the code had ONE default (`DEFAULT_IMAGE_ROOT`, the RXCS server) and **no
`*-image-root` block existed for any pharmacy** on the Prefect server. Consequences:

- **Meduvo never tagged a single PDF** from its go-live (2026-08-03) to 2026-09-17: 73 ledger
  rows, 47 PDFs "found", 0 tagged. The old default `\\libertyserver` does not resolve on the
  Meduvo LAN; the new default is the RXCS server. Meduvo tracking that DID flow came from techs
  typing META notes (the note fallback).
- **Mister Meds broke at 08:05Z on 2026-09-17** when emed_etl PR #74 moved the default to the
  renamed RXCS server: its own Liberty host *is* `libertyserver`, so the old default had worked
  for months. 19 scripts were stamped in the two hours before it was caught
  (`[Errno 2] No such file ... \\LIBERTYSVRRXCS\...`).
- The failure is **silent by construction**: `_tag_from_hardcopy` returns found=1/tag_count=0 on a
  read error, the ledger gets `checked=1`, and the candidate query anti-joins the ledger, so the
  script is never re-checked. Same trap as the RXCS-JOBSERVER-2 share failure
  ([run-all-etl-silent-task-failures.md](run-all-etl-silent-task-failures.md)).

## How to spot it

- `{prefix}_hardcopy_tag_log`: a day where `SUM(found)` is high and `SUM(CASE WHEN tag_count>0)` is
  0 — especially every day since a tenant went live.
- Worker log (`C:\Users\<jobrunner>\.prefect\worker-logs*.txt`): `Secret <prefix>-image-root
  unavailable ... falling back to` and `[hardcopy] Could not read/parse PDF ... [Errno 2]` /
  `Access is denied`.
- eMed: `view_emed_full_order` rows for the pharmacy with `MocTag`/`RxTag` NULL while
  `TrackingNumber` is set; the PC/PN Orders page shows shipped orders with no tracking.

## How to fix / recover

1. Create the secret ON a job server with the worker's own profile (the Prefect API is not
   reachable from laptops and needs the worker's auth): a small Python script that builds the UNC
   from a bare host name — **never pass `\\host\share` on an ssh command line; the backslashes
   collapse** — and calls `Secret(value=...).save("<prefix>-image-root", overwrite=True)`.
2. Reset the ledger rows that were stamped while the root was wrong
   (`UPDATE {prefix}_hardcopy_tag_log SET checked = 0 WHERE checked = 1 AND found = 1 AND
   tag_count = 0 AND applied = 0 [AND checked_date >= <when it broke>]`) so the next 15-minute
   run re-checks them. Limit by date for a long-healthy tenant — old found-but-untagged rows are
   legitimately tag-less documents.
3. Watch the next run: `Hardcopy tag batch: N scripts ... rows tagged: M`. If reads then fail with
   `Access is denied`, the *service account's* Credential Manager vault needs the file-server
   credential (RXCS lesson: an SSH-context probe is not the service context).

## Related

- [run-all-etl-silent-task-failures.md](run-all-etl-silent-task-failures.md) — the same
  "green flow, stale mirror" family.
- [context.md](context.md) — environment / tenant onboarding.
- The store side of the same incident: peaknow.com's AST Pro provider table had no provider
  enabled (`display_in_order = 1` on none of 1,078 rows) after the site migration, so the admin
  "Shipping Provider" dropdown was empty; FedEx (id 64, slug `fedex`) was enabled 2026-09-17.
- **AST Pro does not dedupe by tracking number.** A tracking line added by hand (`ast_insert_tracking_number`)
  sits beside the ETL's later REST push as a second identical line; prefer fixing the tag so the ETL writes
  it, and if you add one by hand, remove it with `delete_tracking_item($order_id, $tracking_id)` once the
  ETL line lands.
