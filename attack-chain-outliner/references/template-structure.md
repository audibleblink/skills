# Attack Chain Documentation Template Structure

This reference provides detailed guidance on each section of the attack chain documentation template.

## Table of Contents

1. Attack Phase (Level 1 Heading)
2. Technique Name (Level 2 Heading)
3. Technique Overview
4. Attack Steps
5. Detection Opportunities
6. Data Sources & Log Fields
7. Pseudocode Queries
8. MITRE ATT&CK Mapping

---

## 1. Attack Phase (Level 1 Heading)

The kill chain phase or tactical category from the MITRE ATT&CK framework.

**Common phases:**
- Initial Access
- Execution
- Persistence
- Privilege Escalation
- Defense Evasion
- Credential Access
- Discovery
- Lateral Movement
- Collection
- Command and Control
- Exfiltration
- Impact

**Format:**
```
= Persistence
```

---

## 2. Technique Name (Level 2 Heading)

Specific technique within the phase, ideally matching MITRE ATT&CK naming conventions.

**Guidelines:**
- Use official MITRE ATT&CK technique names when applicable
- Include sub-technique details in the name if relevant
- Be specific enough to differentiate from related techniques

**Format:**
```
== Create or Modify System Process: LaunchAgent / LaunchDaemon
```

---

## 3. Technique Overview

First principles explanation of how the technique works.

**Required content:**
- Technical explanation of the mechanism
- Why adversaries use this technique
- Prerequisites and requirements
- Privileges required
- Platform-specific details (Windows, macOS, Linux)

**Writing style:**
- Clear and technical but accessible
- Explain the "why" not just the "what"
- Include relevant background on system components
- Note variations across platforms/versions

**Example structure:**
```
=== Technique Overview

[Opening paragraph explaining what the technique is]

[Technical details about how it works]

- *Variant 1*: Description of first variant
- *Variant 2*: Description of second variant

[Additional context about prerequisites, privileges, or platform specifics]
```

---

## 4. Attack Steps

Step-by-step walkthrough of how an adversary executes the technique.

**Required content:**
- Numbered sequential steps
- Commands or code examples where relevant
- File locations, registry keys, API calls
- Configuration details
- Expected outcomes at each step

**Guidelines:**
- Be concrete and actionable
- Show actual commands/code when applicable
- Explain what each step accomplishes
- Note optional vs required steps
- Include realistic file paths and names

**Format:**
```
=== Attack Steps

1. *Step Name*: Description of what happens in this step

2. *Next Step*: Further detail with technical specifics
   - Sub-detail if needed
   - Additional context

3. *Configuration*: Show actual config/code
   
Example [language]:
\`\`\`language
actual code example
\`\`\`

4. *Execution*: How the technique is triggered
```

---

## 5. Detection Opportunities

High-level detection strategies and what defenders should look for.

**Required content:**
- Detection methods (file monitoring, process monitoring, network analysis, etc.)
- Fidelity assessment (high/medium/low) for each method
- Specific indicators or anomalies to watch for
- Known evasion techniques
- False positive considerations

**Fidelity levels:**
- **High**: Rarely produces false positives, strong indicator of malicious activity
- **Medium**: May have some legitimate use cases, requires additional context
- **Low**: Common in normal operations, high false positive rate

**Format:**
```
=== Detection Opportunities

- *Detection Method 1 (High Fidelity)*: What to detect and why it's high fidelity
  
- *Detection Method 2 (Medium Fidelity)*: What to detect and legitimate use cases
  
- *Evasion Technique*: How attackers bypass detection and counter-measures

- *False Positives*: Legitimate scenarios that may trigger alerts
```

---

## 6. Data Sources & Log Fields

Specific technical data sources and log fields for detection implementation.

**Required content:**
- Security product event types (EDR, SIEM, OS logs)
- Specific log fields to collect and analyze
- File paths, registry keys, or other artifacts
- Command-line examples for accessing logs
- Platform-specific logging mechanisms

**Common data sources:**
- **Windows**: Sysmon, Windows Event Logs, ETW, Registry monitoring
- **macOS**: Endpoint Security Framework (ESF), Unified Logs, fsevents
- **Linux**: auditd, syslog, ebpf, process accounting
- **Network**: DNS logs, proxy logs, firewall logs, NetFlow
- **EDR/XDR**: CrowdStrike, SentinelOne, Microsoft Defender, Carbon Black

**Format:**
```
=== Data Sources & Log Fields

*Data Source Name:*

- `EVENT_TYPE`: Description of event
  - Field 1: What to look for in this field
  - Field 2: Additional relevant field
  - Field 3: Context field

*Another Data Source:*

- `EVENT_TYPE`: Description
  - Field: Details

*Command-line access:*
\`\`\`bash
command to query logs
\`\`\`

*File paths to monitor:*
- `/path/to/monitor/*`
- `C:\Windows\Path\*`
```

---

## 7. Pseudocode Queries

Generic, product-agnostic detection logic using UDM (Unified Data Model) style syntax.

**Required content:**
- Named detection rules with descriptive names
- Platform-agnostic query syntax
- Clear logic operators (AND, OR, IN, MATCHES, NOT, etc.)
- Comments explaining complex logic
- Multiple variants for different scenarios

**Query style guidelines:**
- Use generic field names (event.type, process.name, file.path, etc.)
- Avoid vendor-specific syntax
- Make logic explicit and readable
- Include wildcards and regex patterns where appropriate
- Show both broad and narrow detection variants

**Common field conventions:**
- `event.type` - Type of event (file_create, process_start, network_connection)
- `process.name` - Process executable name
- `process.command_line` - Full command line
- `process.parent.name` - Parent process name
- `file.path` - Full file path
- `file.name` - File name only
- `user.name` - Username
- `network.destination.ip` - Destination IP address
- `registry.path` - Registry key path

**Format:**
```
=== Psuedocode Queries

*High Fidelity: Descriptive Rule Name*
\`\`\`
event.type == "file_create" AND 
file.path MATCHES "*/suspicious/location/*" AND
process.name NOT IN ["legitimate.exe", "allowed.exe"]
\`\`\`

*Medium Fidelity: Another Detection*
\`\`\`
process.name == "cmd.exe" AND
process.command_line MATCHES ".*encoded.*" AND
process.parent.name NOT IN ["explorer.exe", "services.exe"]
\`\`\`

*Behavioral: Anomaly Detection*
\`\`\`
// Detects unusual file creation patterns
event.type == "file_create" AND
file.extension IN ["exe", "dll", "scr"] AND
file.path MATCHES "*/Temp/*" AND
process.name NOT IN [known_installers]
\`\`\`
```

---

## 8. MITRE ATT&CK Mapping

Map technique to the MITRE ATT&CK framework with proper tactic and technique IDs.

**Required content:**
- Table with columns: Tactic, Technique ID, Technique Name
- Accurate MITRE ATT&CK IDs (including sub-technique IDs like T1543.001)
- All applicable tactics (some techniques map to multiple)
- Correct tactic names matching MITRE framework

**Guidelines:**
- Verify IDs at https://attack.mitre.org/
- Include both parent and sub-technique IDs when relevant
- List all applicable tactics (e.g., technique may provide both Persistence and Privilege Escalation)
- Use exact technique names from MITRE

**Typst table format:**
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
)
```

**Markdown table format:**
```
=== MITRE ATT&CK Mapping

| Tactic | Technique ID | Technique Name |
|--------|--------------|----------------|
| Persistence | T1543.001 | Create or Modify System Process: Launch Agent |
| Privilege Escalation | T1543.001 | Create or Modify System Process: Launch Agent |
```
