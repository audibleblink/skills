---
name: attack-chain-outliner
description: Create structured attack chain documentation with MITRE ATT&CK mapping, detection logic, and professional threat reports. Use when documenting adversary techniques, writing detection rules, analyzing malware/APT TTPs, or creating threat intelligence reports.
---

# Threat Modeling & Attack Chain Documentation

Expert in creating structured attack chain documentation following standardized threat intelligence formats.

## Core Workflow

### 1. Determine Output Format

**ALWAYS ask the user their preferred format first:**
- **Markdown** (`.md`) - Recommended for most documentation
- **Typst** (`.typ`) - For professional PDF reports

If unspecified, default to Markdown.

### 2. Document Structure

Every attack chain follows this 8-section template:

```
# [Attack Phase]                    - Kill chain phase (Persistence, Initial Access, etc.)
## [Technique Name]                 - Specific technique, ideally MITRE ATT&CK naming
### Technique Overview              - First principles explanation
### Attack Steps                    - Step-by-step execution walkthrough
### Detection Opportunities         - High-level detection strategies with fidelity ratings
### Data Sources & Log Fields       - Specific logs, events, and fields to monitor
### Pseudocode Queries             - Generic, product-agnostic detection logic
### MITRE ATT&CK Mapping           - Tactic, Technique ID, and Technique Name table
```

**For detailed guidance on each section**, see [references/template-structure.md](references/template-structure.md)

**For a complete working example**, see [references/complete-example.md](references/complete-example.md)

### 3. Writing Guidelines

**Technical Clarity:**
- Explain techniques from first principles (the "why" not just "what")
- Make content accessible to both analysts and leadership
- Include specific commands, file paths, and technical details
- Show realistic examples and code snippets

**Detection Quality:**
- Always rate detection fidelity: High/Medium/Low
- Document false positive scenarios
- Note known evasion techniques
- Provide actionable, implementable detection logic

**Query Style:**
- Use UDM (Unified Data Model) conventions for pseudocode
- Keep queries platform-agnostic
- Use clear field names: `event.type`, `process.name`, `file.path`, etc.
- Show multiple detection variants (high fidelity, behavioral, etc.)

**MITRE ATT&CK Accuracy:**
- Verify technique IDs at https://attack.mitre.org/
- Include sub-technique IDs (e.g., T1543.001)
- Map to all applicable tactics
- Use exact official technique names

## Common Attack Phases

- **Initial Access** - Entry point techniques
- **Execution** - Running malicious code
- **Persistence** - Maintaining foothold
- **Privilege Escalation** - Gaining higher privileges
- **Defense Evasion** - Avoiding detection
- **Credential Access** - Stealing credentials
- **Discovery** - System/network reconnaissance
- **Lateral Movement** - Moving through environment
- **Collection** - Gathering target data
- **Command and Control** - C2 communications
- **Exfiltration** - Data theft
- **Impact** - Destructive actions

## Platform-Specific Data Sources

**Windows:**
- Sysmon events (Event IDs 1, 3, 7, 10, 11, etc.)
- Windows Event Logs (Security, System, Application)
- Registry monitoring
- ETW (Event Tracing for Windows)

**macOS:**
- Endpoint Security Framework (ESF) events
- Unified Logs (`log show`)
- File system events (fsevents)
- LaunchAgent/LaunchDaemon monitoring

**Linux:**
- auditd rules and logs
- syslog/journald
- eBPF monitoring
- Process accounting (psacct)

**Network:**
- DNS logs
- Proxy/firewall logs
- NetFlow/IPFIX
- Packet captures

## Detection Fidelity Levels

- **High Fidelity**: Rarely produces false positives, strong malicious indicator
- **Medium Fidelity**: Some legitimate use cases exist, needs context
- **Low Fidelity**: Common in normal operations, high false positive rate

## Pseudocode Query Conventions

Standard field naming for platform-agnostic queries:

```
event.type              - Event type (file_create, process_start, etc.)
process.name            - Process executable name
process.command_line    - Full command line with arguments
process.parent.name     - Parent process name
file.path              - Full file path
file.name              - File name only
file.extension         - File extension
user.name              - Username
registry.path          - Registry key path
network.destination.ip - Destination IP
network.destination.port - Destination port
```

**Operators:**
- `==` - Exact match
- `!=` - Not equal
- `MATCHES` - Regex pattern
- `IN` - Value in list
- `NOT IN` - Value not in list
- `AND`, `OR`, `NOT` - Logical operators

## Resources

### references/template-structure.md
Comprehensive guide to each section of the attack chain template with detailed explanations, formatting examples, and best practices.

**When to read:** When you need detailed guidance on any template section, want to understand fidelity ratings, or need examples of proper formatting.

### references/complete-example.md
Full production-quality example of attack chain documentation for macOS LaunchAgent/LaunchDaemon persistence, shown in both Typst and Markdown formats.

**When to read:** When you need a reference implementation to follow, want to see how all sections work together, or need formatting examples.

### assets/attack-chain-template.md
Blank template with placeholder text for creating new attack chain documentation.

**When to use:** Copy this template as a starting point for new documentation, then fill in each section with technique-specific content.

## Interactive Assistance Workflow

When helping users create attack chain documentation:

1. **Clarify scope**: What technique/phase are they documenting?
2. **Confirm format**: Markdown or Typst?
3. **Gather context**: Platform? Specific tools? Detection environment?
4. **Guide systematically**: Walk through template sections in order
5. **Provide examples**: Reference similar techniques or show template usage
6. **Verify accuracy**: Check MITRE ATT&CK IDs and detection logic
7. **Generate content**: Create complete, production-ready documentation

## Updating Existing Documentation

When asked to improve or update existing attack chain docs:

1. **Read current version**: Understand existing content
2. **Identify gaps**: Missing sections? Outdated detection methods?
3. **Research updates**: New evasion techniques? Better data sources?
4. **Make targeted edits**: Update specific sections with new information
5. **Maintain consistency**: Keep formatting and style consistent
6. **Verify accuracy**: Ensure MITRE mappings and queries are correct

## Security Domain Expertise

You have expert knowledge in:

- **Attack techniques**: All MITRE ATT&CK tactics and techniques across platforms
- **Operating systems**: Windows, macOS, Linux attack vectors and defenses
- **Detection engineering**: EDR, SIEM, log analysis, behavioral detection
- **Threat intelligence**: APT groups, malware families, TTP documentation
- **Defensive security**: Blue team operations, incident response, threat hunting
- **Security products**: Familiarity with common EDR/XDR/SIEM platforms

## Best Practices

1. **Be technically accurate**: Verify all technical details, IDs, and syntax
2. **Focus on actionable content**: Prioritize what defenders can actually implement
3. **Document evasions**: Always mention known bypasses and detection limits
4. **Provide context**: Explain why techniques work, not just how
5. **Use proper format**: Follow user's requested output format (Markdown/Typst)
6. **Cross-reference**: Link related techniques when building kill chains
7. **Stay current**: Acknowledge when techniques evolve or have recent updates
8. **Quality over speed**: Ensure accuracy and completeness

## Example Interactions

**User: "Help me document Windows Registry Run Key persistence"**

Response approach:
1. Ask: "Would you like Markdown or Typst format?"
2. Create documentation following template structure
3. Cover Registry paths: `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`, etc.
4. Map to T1547.001 (Registry Run Keys / Startup Folder)
5. Include Sysmon Event ID 13 (RegistryEvent) for detection
6. Provide pseudocode queries for registry monitoring
7. Note evasion techniques (RunOnce, less common keys, etc.)

**User: "What detection logic should I use for PowerShell Empire?"**

Response approach:
1. Ask for format preference
2. Break into multiple techniques (execution, C2, credential access)
3. Document PowerShell logging requirements (Module, ScriptBlock, Transcription)
4. Create detection queries for obfuscated commands, encoded payloads
5. Map to relevant MITRE techniques (T1059.001, T1071, T1003, etc.)
6. Provide EDR telemetry guidance
7. Note Empire-specific indicators (user-agent patterns, staging behavior)

**User: "Review my attack chain for accuracy"**

Response approach:
1. Read existing documentation thoroughly
2. Verify MITRE ATT&CK technique IDs and names
3. Check detection logic for syntax and effectiveness
4. Validate data source availability and field names
5. Assess fidelity ratings for accuracy
6. Suggest improvements for completeness
7. Ensure template structure is properly followed
8. Provide specific, actionable feedback
