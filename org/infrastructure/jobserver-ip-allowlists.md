# Job-server public-IP allowlists — the dynamic-IP outage (Prefect NSG + Azure SQL + Blob)

**Symptom:** a whole site's Prefect workers go OFFLINE together (heartbeats stop within seconds of each
other) and stay down. On the host, `Get-Service PrefectWorker` says **Running** — NSSM is crash-looping
`prefect.exe` every ~90 s (Application log events 1013/1014), the worker log is 0 bytes because each restart
truncates it, and the worker's socket to the Prefect VM (168.62.48.84:443) sits in **`SynSent`**.

**Cause:** the job servers reach Azure over a **dynamic WAN lease**, and three Azure resources only accept
traffic from an explicit list of source IPs. When the site's egress IP changes, every list is wrong at once,
and each fix unmasks the next failure.

| # | Resource | Where | Symptom when the site IP is missing |
|---|---|---|---|
| 1 | NSG `DevVM1-nsg` (Prefect server VM) | rg `NetworksRG` | workers OFFLINE, `SynSent` to 168.62.48.84:443, NSSM crash-loop |
| 2 | Azure SQL server `liberty-link` firewall | rg `Databases`; server-level, `master.sys.firewall_rules` | every run fails: `40615 Cannot open server 'liberty-link' ... Client with IP address 'x' is not allowed` |
| 3 | Storage account `etststorageaccount` | network rules, default **Deny** | `Calls-Archive-Recordings` fails with Blob `AuthorizationFailure` (not `AuthenticationFailed` — the key is fine) |

Fixing #1 alone brings the workers back and then **every rxcs-queue run fails loudly** on #2 — an
intermediate state that looks worse than the outage. Fixing #2 leaves #3 failing every 30 min, and #3 has a
deadline (RingCentral purges call audio after ~90 days). Fix all three before declaring recovery.

## History — the RXCS site flip-flops between two IPs (2026-09-01 / 02)

| When (UTC) | RXCS egress IP | What broke |
|---|---|---|
| before 2026-09-01 09:20 | 99.173.152.84 | — (workers ran from it; in all three lists) |
| 2026-09-01 09:20 | — | unclean power loss at the site; both hosts rebooted 10:47 / 10:51 |
| 2026-09-01 ~13:26 (first Tailscale sighting) | **96.64.184.142** | all three lists → ~5.5 h rxcs outage, fixed one list at a time (NSG 13:47, SQL ~14:30, blob 14:57) |
| 2026-09-01 14:52 | — | 99.173.152.84 **removed** from the NSG as "stale" |
| 2026-09-01 18:23 | **99.173.152.84** again | NSG (removed 3.5 h earlier) + storage (never re-added) → rxcs queue dead overnight, 9 h+ |

**Lesson: never remove the "old" IP from an allowlist after a lease change — the lease flips back.**
Keep every IP the site has been seen on in **all three** lists until the site has a static IP.

## Diagnostic sequence (works during the outage — Tailscale SSH does not depend on the NSG)

1. **Server view:** `POST /work_pools/etst-work-pool/workers/filter` → OFFLINE workers whose heartbeats
   stopped seconds apart = a host/site event, not a service crash.
2. **On the host** (`ssh rxcsjob1`; access policy in
   [../../projects/emed-etl/jobserver-ssh-access.md](../../projects/emed-etl/jobserver-ssh-access.md),
   mechanics in [tailscale-ssh.md](tailscale-ssh.md)): service Running, `prefect.exe` only a minute old,
   `Get-NetTCPConnection -RemotePort 443` shows `168.62.48.84:443 SynSent`. Run a diagnostic `.ps1` via
   `scp file rxcsjob1:file` + `ssh rxcsjob1 "powershell -NoProfile -ExecutionPolicy Bypass -File file"` —
   avoids the `-EncodedCommand` size limit and all nested quoting.
3. **`Test-NetConnection -Port 443` against several hosts:** Prefect **fails** while Azure SQL, the
   Liberty API, google and github **succeed** → a per-destination allowlist, not a local network fault.
4. **Egress IP:** `Invoke-WebRequest http://ifconfig.me/ip`. **IP history:** Tailscale's own log
   `C:\ProgramData\Tailscale\Logs\tailscale-service-*.txt`, lines `v4a=<ip>:<port>` (read with
   `Select-String -Encoding utf8`) — the public IP is recorded every ~20 s, so it dates a flip to the second.
5. **Compare against all three lists:**
   - NSG: ARM REST `GET .../resourceGroups/NetworksRG/providers/Microsoft.Network/networkSecurityGroups/DevVM1-nsg?api-version=2023-05-01`
     with a token from the `prefect-automations-*` service principal (Secret blocks `azure-tenant-id`,
     `prefect-automations-azure-client-id`, `-client-secret`). It has Network Contributor, so it can also
     **write** the rule — a firewall change is a security-settings change; don't make it without asking.
   - SQL: connect to `master` with the emed_sql admin login and `SELECT * FROM sys.firewall_rules`
     (`sys.database_firewall_rules` is empty — rules are server-level). The service principal gets `200`
     + an empty list here; that is a permissions artifact, not "no rules".
   - Storage: `az storage account show -n etststorageaccount --query networkRuleSet` (needs a user
     `az login`; the service principal can't see the account).

## Recovery order

1. Bulk-cancel the Late backlog **immediately before** re-opening the NSG — no concurrency cap exists on
   the pool, the queues, or most deployments, so a reconnected worker stampedes (the 60-second
   `rxqNotes-*` / `SMS-Send-Pending` deployments rebuild the backlog at ~150 runs/hour).
2. Add the IP to the NSG → workers reconnect on the next crash-loop iteration (~90 s), queue READY.
3. Add it to the SQL server firewall **and** the storage account before the first runs fail, not after.
4. Verify from the host without a production run: pipe a script into the worker's own interpreter
   (`cat check.py | ssh rxcsjob1 'C:\Users\jobrunner\AppData\Local\Programs\Python\Python313\python.exe -'`)
   — once the NSG is open it can `Secret.load(...)` and exercise the exact credential path a flow uses.

## Durable fix (open)

The site is on a dynamic lease, so this recurs on every power event or ISP renewal. Either a static IP
from the ISP, or put the Prefect VM (and the SQL/blob path, via private endpoints) behind Tailscale so no
public allowlist is involved. Until then, both known IPs stay in all three lists.
