# Threat Model Outline

This serves as a template for individual attack phases of a kill chain


```typst
= {{ attack_phase }}
== {{ technique_name }}
=== Technique Overview
{{ a first principles explanation of the technique }}
=== Attack Steps
{{ step an attack might take to perform this attack }}
=== Detection Opportunities
{{ general explanation of what one might look for / evidence that an attack leaves }}
=== Data Sources & Log Fields
{{ specific log sources and artifacts, both local and remote }}
=== Psuedocode Queries
{{ generic, product-agnostic, UDM style SIEM/EDR queries }}
=== MITRE ATT&CK Mapping
```



## Example Typst Outline Usage

```typst
= Persistence
== Create or Modify System Process: LaunchAgent / LaunchDaemon
=== Technique Overview
Persistence via LaunchAgents and LaunchDaemons is the most common and
well-documented persistence mechanism on macOS. `launchd` is the operating
system's init process, responsible for managing services.

- *LaunchDaemons (T1543.004)*: These are system-level services. Their
  configuration .plist (property list) files are stored in
  `/Library/LaunchDaemons/`, execute at system startup, and run as root. This
  technique provides persistence and privilege escalation.
- *LaunchAgents (T1543.001)*: These are user-level services. Their .plist files
  are stored in `~/Library/LaunchAgents/` (for a specific user) or
  `/Library/LaunchAgents/` (for all users). They are executed when the user
  logs in and run with that user's privileges.

=== Attack Steps

1. *Create Plist*: An adversary crafts a .plist file
2. *Plist Content*: The .plist is an XML file containing key-value pairs. The
  most important for persistence are Label (the unique job name),
  ProgramArguments (an array of strings defining the command and arguments to
  execute), and RunAtLoad (a boolean set to true to execute the job as soon as
  it's loaded)
3. *Drop Plist*: The adversary drops this file into one of the three monitored
  locations (User `~/Library/LaunchAgents/`, System `/Library/LaunchAgents/`,
  or System `/Library/LaunchDaemons/`)
4. *Load Plist*: The persistence will be loaded automatically on the next login
  (for LaunchAgents) or reboot (for LaunchDaemons). Adversaries can trigger it
  immediately by executing `launchctl load -w /path/to/com.evil.plist`

Example minimal plist:
\`\`\`xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.agent</string>
    <key>ProgramArguments</key>
    <array>
        <string>osascript</string>
        <string>/path/to/payload.js</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
\`\`\

=== Detection Opportunities

- *File Monitoring (High Fidelity)*: The creation of any new file in the
  LaunchAgent or LaunchDaemon directories is a high-priority event. This is
  a perfect use case for a detection rule based on ESF's
  ES_EVENT_TYPE_NOTIFY_CREATE event
- *Masquerading*: Attackers frequently name their malicious plists to look
  legitimate, such as `com.apple.jptest.plist` or
  `com.apple.GrowlHelper.plist`. A very high-fidelity detection can be built to
  flag the creation of any .plist file with a `com.apple.*` naming convention
  in the user or system-level directories. Apple's native plists reside in
  `/System/Library/`, not `~/Library/` or `/Library/`
- *Process Monitoring*: Monitor for `launchctl` execution with the load
  argument, especially from an anomalous parent process

=== Data Sources & Log Fields

*Endpoint Security Framework (ESF):*

- `ES_EVENT_TYPE_NOTIFY_CREATE`: New plist creation
  - File path: `*/LaunchAgents/*.plist`, `*/LaunchDaemons/*.plist`
  - Creating process: Track what created the file

- `ES_EVENT_TYPE_NOTIFY_WRITE`: Modifications to existing plists
  - File path: LaunchAgent/Daemon locations

- `ES_EVENT_TYPE_NOTIFY_EXEC`: launchctl execution
  - Process: `/bin/launchctl`
  - Arguments: `load`, `unload`, `start`, `bootstrap`, `bootout`
  - Parse plist path from arguments

- `ES_EVENT_TYPE_NOTIFY_EXEC`: Processes started by launchd
  - Parent PID: 1 (launchd)
  - Look for unusual programs with PPID 1

*Unified Logs:*
\`\`\`bash
log show --predicate 'process == "launchd" OR process == "launchctl"' --info --last 1h
log show --predicate 'eventMessage CONTAINS "LaunchAgents" OR eventMessage CONTAINS "LaunchDaemons"' --info
`\`\`\

*File System:*
\`\`\`bash
# List all user Launch Agents
ls -la ~/Library/LaunchAgents/
ls -la /Library/LaunchAgents/

# List loaded agents for user
launchctl list

# Get detailed plist info
launchctl print gui/$(id -u)/com.example.agent
\`\`\`

=== Psuedocode Queries

*Plist File Create in Monitored Directory:*
```
event.type == "file_create" AND file.path IN ["*/LaunchAgents/*.plist", "*/LaunchDaemons/*.plist"]
```

*Apple Plist Masquerading - High Fidelity:*
```
event.type == "file_create" AND file.name MATCHES "com.apple.*.plist" AND
file.path NOT MATCHES "/System/*"
```

*Process Load:*
```
process.name == "launchctl" AND command_line.contains("load")
```

=== Known Bypasses

- *Legitimate Naming*: Using plausible-sounding names that mimic uninstalled third-party software (e.g., `com.google.updater.plist`)
- *TCC Bypass*: Malware like #link(<xcsset>)[XCSSET] has used TCC bypass vulnerabilities to gain Full Disk Access, allowing it to drop its persistence files without triggering a user prompt

=== MITRE ATT&CK Mapping

#table(
  columns: 3,
  stroke: 0.5pt,
  fill: (col, row) => if row == 0 { luma(240) },
  align: (left, left, left),
  [*Tactic*], [*Technique ID*], [*Technique Name*],
  [Persistence], [T1543.001], [Create or Modify System Process: Launch Agent],
  [Privilege Escalation],
  [T1543.001],
  [Create or Modify System Process: Launch Agent],
)

```
