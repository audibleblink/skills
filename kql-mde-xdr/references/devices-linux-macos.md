# MDE - Linux and macOS Platform Guidance

Platform-specific guidance for Linux and macOS devices in Microsoft Defender for Endpoint.

---

## CRITICAL: macOS Plist Queries

**NEVER use `DeviceFileEvents` for plist queries on macOS** - this table does NOT contain plist modification events.

**ALWAYS use:**
```kql
DeviceEvents
| where ActionType == "PlistPropertyModified"
```

---

## Platform Filtering

**IMPORTANT:** `OSPlatform` only exists in `DeviceInfo`, NOT in other Device* tables.

To filter any Device* table to macOS or Linux devices, you MUST use a let statement with DeviceInfo:

### macOS Platform Filtering
```kql
let macOSDevices =
    DeviceInfo
    | where OSPlatform == "macOS"
    | distinct DeviceId;
DeviceEvents  // or DeviceProcessEvents, DeviceFileEvents, etc.
| where DeviceId in (macOSDevices)
| where Timestamp > ago(24h)
// ... rest of query
```

### Linux Platform Filtering
```kql
let linuxDevices =
    DeviceInfo
    | where OSPlatform == "Linux"
    | distinct DeviceId;
DeviceProcessEvents
| where DeviceId in (linuxDevices)
| where Timestamp > ago(24h)
// ... rest of query
```

**NEVER do this** (OSPlatform doesn't exist in these tables):
```kql
// WRONG - will fail or return no results
DeviceEvents
| where OSPlatform == "macOS"
```

---

## Linux-Specific Guidance

### Linux File Paths

Linux uses forward slashes and has different critical paths:

```kql
// Persistence locations
let linuxPersistencePaths = dynamic([
    "/etc/cron",
    "/etc/init.d",
    "/etc/systemd",
    "/lib/systemd",
    "/usr/lib/systemd",
    "/.bashrc",
    "/.bash_profile",
    "/.profile",
    "/etc/profile.d",
    "/etc/rc.local"
]);

// Binary locations
let linuxBinPaths = dynamic([
    "/bin/",
    "/sbin/",
    "/usr/bin/",
    "/usr/sbin/",
    "/usr/local/bin/",
    "/tmp/",
    "/var/tmp/",
    "/dev/shm/"
]);
```

### Linux-Specific ActionTypes in DeviceEvents

| ActionType | Description |
| --- | --- |
| **CronJobCreated** | A cron job was created or modified |
| **SystemdUnitModified** | A systemd service unit was modified |
| **SudoersFileModified** | The sudoers file was modified |
| **PasswdFileModified** | The passwd file was modified |
| **ShadowFileModified** | The shadow file was modified |

### Linux Persistence Detection

#### Cron Job Persistence
```kql
let linuxDevices =
    DeviceInfo
    | where OSPlatform == "Linux"
    | distinct DeviceId;
DeviceEvents
| where DeviceId in (linuxDevices)
| where Timestamp > ago(7d)
| where ActionType == "CronJobCreated"
| extend CronDetails = parse_json(AdditionalFields)
| project Timestamp, DeviceName, ActionType,
    CronUser = CronDetails.User,
    CronSchedule = CronDetails.Schedule,
    CronCommand = CronDetails.Command,
    InitiatingProcessFileName, InitiatingProcessCommandLine
```

#### Systemd Service Persistence
```kql
let linuxDevices =
    DeviceInfo
    | where OSPlatform == "Linux"
    | distinct DeviceId;
DeviceFileEvents
| where DeviceId in (linuxDevices)
| where Timestamp > ago(7d)
| where FolderPath has_any ("/etc/systemd/system", "/lib/systemd/system", "/usr/lib/systemd/system")
| where FileName endswith ".service" or FileName endswith ".timer"
| project Timestamp, DeviceName, ActionType, FileName, FolderPath,
    InitiatingProcessFileName, InitiatingProcessCommandLine
```

#### SSH Authorized Keys Modification
```kql
let linuxDevices =
    DeviceInfo
    | where OSPlatform == "Linux"
    | distinct DeviceId;
DeviceFileEvents
| where DeviceId in (linuxDevices)
| where Timestamp > ago(7d)
| where FileName == "authorized_keys" or FolderPath has ".ssh"
| where ActionType in ("FileCreated", "FileModified")
| project Timestamp, DeviceName, ActionType, FileName, FolderPath,
    InitiatingProcessFileName, InitiatingProcessCommandLine, AccountName
```

### Linux Privilege Escalation Detection

#### Sudo/Su Usage
```kql
let linuxDevices =
    DeviceInfo
    | where OSPlatform == "Linux"
    | distinct DeviceId;
DeviceProcessEvents
| where DeviceId in (linuxDevices)
| where Timestamp > ago(24h)
| where FileName in~ ("sudo", "su", "pkexec", "doas")
| project Timestamp, DeviceName, AccountName,
    FileName, ProcessCommandLine,
    InitiatingProcessFileName, InitiatingProcessCommandLine
```

#### SUID Binary Execution
```kql
let linuxDevices =
    DeviceInfo
    | where OSPlatform == "Linux"
    | distinct DeviceId;
DeviceProcessEvents
| where DeviceId in (linuxDevices)
| where Timestamp > ago(24h)
// Look for common SUID binaries used in privilege escalation
| where FileName in~ ("nmap", "vim", "find", "bash", "less", "more", "nano", "cp", "mv", "awk", "python", "python3", "perl", "ruby")
| where ProcessCommandLine has_any ("--interactive", "-p", "!/bin", "os.system", "subprocess")
| project Timestamp, DeviceName, AccountName, FileName, ProcessCommandLine
```

### Linux Command Execution Detection

#### Reverse Shell Detection
```kql
let linuxDevices =
    DeviceInfo
    | where OSPlatform == "Linux"
    | distinct DeviceId;
DeviceProcessEvents
| where DeviceId in (linuxDevices)
| where Timestamp > ago(24h)
| where
    // Bash reverse shell patterns
    (ProcessCommandLine has "/dev/tcp/" or ProcessCommandLine has "/dev/udp/")
    or
    // Python reverse shells
    (FileName in~ ("python", "python3") and ProcessCommandLine has_any ("socket", "subprocess", "pty.spawn"))
    or
    // Netcat reverse shells
    (FileName in~ ("nc", "ncat", "netcat") and ProcessCommandLine has_any ("-e", "-c"))
    or
    // Perl reverse shells
    (FileName == "perl" and ProcessCommandLine has "socket")
| project Timestamp, DeviceName, AccountName, FileName, ProcessCommandLine,
    InitiatingProcessFileName, InitiatingProcessCommandLine
```

#### Suspicious Download and Execute
```kql
let linuxDevices =
    DeviceInfo
    | where OSPlatform == "Linux"
    | distinct DeviceId;
DeviceProcessEvents
| where DeviceId in (linuxDevices)
| where Timestamp > ago(24h)
| where
    // curl/wget piped to shell
    (ProcessCommandLine has_any ("curl", "wget") and ProcessCommandLine has_any ("| bash", "| sh", "|bash", "|sh"))
    or
    // Download to /tmp and execute
    (FileName in~ ("curl", "wget") and ProcessCommandLine has "/tmp/")
| project Timestamp, DeviceName, AccountName, FileName, ProcessCommandLine,
    InitiatingProcessFileName
```

### Linux Network Detection

#### Suspicious Outbound Connections
```kql
let linuxDevices =
    DeviceInfo
    | where OSPlatform == "Linux"
    | distinct DeviceId;
DeviceNetworkEvents
| where DeviceId in (linuxDevices)
| where Timestamp > ago(24h)
| where ActionType == "ConnectionSuccess"
| where InitiatingProcessFileName in~ ("bash", "sh", "python", "python3", "perl", "ruby", "nc", "ncat")
| where RemoteIPType == "Public"
| project Timestamp, DeviceName, RemoteIP, RemotePort, RemoteUrl,
    InitiatingProcessFileName, InitiatingProcessCommandLine
```

---

## macOS-Specific Guidance

### macOS Persistence via LaunchAgents/LaunchDaemons

**CRITICAL:** Use `DeviceEvents` with `ActionType == "PlistPropertyModified"` - NOT `DeviceFileEvents`.

```kql
let macOSDevices =
    DeviceInfo
    | where OSPlatform == "macOS"
    | distinct DeviceId;
DeviceEvents
| where DeviceId in (macOSDevices)
| where Timestamp > ago(7d)
| where ActionType == "PlistPropertyModified"
| extend PlistDetails = parse_json(AdditionalFields)
| where PlistDetails.FileName has_any ("LaunchAgents", "LaunchDaemons")
| project Timestamp, DeviceName, ActionType,
    PlistPath = PlistDetails.FileName,
    PropertyName = PlistDetails.PropertyName,
    PropertyValue = PlistDetails.PropertyValue,
    InitiatingProcessFileName, InitiatingProcessCommandLine
```

### macOS Process Execution from Unusual Locations
```kql
let macOSDevices =
    DeviceInfo
    | where OSPlatform == "macOS"
    | distinct DeviceId;
DeviceProcessEvents
| where DeviceId in (macOSDevices)
| where Timestamp > ago(24h)
| where FolderPath has_any ("/tmp/", "/var/tmp/", "/private/tmp/", "/Users/Shared/")
| project Timestamp, DeviceName, AccountName,
    FileName, FolderPath, ProcessCommandLine,
    InitiatingProcessFileName
```

### macOS Script Execution
```kql
let macOSDevices =
    DeviceInfo
    | where OSPlatform == "macOS"
    | distinct DeviceId;
DeviceProcessEvents
| where DeviceId in (macOSDevices)
| where Timestamp > ago(24h)
| where FileName in~ ("osascript", "bash", "sh", "zsh", "python", "python3", "perl", "ruby")
| where ProcessCommandLine has_any ("-e", "-c", "curl", "wget", "base64")
| project Timestamp, DeviceName, AccountName,
    FileName, ProcessCommandLine,
    InitiatingProcessFileName, InitiatingProcessCommandLine
```

### macOS Keychain Access
```kql
let macOSDevices =
    DeviceInfo
    | where OSPlatform == "macOS"
    | distinct DeviceId;
DeviceProcessEvents
| where DeviceId in (macOSDevices)
| where Timestamp > ago(24h)
| where FileName == "security"
| where ProcessCommandLine has_any ("dump-keychain", "find-generic-password", "find-internet-password")
| project Timestamp, DeviceName, AccountName,
    ProcessCommandLine,
    InitiatingProcessFileName, InitiatingProcessCommandLine
```
