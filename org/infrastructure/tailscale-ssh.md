# Tailscale SSH (Job Servers)

Remote shell access to the ETL job servers runs over a Tailscale tailnet. Added 2026-08-17/18 so
engineers — and their Claude Code instances — can troubleshoot workers directly instead of going
through RemotePC.

**This is an access plane only.** No ETL data crosses the tailnet; flows talk to Azure SQL and
Liberty exactly as before. Tailnet latency never affects pipeline throughput.

> Not the same thing as the **Cloudways SSH/SFTP** credentials in `emed_etl/.env` — those are for the
> Peaks WordPress host and are unrelated to the job servers.

## Servers

Verified 2026-08-18 by reading each worker's command line. The pharmacy a box serves is **not**
inferable from its hostname — `mdsvr02` breaks the naming convention entirely.

| SSH alias | Machine name | Pharmacy | Work queue | Prefect worker | Login |
|-----------|--------------|----------|------------|----------------|-------|
| `mmjob1` | `MM-JOBSERVER-1` | Mister Meds | `mmed-jobserver-workqueue` | `mmed-jobserver-worker` | `jobrunner` |
| `rxcsjob1` | `RXCS-JOBSERVER-1` | Rx Compound Store | `rxcs-jobserver-workqueue` | `rxcs-jobserver-worker` | `jobrunner` |
| `rxcsjob2` | `RXCS-JOBSERVER-2` | Rx Compound Store | `rxcs-jobserver-workqueue` | `rxcs-jobserver-worker2` | `jobrunner` |
| `mdvo-jobserver` | `MDSVR02` | Meduvo | `mdvo-jobserver-workqueue` | `mdvo-jobserver-worker` | `administrator` |

Every host runs a `PrefectWorker` NSSM service against the shared `etst-work-pool`, plus the
`default` queue.

**The two RXCS boxes share one queue.** A given `rxcs` flow run lands on whichever worker picks it
up, so "which server ran this?" is never answerable from the queue name alone.

## Access model

- **Key-based only.** `PasswordAuthentication no`, `KbdInteractiveAuthentication no` on all four.
  There is no password fallback — a missing key means no access.
- **Each person uses their own keypair.** Never share a private key. Public keys go in
  `C:\ProgramData\ssh\administrators_authorized_keys`; revoking is deleting that one line, per host.
- **Login accounts are shared** (`jobrunner`, `administrator`), so attribution comes from the key
  fingerprint sshd logs on every connection, not from the username.
- **You get a full elevated token.** Windows OpenSSH does not apply UAC filtering to administrators,
  so an SSH session can edit protected paths and restart services. Treat it as a root shell.
- Port 22 is firewalled to the tailnet range on every host and is not reachable from the internet.

## Gotchas

Three things that cost real time to discover. All three apply to any remote command.

1. **ssh strips inner double quotes.** A quoted regex containing `|` gets reparsed as a pipeline by
   the remote shell, and the error names a fragment of your own pattern. Filter locally, or use
   encoded commands.
2. **pwsh returns CLIXML unless told otherwise.** Use
   `pwsh -NoProfile -NonInteractive -OutputFormat Text -EncodedCommand <base64-UTF16LE>`. Without
   `-OutputFormat Text` you get tens of KB of XML progress records instead of output. The encoding
   must be UTF-16LE.
3. **`$env:COMPUTERNAME` cannot identify the RXCS servers.** `RXCS-JOBSERVER-1` and
   `RXCS-JOBSERVER-2` are both 16 characters and the NetBIOS name truncates at 15, so **both report
   the identical string `RXCS-JOBSERVER-`**. Since they also share a work queue, anything logging
   the machine name is ambiguous about which box ran a flow. Use `hostname`,
   `[Net.Dns]::GetHostName()`, or `Win32_ComputerSystem.DNSHostName` — all return the full distinct
   name. The machines are intentionally not being renamed.

## Getting access

Ask Carlos. You need a Tailscale invite to the tailnet plus your public key installed on each host
you need. Step-by-step setup — including tailnet addresses and host key fingerprints for
first-connect verification — is in the onboarding runbook; ask Carlos for the link.

Server hostnames, queues, and gotchas live here; addresses and fingerprints deliberately do not.
