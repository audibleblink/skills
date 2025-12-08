# Threat Hunting - MITRE ATT&CK Queries

MITRE ATT&CK technique hunting queries for Microsoft Defender XDR.

---

## Initial Access (TA0001)

### T1566.001 - Spearphishing Attachment
```kql
// Macro-enabled documents followed by suspicious child processes
let macroExtensions = dynamic([".docm", ".xlsm", ".pptm", ".dotm", ".xltm"]);
DeviceFileEvents
| where Timestamp > ago(7d)
| where ActionType == "FileCreated"
| where FileName has_any (macroExtensions)
| project FileCreatedTime = Timestamp, DeviceId, DeviceName, MacroFile = FileName, FolderPath
| join kind=inner (
    DeviceProcessEvents
    | where Timestamp > ago(7d)
    | where InitiatingProcessFileName in~ ("winword.exe", "excel.exe", "powerpnt.exe")
    | where FileName in~ ("cmd.exe", "powershell.exe", "wscript.exe", "cscript.exe", "mshta.exe", "certutil.exe")
) on DeviceId
| where Timestamp between (FileCreatedTime .. 10m)
| project FileCreatedTime, Timestamp, DeviceName, MacroFile,
    InitiatingProcessFileName, FileName, ProcessCommandLine
```

---

## Execution (TA0002)

### T1059.001 - PowerShell
```kql
// Encoded PowerShell commands
DeviceProcessEvents
| where Timestamp > ago(24h)
| where FileName =~ "powershell.exe" or FileName =~ "pwsh.exe"
| where ProcessCommandLine has_any ("-enc", "-ec", "-encodedcommand", "-e ")
    or ProcessCommandLine has "FromBase64String"
    or ProcessCommandLine has "IEX"
    or ProcessCommandLine has "Invoke-Expression"
| project Timestamp, DeviceName, AccountName,
    InitiatingProcessFileName, ProcessCommandLine
| extend DecodedHint = extract(@"-e[nc]* ([A-Za-z0-9+/=]{20,})", 1, ProcessCommandLine)
```

### T1059.003 - Windows Command Shell
```kql
// Suspicious cmd.exe usage
DeviceProcessEvents
| where Timestamp > ago(24h)
| where FileName =~ "cmd.exe"
| where ProcessCommandLine has_any (
    "curl", "wget", "certutil -urlcache", "bitsadmin /transfer",
    "powershell", "wscript", "cscript", "mshta",
    "reg add", "reg delete", "schtasks /create"
)
| project Timestamp, DeviceName, AccountName,
    InitiatingProcessFileName, InitiatingProcessCommandLine,
    ProcessCommandLine
```

### T1047 - WMI Execution
```kql
DeviceProcessEvents
| where Timestamp > ago(24h)
| where FileName =~ "wmic.exe"
    or (FileName =~ "powershell.exe" and ProcessCommandLine has "Get-WmiObject")
    or (FileName =~ "powershell.exe" and ProcessCommandLine has "Invoke-WmiMethod")
| where ProcessCommandLine has_any ("process call create", "node:", "/node:")
| project Timestamp, DeviceName, AccountName,
    InitiatingProcessFileName, ProcessCommandLine
```

---

## Persistence (TA0003)

### T1053.005 - Scheduled Task
```kql
// Scheduled task creation
DeviceEvents
| where Timestamp > ago(7d)
| where ActionType in ("ScheduledTaskCreated", "ScheduledTaskUpdated")
| extend TaskDetails = parse_json(AdditionalFields)
| project Timestamp, DeviceName, ActionType,
    TaskName = TaskDetails.TaskName,
    TaskContent = TaskDetails.TaskContent,
    InitiatingProcessFileName, InitiatingProcessCommandLine, AccountName
```

### T1547.001 - Registry Run Keys
```kql
// Run key persistence
DeviceRegistryEvents
| where Timestamp > ago(7d)
| where ActionType == "RegistryValueSet"
| where RegistryKey has_any (
    @"\CurrentVersion\Run",
    @"\CurrentVersion\RunOnce",
    @"\CurrentVersion\RunServices",
    @"\CurrentVersion\RunServicesOnce",
    @"\Explorer\Shell Folders",
    @"\Explorer\User Shell Folders"
)
| project Timestamp, DeviceName, RegistryKey, RegistryValueName, RegistryValueData,
    InitiatingProcessFileName, InitiatingProcessCommandLine, AccountName
```

### T1543.003 - Windows Service
```kql
// Service installation
DeviceEvents
| where Timestamp > ago(7d)
| where ActionType == "ServiceInstalled"
| extend ServiceDetails = parse_json(AdditionalFields)
| project Timestamp, DeviceName,
    ServiceName = ServiceDetails.ServiceName,
    ServiceType = ServiceDetails.ServiceType,
    ServiceStartType = ServiceDetails.ServiceStartType,
    ServiceAccount = ServiceDetails.ServiceAccount,
    InitiatingProcessFileName, InitiatingProcessCommandLine
```

---

## Privilege Escalation (TA0004)

### T1548.002 - UAC Bypass
```kql
// Common UAC bypass techniques
DeviceProcessEvents
| where Timestamp > ago(24h)
| where
    // fodhelper bypass
    (InitiatingProcessFileName =~ "fodhelper.exe" and FileName in~ ("cmd.exe", "powershell.exe"))
    or
    // eventvwr bypass
    (InitiatingProcessFileName =~ "eventvwr.exe" and FileName in~ ("cmd.exe", "powershell.exe"))
    or
    // sdclt bypass
    (InitiatingProcessFileName =~ "sdclt.exe" and FileName in~ ("cmd.exe", "powershell.exe"))
    or
    // computerdefaults bypass
    (InitiatingProcessFileName =~ "computerdefaults.exe" and FileName in~ ("cmd.exe", "powershell.exe"))
| project Timestamp, DeviceName, AccountName,
    InitiatingProcessFileName, FileName, ProcessCommandLine
```

---

## Defense Evasion (TA0005)

### T1562.001 - Disable Security Tools
```kql
// Attempts to disable Windows Defender
union DeviceProcessEvents, DeviceRegistryEvents
| where Timestamp > ago(7d)
| where
    // PowerShell commands to disable Defender
    (ProcessCommandLine has "Set-MpPreference" and ProcessCommandLine has_any ("DisableRealtimeMonitoring", "DisableBehaviorMonitoring", "DisableScriptScanning"))
    or
    // Registry modifications to disable Defender
    (RegistryKey has @"Windows Defender" and RegistryValueName has_any ("DisableRealtimeMonitoring", "DisableAntiSpyware", "DisableBehaviorMonitoring"))
    or
    // Stopping Defender service
    (ProcessCommandLine has_any ("Stop-Service WinDefend", "sc stop WinDefend", "net stop WinDefend"))
| project Timestamp, DeviceName, ActionType,
    ProcessCommandLine, RegistryKey, RegistryValueName, RegistryValueData
```

### T1070.001 - Clear Windows Event Logs
```kql
DeviceProcessEvents
| where Timestamp > ago(7d)
| where
    (FileName =~ "wevtutil.exe" and ProcessCommandLine has_any ("cl", "clear-log"))
    or
    (FileName =~ "powershell.exe" and ProcessCommandLine has "Clear-EventLog")
    or
    (ProcessCommandLine has "wmic" and ProcessCommandLine has "cleareventlog")
| project Timestamp, DeviceName, AccountName,
    InitiatingProcessFileName, FileName, ProcessCommandLine
```

---

## Credential Access (TA0006)

### T1003.001 - LSASS Memory Dumping
```kql
// LSASS access attempts
DeviceEvents
| where Timestamp > ago(24h)
| where ActionType == "OpenProcessApiCall"
| where FileName =~ "lsass.exe"
| where InitiatingProcessFileName !in~ ("svchost.exe", "lsass.exe", "MsMpEng.exe", "csrss.exe")
| project Timestamp, DeviceName, AccountName,
    InitiatingProcessFileName, InitiatingProcessCommandLine,
    FileName
```

### T1003.003 - NTDS.dit Access
```kql
// Attempts to access or copy NTDS.dit
DeviceFileEvents
| where Timestamp > ago(7d)
| where FileName =~ "ntds.dit" or FolderPath has @"\Windows\NTDS"
| where ActionType in ("FileCreated", "FileModified", "FileRenamed")
| project Timestamp, DeviceName, ActionType, FileName, FolderPath,
    InitiatingProcessFileName, InitiatingProcessCommandLine
```

---

## Discovery (TA0007)

### T1087 - Account Discovery
```kql
// Account enumeration commands
DeviceProcessEvents
| where Timestamp > ago(24h)
| where
    (FileName =~ "net.exe" and ProcessCommandLine has_any ("user", "group", "localgroup"))
    or
    (FileName =~ "net1.exe" and ProcessCommandLine has_any ("user", "group", "localgroup"))
    or
    (FileName =~ "whoami.exe")
    or
    (FileName =~ "cmdkey.exe" and ProcessCommandLine has "/list")
    or
    (ProcessCommandLine has "Get-ADUser" or ProcessCommandLine has "Get-ADGroup")
| summarize
    CommandCount = count(),
    Commands = make_set(ProcessCommandLine)
    by DeviceName, AccountName, bin(Timestamp, 1h)
| where CommandCount >= 3
```

### T1018 - Remote System Discovery
```kql
// Network scanning and enumeration
DeviceProcessEvents
| where Timestamp > ago(24h)
| where
    (FileName =~ "arp.exe" and ProcessCommandLine has "-a")
    or
    (FileName in~ ("ping.exe", "nslookup.exe") and ProcessCommandLine matches regex @"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")
    or
    (FileName =~ "net.exe" and ProcessCommandLine has "view")
    or
    (ProcessCommandLine has "Test-NetConnection")
    or
    (FileName =~ "nltest.exe")
| summarize
    ScanCount = count(),
    TargetsScanned = make_set(extract(@"(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})", 1, ProcessCommandLine))
    by DeviceName, AccountName, bin(Timestamp, 1h)
| where ScanCount >= 5
```

---

## Lateral Movement (TA0008)

### T1021.001 - Remote Desktop Protocol
```kql
// Suspicious RDP connections
DeviceLogonEvents
| where Timestamp > ago(7d)
| where LogonType == "RemoteInteractive"
| where ActionType == "LogonSuccess"
| summarize
    FirstLogon = min(Timestamp),
    LastLogon = max(Timestamp),
    LogonCount = count(),
    SourceIPs = make_set(RemoteIP),
    SourceDevices = make_set(RemoteDeviceName)
    by DeviceName, AccountName
| where LogonCount >= 3 or array_length(SourceIPs) >= 3
```

### T1021.002 - SMB/Windows Admin Shares
```kql
// Lateral movement via SMB
DeviceNetworkEvents
| where Timestamp > ago(24h)
| where RemotePort == 445
| where ActionType == "ConnectionSuccess"
| where LocalIPType == "Private" and RemoteIPType == "Private"
| summarize
    ConnectionCount = count(),
    UniqueDestinations = dcount(RemoteIP),
    Destinations = make_set(RemoteIP)
    by DeviceName, InitiatingProcessFileName, bin(Timestamp, 1h)
| where ConnectionCount >= 5 or UniqueDestinations >= 3
```

### T1047 - WMI Lateral Movement
```kql
// Remote WMI execution
DeviceProcessEvents
| where Timestamp > ago(24h)
| where FileName =~ "wmic.exe"
| where ProcessCommandLine has "/node:"
| extend TargetNode = extract(@"/node:[\""]?([^\s\""]+)", 1, ProcessCommandLine)
| project Timestamp, DeviceName, AccountName, TargetNode, ProcessCommandLine
```

---

## Collection (TA0009)

### T1560 - Archive Collected Data
```kql
// Archiving sensitive data
DeviceProcessEvents
| where Timestamp > ago(7d)
| where FileName in~ ("7z.exe", "7za.exe", "rar.exe", "winrar.exe", "zip.exe", "tar.exe")
    or (FileName =~ "powershell.exe" and ProcessCommandLine has "Compress-Archive")
| where ProcessCommandLine has_any (".doc", ".xls", ".pdf", ".pst", ".db", "password", "credential", "secret", "confidential")
| project Timestamp, DeviceName, AccountName, FileName, ProcessCommandLine
```

---

## Command and Control (TA0011)

### T1071.001 - Web Protocols
```kql
// Unusual HTTP/HTTPS connections
let trustedDomains = dynamic(["microsoft.com", "windows.com", "office.com", "azure.com"]);
DeviceNetworkEvents
| where Timestamp > ago(24h)
| where RemotePort in (80, 443, 8080, 8443)
| where ActionType == "ConnectionSuccess"
| where RemoteUrl !has_any (trustedDomains)
| where InitiatingProcessFileName in~ ("powershell.exe", "cmd.exe", "wscript.exe", "cscript.exe", "mshta.exe", "rundll32.exe")
| summarize
    ConnectionCount = count(),
    BytesSent = sum(tolong(AdditionalFields.BytesSent)),
    Destinations = make_set(RemoteUrl)
    by DeviceName, InitiatingProcessFileName, bin(Timestamp, 1h)
| where ConnectionCount >= 10
```

### T1572 - Protocol Tunneling (DNS)
```kql
// DNS tunneling indicators
DeviceNetworkEvents
| where Timestamp > ago(24h)
| where RemotePort == 53
| extend QueryLength = strlen(RemoteUrl)
| where QueryLength > 50  // Long DNS queries may indicate tunneling
| summarize
    QueryCount = count(),
    AvgQueryLength = avg(QueryLength),
    UniqueQueries = dcount(RemoteUrl)
    by DeviceName, RemoteIP, bin(Timestamp, 1h)
| where QueryCount >= 100 or AvgQueryLength > 60
```

---

## Exfiltration (TA0010)

### T1567 - Exfiltration Over Web Service
```kql
// Large uploads to cloud services
let cloudServices = dynamic(["dropbox.com", "drive.google.com", "onedrive.live.com", "mega.nz", "wetransfer.com", "pastebin.com"]);
DeviceNetworkEvents
| where Timestamp > ago(7d)
| where RemoteUrl has_any (cloudServices)
| extend BytesSent = tolong(parse_json(AdditionalFields).BytesSent)
| where BytesSent > 10000000  // > 10 MB
| project Timestamp, DeviceName, AccountName = InitiatingProcessAccountName,
    RemoteUrl, BytesSent, InitiatingProcessFileName
```
