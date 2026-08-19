# Job Server SSH Access (capability + policy)

There is a capability to reach the four ETL job servers over **Tailscale + key-based SSH**, to run remote
PowerShell on them (check/restart Prefect workers, tail logs) and to **query each tenant's live Liberty
source database directly** — read-only, and only from that tenant's own box (mapping below).

## Access is restricted — request it, don't self-provision

For security, SSH access to these production, PHI-adjacent servers is **deliberately limited**. As of
2026-08-18 the only people with access are:

- **Carlos Cueto** (server administrator)
- **Nicholas Cardell**

**If you're a developer who needs this access, request it from Carlos Cueto or Nicholas Cardell.** Access
is granted per person (your own SSH key), is individually revocable, and every login is attributed to an
individual key — it is never shared credentials. Do **not** attempt to provision your own access: the
tailnet, the network path, and the key install are administered by Carlos and Nicholas.

> This access carries **full administrator** rights on servers that sit next to patient data — which is
> exactly why the holder list is kept short. Expanding it is a deliberate decision by Carlos and
> Nicholas, not self-serve onboarding.

## Which box reaches which pharmacy's Liberty DB

Each tenant's Liberty source DB (`RXQRXCOMPOUNDSTORE`) is reachable **only** from that tenant's
job-server network — which is why Prefect deployments are pinned to per-tenant queues
(worker-provisioning.md #6). To query a pharmacy's *live* Liberty data directly (not just the ~11 tables
mirrored into `liberty_link_stage`), you work from that pharmacy's box:

| Pharmacy (tenant) | Job server(s) | Liberty source DB |
|-------------------|---------------|-------------------|
| Rx Compound Store (`rxcs`) | rxcs-jobserver-1, rxcs-jobserver-2 | RXCS |
| Mister Meds (`mmed`) | mm-jobserver-1 | MMED |
| Meduvo (`mdvo`) | mdsvr02 | MDVO |

Treat the Liberty source as **READ-ONLY** — it is the live upstream pharmacy system; the ETL only ever
reads from it. Full 360-table schema: [`ai_info/reference/liberty-db/`](../../reference/liberty-db/README.md)
— read it before querying. The two RXCS servers share the RXCS queue, so a flow may land on either; use
`hostname` (not `$env:COMPUTERNAME`; see trap 3) to know which one ran something.

## Operating tips for whoever has access (three SSH traps)

Default remote shell on all four boxes is **PowerShell 7**. These three gotchas cost real time and none
are guessable:

1. **ssh strips inner double quotes** from a remote command, and the remote shell reparses any `|` inside
   it as a pipeline — you get "term not recognized" for a fragment of your own regex. Filter locally
   (`ssh <host> 'Get-Content file' | grep ...`) or use the encoded-command pattern (trap 2). Wrapping the
   remote command in **single** quotes and avoiding `$_` / inner `"` also survives.
2. **pwsh returns CLIXML unless you ask for text.** A remote `pwsh -EncodedCommand` emits tens of KB of
   XML instead of your output unless you pass `-OutputFormat Text` (and set
   `$ProgressPreference='SilentlyContinue'` in the script). The bytes must be **UTF-16LE**
   (`[Text.Encoding]::Unicode`), not UTF-8.
3. **`$env:COMPUTERNAME` can't tell the two RXCS boxes apart** — both machine names exceed the 15-char
   NetBIOS limit and report the identical `RXCS-JOBSERVER-`. Use `hostname` (or
   `[Net.Dns]::GetHostName()`), which returns the full distinct name.

Operational specifics — tailnet addresses, login accounts, key install/revoke — are held by Carlos and
Nicholas and are intentionally **not** published here.

## Related
- [worker-provisioning.md](worker-provisioning.md) — bringing up a new worker host
- [`ai_info/reference/liberty-db/`](../../reference/liberty-db/README.md) — full Liberty source schema
