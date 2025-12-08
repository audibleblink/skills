# Threat Hunting - IOC & Behavioral Patterns

IOC hunting, process ancestry chains, and behavioral anomaly patterns for Microsoft Defender XDR.

---

## IOC Hunting

### Hunt by File Hash
```kql
let targetHash = "<SHA256 hash>";
union DeviceFileEvents, DeviceProcessEvents, DeviceImageLoadEvents
| where Timestamp > ago(30d)
| where SHA256 == targetHash or InitiatingProcessSHA256 == targetHash
| project Timestamp, DeviceName, FileName, FolderPath, ActionType,
    InitiatingProcessFileName, InitiatingProcessCommandLine
| order by Timestamp desc
```

### Hunt by IP Address
```kql
let targetIP = "<IP address>";
DeviceNetworkEvents
| where Timestamp > ago(30d)
| where RemoteIP == targetIP
| project Timestamp, DeviceName, RemoteIP, RemotePort, RemoteUrl,
    InitiatingProcessFileName, InitiatingProcessCommandLine
| summarize
    FirstSeen = min(Timestamp),
    LastSeen = max(Timestamp),
    ConnectionCount = count(),
    Devices = make_set(DeviceName)
    by InitiatingProcessFileName
```

### Hunt by Domain
```kql
let targetDomain = "<domain.com>";
DeviceNetworkEvents
| where Timestamp > ago(30d)
| where RemoteUrl has targetDomain
| project Timestamp, DeviceName, RemoteUrl, RemoteIP, RemotePort,
    InitiatingProcessFileName, InitiatingProcessCommandLine
| order by Timestamp desc
```

---

## Process Ancestry Chains

### Get Full Process Tree
```kql
let targetProcess = "<process name or hash>";
let timeWindow = 24h;
DeviceProcessEvents
| where Timestamp > ago(timeWindow)
| where FileName =~ targetProcess or SHA256 == targetProcess
| project
    Timestamp,
    DeviceName,
    // Child process
    ChildPID = ProcessId,
    ChildProcess = FileName,
    ChildCommandLine = ProcessCommandLine,
    // Parent process
    ParentPID = InitiatingProcessId,
    ParentProcess = InitiatingProcessFileName,
    ParentCommandLine = InitiatingProcessCommandLine,
    // Grandparent process
    GrandparentProcess = InitiatingProcessParentFileName,
    GrandparentPID = InitiatingProcessParentId,
    // User context
    AccountName
```

### Suspicious Process Chains
```kql
// Common malicious process chains
DeviceProcessEvents
| where Timestamp > ago(24h)
| where
    // Office spawning cmd/powershell
    (InitiatingProcessFileName in~ ("winword.exe", "excel.exe", "powerpnt.exe", "outlook.exe")
        and FileName in~ ("cmd.exe", "powershell.exe", "wscript.exe", "cscript.exe", "mshta.exe"))
    or
    // Browser spawning scripting engines
    (InitiatingProcessFileName in~ ("chrome.exe", "firefox.exe", "msedge.exe", "iexplore.exe")
        and FileName in~ ("cmd.exe", "powershell.exe", "wscript.exe"))
    or
    // Script hosts spawning network tools
    (InitiatingProcessFileName in~ ("wscript.exe", "cscript.exe", "mshta.exe")
        and FileName in~ ("powershell.exe", "cmd.exe", "curl.exe", "wget.exe", "bitsadmin.exe"))
| project Timestamp, DeviceName, AccountName,
    InitiatingProcessParentFileName, InitiatingProcessFileName, InitiatingProcessCommandLine,
    FileName, ProcessCommandLine
```

---

## Behavioral Anomaly Patterns

### First-Time Execution (Rare Process)
```kql
// Processes seen for the first time in environment
let lookbackDays = 30;
let recentDays = 1;
let historicalProcesses =
    DeviceProcessEvents
    | where Timestamp between (ago(lookbackDays) .. ago(recentDays))
    | summarize by SHA256;
DeviceProcessEvents
| where Timestamp > ago(recentDays)
| where SHA256 !in (historicalProcesses)
| summarize
    FirstSeen = min(Timestamp),
    DeviceCount = dcount(DeviceName),
    Devices = make_set(DeviceName, 5)
    by FileName, SHA256, FolderPath
| order by FirstSeen desc
```

### Unusual Parent-Child Relationships
```kql
// Parent processes that rarely spawn specific children
DeviceProcessEvents
| where Timestamp > ago(7d)
| summarize
    SpawnCount = count(),
    DeviceCount = dcount(DeviceName)
    by InitiatingProcessFileName, FileName
| where SpawnCount < 5 and DeviceCount == 1
| where InitiatingProcessFileName !in~ ("explorer.exe", "svchost.exe", "services.exe", "cmd.exe", "powershell.exe")
| order by SpawnCount asc
```

### Off-Hours Activity
```kql
// Process execution outside business hours
DeviceProcessEvents
| where Timestamp > ago(7d)
| extend Hour = datetime_part("hour", Timestamp)
| extend DayOfWeek = dayofweek(Timestamp)
| where (Hour < 6 or Hour > 22) or (DayOfWeek == 0d or DayOfWeek == 6d)
| where FileName in~ ("powershell.exe", "cmd.exe", "wmic.exe", "net.exe", "reg.exe")
| summarize
    OffHoursCount = count(),
    Commands = make_set(ProcessCommandLine, 10)
    by DeviceName, AccountName, FileName
| where OffHoursCount >= 5
```

---

## Cross-Table Correlation

### Email to Process Execution
```kql
// Track activity after opening email attachments
let suspiciousEmails =
    EmailAttachmentInfo
    | where Timestamp > ago(7d)
    | where ThreatTypes has_any ("Malware", "Phish")
    | project EmailTime = Timestamp, RecipientEmailAddress, SHA256, FileName;
let recipients = suspiciousEmails | distinct RecipientEmailAddress;
DeviceProcessEvents
| where Timestamp > ago(7d)
| where AccountName has_any (recipients)
| join kind=inner suspiciousEmails on SHA256
| where Timestamp between (EmailTime .. 1h)
| project EmailTime, Timestamp, RecipientEmailAddress, DeviceName,
    AttachmentName = FileName, ProcessFileName = FileName1, ProcessCommandLine
```

### Alert to Behavior Expansion
```kql
// Expand investigation from an alert
let alertedDevices =
    AlertEvidence
    | where Timestamp > ago(7d)
    | where Severity in ("High", "Critical")
    | distinct DeviceId;
DeviceProcessEvents
| where Timestamp > ago(7d)
| where DeviceId in (alertedDevices)
| where FileName in~ ("powershell.exe", "cmd.exe", "wmic.exe", "net.exe", "reg.exe", "schtasks.exe")
| project Timestamp, DeviceName, AccountName, FileName, ProcessCommandLine
| order by DeviceName, Timestamp
```
