---
name: kql-mde-xdr
description: Write and optimize KQL queries for Microsoft Defender (MDE), Sentinel, and Microsoft 365 Defender XDR. Use when threat hunting, writing detection rules, investigating incidents, or analyzing security data with KQL.
refs:
  - references/*.md
---

# KQL and MDE XDR Expert

## Core Capabilities

1. **KQL Query Writing** - Craft optimized queries for security analysis
2. **Threat Hunting** - Proactive hunting queries for adversary techniques
3. **Detection Engineering** - Create detection rules and analytics
4. **Incident Investigation** - Investigate alerts and incidents
5. **Performance Optimization** - Optimize slow or inefficient queries

## MDE Tables Reference

**CRITICAL:** You MUST read the relevant reference files BEFORE writing any query. Do not rely on memory - always verify field names, ActionTypes, and table schemas from the reference documentation.

| File | Description |
| --- | --- |
| `references/alerts.md` | MS365D alert and behavior tables (AlertInfo, AlertEvidence, BehaviorInfo, BehaviorEntities) |
| `references/identity.md` | MDA/MDI identity and cloud app tables (AAD sign-in events, IdentityInfo, IdentityLogonEvents, IdentityQueryEvents, IdentityDirectoryEvents, CloudAppEvents) |
| `references/email.md` | MDO email security tables (EmailEvents, EmailAttachmentInfo, EmailUrlInfo, EmailPostDeliveryEvents, UrlClickEvents) |
| `references/devices-core.md` | Core MDE device tables (DeviceInfo, DeviceNetworkInfo, DeviceProcessEvents, DeviceNetworkEvents, DeviceFileEvents) |
| `references/devices-security.md` | Security-focused MDE tables (DeviceRegistryEvents, DeviceLogonEvents, DeviceImageLoadEvents, DeviceEvents, DeviceFileCertificateInfo) |
| `references/devices-linux-macos.md` | Linux and macOS platform-specific guidance, ActionTypes, and detection patterns |
| `references/tvm.md` | TVM vulnerability management tables (DeviceTvmSoftwareInventory, DeviceTvmSoftwareVulnerabilities, DeviceTvmSecureConfigurationAssessment, baseline compliance, browser extensions, hardware/firmware) |
| `references/hunting-ioc.md` | IOC hunting patterns (hash, IP, domain), process ancestry chains, behavioral anomalies, cross-table correlation |
| `references/hunting-mitre.md` | MITRE ATT&CK hunting queries (TA0001-TA0011: Initial Access through Exfiltration) |


## Query Writing Principles

### Use Native Fields First
Before using string manipulation functions like `split()`, `extract()`, or `parse()`, check if the data you need already exists as a native field in the table schema. For example:
- Use `FileName` directly instead of extracting from `FolderPath`
- Use `InitiatingProcessFileName` instead of parsing command lines
- Check `AdditionalFields` for structured data before regex parsing

### Focus on the Right Entity
When detecting suspicious activity, consider which entity matters most for detection:
- **Persistence detection**: Focus on `InitiatingProcess*` fields (what created/modified the persistence)
- **Malware detection**: Focus on the file/process itself (`FileName`, `FolderPath`)
- **Lateral movement**: Focus on source/remote fields


## KQL Fundamentals

### Query Structure

```kql
TableName
| where TimeGenerated > ago(24h)
| where <condition>
| project <columns>
| summarize <aggregation> by <grouping>
| order by <column> desc
```

### Essential Operators

| Operator | Purpose | Example |
|----------|---------|---------|
| `where` | Filter rows | `where ActionType == "ProcessCreated"` |
| `project` | Select columns | `project Timestamp, DeviceName, FileName` |
| `extend` | Add computed columns | `extend FileExt = tostring(split(FileName, ".")[-1])` |
| `summarize` | Aggregate data | `summarize count() by DeviceName` |
| `join` | Combine tables | `join kind=inner (Table2) on $left.Id == $right.Id` |
| `union` | Combine table rows | `union DeviceProcessEvents, DeviceFileEvents` |
| `parse` | Extract from strings | `parse CommandLine with * "/c " Command` |
| `mv-expand` | Expand arrays | `mv-expand parsed=parse_json(AdditionalFields)` |

### String Functions

```kql
// Case-insensitive contains
| where FileName contains "mimikatz"

// Case-sensitive contains
| where FileName contains_cs "Mimikatz"

// Starts/ends with
| where FileName startswith "cmd" or FileName endswith ".ps1"

// Regex matching
| where FileName matches regex @"(?i).*mimi.*"

// String extraction
| extend Domain = extract(@"https?://([^/]+)", 1, Url)
```

### Time Functions

```kql
// Relative time
| where Timestamp > ago(7d)
| where Timestamp between (ago(48h) .. ago(24h))

// Time binning
| summarize count() by bin(Timestamp, 1h)

// Time formatting
| extend Hour = datetime_part("hour", Timestamp)
```


## Query Optimization

### Performance Best Practices

1. **Filter early** - Use `where` clauses first to reduce dataset size
2. **Time bound** - Always include time filters
3. **Use `has` over `contains`** - `has` is faster for word boundaries
4. **Avoid `*` in project** - Select only needed columns
5. **Limit `join` scope** - Filter tables before joining

### Inefficient vs Optimized

```kql
// INEFFICIENT - late filtering, uses regex
DeviceProcessEvents
| project-away ReportId
| extend lower_cmd = tolower(ProcessCommandLine)
| where lower_cmd matches regex ".*mimikatz.*"

// OPTIMIZED - early filtering, uses has
DeviceProcessEvents
| where Timestamp > ago(24h)
| where ProcessCommandLine has "mimikatz"
| project Timestamp, DeviceName, FileName, ProcessCommandLine
```

### Materialize for Reuse

```kql
let suspiciousDevices = materialize(
    DeviceProcessEvents
    | where Timestamp > ago(1h)
    | where FileName =~ "powershell.exe"
    | where ProcessCommandLine has "-enc"
    | distinct DeviceId
);
DeviceFileEvents
| where DeviceId in (suspiciousDevices)
| where Timestamp > ago(1h)
```


## General Tips

- Use `let` statements for readability and reuse
- Test queries with `| take 100` before running full scope
- Use `render` for visualization: `| render timechart`
- Check schema with `TableName | getschema`
- Use `datatable` for inline reference lists
- Combine MITRE ATT&CK technique IDs in comments for documentation
