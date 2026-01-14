# Complete Attack Chain Example

This reference provides a full, production-quality example of attack chain documentation.

---

## Typst Format Example

```typst
= Persistence

== Create or Modify System Process: LaunchAgent / LaunchDaemon

=== Technique Overview

Persistence via LaunchAgents and LaunchDaemons is the most common and well-documented persistence mechanism on macOS. `launchd` is the operating system's init process, responsible for managing services and daemons.

- *LaunchDaemons (T1543.004)*: These are system-level services. Their configuration .plist (property list) files are stored in `/Library/LaunchDaemons/`, execute at system startup, and run as root. This technique provides both persistence and privilege escalation.

- *LaunchAgents (T1543.001)*: These are user-level services. Their .plist files are stored in `~/Library/LaunchAgents/` (for a specific user) or `/Library/LaunchAgents/` (for all users). They are executed when the user logs in and run with that user's privileges.

The persistence mechanism is simple but powerful: launchd automatically loads and manages any valid .plist file in these directories. Adversaries exploit this by dropping malicious .plist files that execute their payloads.

=== Attack Steps

1. *Create Plist Configuration*: An adversary crafts a .plist file (XML format) that specifies what program to run and when

2. *Plist Content*: The .plist contains key-value pairs defining the job:
   - `Label`: Unique job identifier (e.g., "com.evil.agent")
   - `ProgramArguments`: Array of strings defining the command and arguments
   - `RunAtLoad`: Boolean set to true to execute immediately on load
   - `KeepAlive`: Boolean to restart if process dies

3. *Drop Plist File*: The adversary places this file in one of three locations:
   - `~/Library/LaunchAgents/` - User-specific, loads at user login
   - `/Library/LaunchAgents/` - All users, loads at any user login
   - `/Library/LaunchDaemons/` - System-wide, loads at boot (requires root)

4. *Trigger Execution*: Persistence activates automatically on next login/reboot, or adversary manually loads it:
   ```bash
   launchctl load -w /path/to/com.evil.plist
   ```

Example minimal plist:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.agent</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>/Users/victim/.hidden/backdoor.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

=== Detection Opportunities

- *File Monitoring (High Fidelity)*: Creation of any new .plist file in LaunchAgent or LaunchDaemon directories is high-priority. These directories rarely change in normal operations. Monitor:
  - `~/Library/LaunchAgents/*.plist`
  - `/Library/LaunchAgents/*.plist`
  - `/Library/LaunchDaemons/*.plist`

- *Masquerading Detection (High Fidelity)*: Attackers frequently name malicious plists to look legitimate, such as `com.apple.*.plist`. **Apple's native plists reside in `/System/Library/`, not `~/Library/` or `/Library/`**. Flag any .plist with "com.apple.*" naming in user/system directories.

- *Process Monitoring (Medium Fidelity)*: Monitor for `launchctl` execution with `load`, `bootstrap`, or `start` arguments, especially from anomalous parent processes (not Terminal, System Preferences, or installer processes).

- *Content Analysis (Medium Fidelity)*: Parse .plist files for suspicious indicators:
  - Obfuscated or encoded commands
  - Unusual interpreters (python, perl, ruby executing hidden scripts)
  - Network connections in ProgramArguments
  - References to /tmp, hidden directories, or unusual paths

- *Evasion Techniques*:
  - Attackers may use legitimate-looking names
  - May modify existing plists instead of creating new ones
  - May use `launchctl` alternatives or direct file operations

=== Data Sources & Log Fields

*Endpoint Security Framework (ESF):*

- `ES_EVENT_TYPE_NOTIFY_CREATE`: Detects new plist creation
  - `file.path`: Full path to .plist file
  - `process.executable.path`: Process that created the file
  - `process.audit_token.pid`: Creating process PID
  - `process.parent_audit_token.pid`: Parent process for lineage

- `ES_EVENT_TYPE_NOTIFY_WRITE`: Modifications to existing plists
  - `file.path`: Path to modified .plist
  - `process.executable.path`: Modifying process

- `ES_EVENT_TYPE_NOTIFY_EXEC`: launchctl execution
  - `process.executable.path`: Should be `/bin/launchctl`
  - `process.arguments`: Parse for `load`, `bootstrap`, `start`, `bootout`
  - `process.parent_audit_token.pid`: Check for suspicious parent

*Unified Logs (macOS system logs):*
```bash
# View launchd and launchctl activity
log show --predicate 'process == "launchd" OR process == "launchctl"' \
  --info --last 1h

# Filter for loading events
log show --predicate 'eventMessage CONTAINS "load" AND process == "launchctl"' \
  --info --last 24h
```

*File System Events (fsevents):*
- Monitor paths: `*/LaunchAgents/`, `*/LaunchDaemons/`
- Event types: Created, Modified

*Command line monitoring:*
```bash
# List all loaded LaunchAgents/Daemons
launchctl list

# Examine specific plist
launchctl print system/com.suspicious.agent
```

=== Psuedocode Queries

*High Fidelity: New Plist Created in Monitored Directory*
```
event.type == "file_create" AND
file.path MATCHES "*/LaunchAgents/*.plist" OR 
file.path MATCHES "*/LaunchDaemons/*.plist"
```

*High Fidelity: Apple Plist Masquerading*
```
event.type == "file_create" AND
file.name MATCHES "com.apple.*.plist" AND
file.path NOT MATCHES "/System/Library/*"
```

*Medium Fidelity: Suspicious launchctl Execution*
```
event.type == "process_start" AND
process.name == "launchctl" AND
process.command_line MATCHES ".*(load|bootstrap|start).*" AND
process.parent.name NOT IN ["Terminal", "iTerm2", "Installer", "System Preferences"]
```

*Medium Fidelity: Plist with Obfuscated Content*
```
event.type == "file_create" AND
file.path MATCHES "*/Launch(Agents|Daemons)/*.plist" AND
file.content MATCHES ".*(base64|eval|curl|wget).*"
```

*Behavioral: Unusual Plist Modifications*
```
event.type == "file_write" AND
file.path MATCHES "*/Launch(Agents|Daemons)/*.plist" AND
process.name NOT IN ["Installer", "softwareupdate", "defaults", "plutil"]
```

=== MITRE ATT&CK Mapping

#table(
  columns: 3,
  stroke: 0.5pt,
  fill: (col, row) => if row == 0 { luma(240) },
  align: (left, left, left),
  [*Tactic*], [*Technique ID*], [*Technique Name*],
  [Persistence], [T1543.001], [Create or Modify System Process: Launch Agent],
  [Privilege Escalation], [T1543.001], [Create or Modify System Process: Launch Agent],
  [Persistence], [T1543.004], [Create or Modify System Process: Launch Daemon],
  [Privilege Escalation], [T1543.004], [Create or Modify System Process: Launch Daemon],
)
```

---

## Markdown Format Example

```markdown
# Persistence

## Create or Modify System Process: LaunchAgent / LaunchDaemon

### Technique Overview

Persistence via LaunchAgents and LaunchDaemons is the most common and well-documented persistence mechanism on macOS. `launchd` is the operating system's init process, responsible for managing services and daemons.

- **LaunchDaemons (T1543.004)**: These are system-level services. Their configuration .plist (property list) files are stored in `/Library/LaunchDaemons/`, execute at system startup, and run as root. This technique provides both persistence and privilege escalation.

- **LaunchAgents (T1543.001)**: These are user-level services. Their .plist files are stored in `~/Library/LaunchAgents/` (for a specific user) or `/Library/LaunchAgents/` (for all users). They are executed when the user logs in and run with that user's privileges.

The persistence mechanism is simple but powerful: launchd automatically loads and manages any valid .plist file in these directories. Adversaries exploit this by dropping malicious .plist files that execute their payloads.

### Attack Steps

1. **Create Plist Configuration**: An adversary crafts a .plist file (XML format) that specifies what program to run and when

2. **Plist Content**: The .plist contains key-value pairs defining the job:
   - `Label`: Unique job identifier (e.g., "com.evil.agent")
   - `ProgramArguments`: Array of strings defining the command and arguments
   - `RunAtLoad`: Boolean set to true to execute immediately on load
   - `KeepAlive`: Boolean to restart if process dies

3. **Drop Plist File**: The adversary places this file in one of three locations:
   - `~/Library/LaunchAgents/` - User-specific, loads at user login
   - `/Library/LaunchAgents/` - All users, loads at any user login
   - `/Library/LaunchDaemons/` - System-wide, loads at boot (requires root)

4. **Trigger Execution**: Persistence activates automatically on next login/reboot, or adversary manually loads it:
   ```bash
   launchctl load -w /path/to/com.evil.plist
   ```

Example minimal plist:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.agent</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>/Users/victim/.hidden/backdoor.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

### Detection Opportunities

- **File Monitoring (High Fidelity)**: Creation of any new .plist file in LaunchAgent or LaunchDaemon directories is high-priority. These directories rarely change in normal operations. Monitor:
  - `~/Library/LaunchAgents/*.plist`
  - `/Library/LaunchAgents/*.plist`
  - `/Library/LaunchDaemons/*.plist`

- **Masquerading Detection (High Fidelity)**: Attackers frequently name malicious plists to look legitimate, such as `com.apple.*.plist`. **Apple's native plists reside in `/System/Library/`, not `~/Library/` or `/Library/`**. Flag any .plist with "com.apple.*" naming in user/system directories.

- **Process Monitoring (Medium Fidelity)**: Monitor for `launchctl` execution with `load`, `bootstrap`, or `start` arguments, especially from anomalous parent processes (not Terminal, System Preferences, or installer processes).

- **Content Analysis (Medium Fidelity)**: Parse .plist files for suspicious indicators:
  - Obfuscated or encoded commands
  - Unusual interpreters (python, perl, ruby executing hidden scripts)
  - Network connections in ProgramArguments
  - References to /tmp, hidden directories, or unusual paths

- **Evasion Techniques**:
  - Attackers may use legitimate-looking names
  - May modify existing plists instead of creating new ones
  - May use `launchctl` alternatives or direct file operations

### Data Sources & Log Fields

**Endpoint Security Framework (ESF):**

- `ES_EVENT_TYPE_NOTIFY_CREATE`: Detects new plist creation
  - `file.path`: Full path to .plist file
  - `process.executable.path`: Process that created the file
  - `process.audit_token.pid`: Creating process PID
  - `process.parent_audit_token.pid`: Parent process for lineage

- `ES_EVENT_TYPE_NOTIFY_WRITE`: Modifications to existing plists
  - `file.path`: Path to modified .plist
  - `process.executable.path`: Modifying process

- `ES_EVENT_TYPE_NOTIFY_EXEC`: launchctl execution
  - `process.executable.path`: Should be `/bin/launchctl`
  - `process.arguments`: Parse for `load`, `bootstrap`, `start`, `bootout`
  - `process.parent_audit_token.pid`: Check for suspicious parent

**Unified Logs (macOS system logs):**
```bash
# View launchd and launchctl activity
log show --predicate 'process == "launchd" OR process == "launchctl"' \
  --info --last 1h

# Filter for loading events
log show --predicate 'eventMessage CONTAINS "load" AND process == "launchctl"' \
  --info --last 24h
```

**File System Events (fsevents):**
- Monitor paths: `*/LaunchAgents/`, `*/LaunchDaemons/`
- Event types: Created, Modified

**Command line monitoring:**
```bash
# List all loaded LaunchAgents/Daemons
launchctl list

# Examine specific plist
launchctl print system/com.suspicious.agent
```

### Pseudocode Queries

**High Fidelity: New Plist Created in Monitored Directory**
```
event.type == "file_create" AND
file.path MATCHES "*/LaunchAgents/*.plist" OR 
file.path MATCHES "*/LaunchDaemons/*.plist"
```

**High Fidelity: Apple Plist Masquerading**
```
event.type == "file_create" AND
file.name MATCHES "com.apple.*.plist" AND
file.path NOT MATCHES "/System/Library/*"
```

**Medium Fidelity: Suspicious launchctl Execution**
```
event.type == "process_start" AND
process.name == "launchctl" AND
process.command_line MATCHES ".*(load|bootstrap|start).*" AND
process.parent.name NOT IN ["Terminal", "iTerm2", "Installer", "System Preferences"]
```

**Medium Fidelity: Plist with Obfuscated Content**
```
event.type == "file_create" AND
file.path MATCHES "*/Launch(Agents|Daemons)/*.plist" AND
file.content MATCHES ".*(base64|eval|curl|wget).*"
```

**Behavioral: Unusual Plist Modifications**
```
event.type == "file_write" AND
file.path MATCHES "*/Launch(Agents|Daemons)/*.plist" AND
process.name NOT IN ["Installer", "softwareupdate", "defaults", "plutil"]
```

### MITRE ATT&CK Mapping

| Tactic | Technique ID | Technique Name |
|--------|--------------|----------------|
| Persistence | T1543.001 | Create or Modify System Process: Launch Agent |
| Privilege Escalation | T1543.001 | Create or Modify System Process: Launch Agent |
| Persistence | T1543.004 | Create or Modify System Process: Launch Daemon |
| Privilege Escalation | T1543.004 | Create or Modify System Process: Launch Daemon |
```
