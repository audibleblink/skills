# Low-Maintenance Detection Patterns

**Philosophy:** Build maintainable detections on behavioral signals, not artifact strings. Avoid hardcoded process names, IPs, or domains—use attributes like parent-child relationships, temporal proximity, and system role.

## Table of Contents
1. [Pattern 1: Network Connections from Specific Application](#pattern-1-network-connections-from-specific-application)
2. [Pattern 2: Multi-Destination Beaconing](#pattern-2-multi-destination-beaconing)
3. [Pattern 3: Multi-Parent Process with Child Network Activity](#pattern-3-multi-parent-process-with-child-network-activity)

---

## Pattern 1: Network Connections from Specific Application

### Use Case
Detect network connections initiated by a particular application, regardless of connection destination.

### Low-Maintenance Approach
Instead of listing expected destinations, identify the application by:
- **Path location** (system binaries vs. user installations)
- **Code signing** (legitimate vs. unsigned)
- **Parent process** (expected launcher vs. unusual parent)

### Example Query: Browser Network Activity

```yaral
process
| process.name in ["chrome.exe", "firefox.exe", "msedge.exe"]
| process.user.user_name != "SYSTEM"  // User-mode browser
| process.image_file.path.startsWith("C:\\Program Files")
  or process.image_file.path.startsWith("C:\\Users")
| within 10s: network_connection
  // Capture all network connections within 10 seconds
```

### Example Query: Service Binary Network Activity (Low Maintenance)

```yaral
process
| process.user.user_name == "SYSTEM"
| process.image_file.path.startsWith("C:\\Windows\\System32")
| process.name == "svchost.exe"
| any_of(network_connection) where
    network_connection.created_time >= process.creation_time
    and seconds_between(process.creation_time, network_connection.created_time) < 5
```

**Why this is maintainable:**
- Uses system context (SYSTEM user, System32 path)
- Doesn't hardcode which service should/shouldn't call network
- Temporal proximity (within 5 seconds) reduces false positives

---

## Pattern 2: Multi-Destination Beaconing

### Use Case
Detect processes connecting to multiple distinct network destinations within a time window (command and control signal).

### Low-Maintenance Approach
Rather than listing "known bad" IPs:
- Count **unique destination IPs** per process
- Examine **temporal clustering** (rapid successive connections)
- Look for **geographic diversity** (connections to multiple countries)
- Exclude known infrastructure (CDNs, update servers)

### Example Query: Rapid Multi-IP Beaconing

```yaral
process
| process.ppid != 0  // Filter out kernel processes
| process.image_file.path.startsWith("C:\\Users")
  or process.image_file.path.startsWith("C:\\Temp")
| within 2m: network_connection as nc
| count(distinct nc.dst_ipv4) >= 5
| min(nc.dst_port) != 443 and max(nc.dst_port) != 80
  // Multiple non-standard ports increase suspicion
```

**Why this is maintainable:**
- No hardcoded IPs or domains
- Behavioral signal: multiple distinct destinations
- Port diversity suggests command-and-control vs. normal browsing

### Example Query: Geographic Beaconing

```yaral
process
| process.ppid != 0
| process.user.user_name != "SYSTEM"
| within 5m: network_connection as nc
| count(distinct getCountry(nc.dst_ipv4)) >= 3
  // Connections to 3+ countries in 5 minutes
```

**Why this is maintainable:**
- Geographic diversity is a behavioral red flag
- No IP/domain lists to maintain
- Works across updates/relocations of C2 infrastructure

### Example Query: Port Fluxing

```yaral
process
| process.user.user_name != "SYSTEM"
| process.name not in ["chrome.exe", "firefox.exe", "msedge.exe"]
| within 3m: network_connection as nc
| count(distinct nc.dst_port) >= 10
  // Trying many different ports to a few destinations
```

**Why this is maintainable:**
- Port scanning/fluxing is behavioral, not artifact-based
- Generic enough to detect varied malware families

---

## Pattern 3: Multi-Parent Process with Child Network Activity

### Use Case
Detect when multiple parent processes spawn the same child executable, and that child initiates network connections (classic lateral movement / deployment pattern).

### Low-Maintenance Approach
Instead of listing specific executables to watch:
- Identify **unusual parent-child relationships**
- Look for **reuse of child across multiple parents** (lateral movement)
- Check **temporal correlation** (child network activity within N seconds of spawn)
- Focus on **non-system contexts** (user temp folders, user appdata)

### Example Query: Multi-Parent Child with Network Activity

```yaral
process as child_process
| child_process.ppid != 0
| child_process.image_file.path.startsWith("C:\\Users")
| child_process.user.user_name != "SYSTEM"
| within 10s: network_connection as nc
  where nc.process_id == child_process.pid
| any_of(process as p) where
    p.pid == child_process.ppid
    and p.pid != child_process.pid
    and count(distinct p.pid) >= 2
  // At least 2 different parent processes spawned this child
```

### Example Query: Suspicious Child via Living-off-Land

```yaral
process as parent
| parent.name in ["explorer.exe", "notepad.exe", "mspaint.exe"]
  // User-facing apps shouldn't spawn network tools
| childprocess
| childprocess.name in ["powershell.exe", "cmd.exe", "certutil.exe"]
| within 2s: network_connection
  where network_connection.process_id == childprocess.pid
  and network_connection.dst_port not in [80, 443, 53]
    // Non-standard port suggests C2, not normal app
```

**Why this is maintainable:**
- Uses parent-child relationships and user context
- Behavioral: admin tools from user apps + network = suspicious
- No hardcoded malware names or IPs

### Example Query: Multiple Parents Launching Same Tool

```yaral
process as child
| child.name == "powershell.exe"
| child.ppid != 0
| within 5s: network_connection
  where network_connection.process_id == child.pid
  and network_connection.dst_port == 4444
    // Listening port often used in exploitation
| group_by(child.name) having count(distinct child.ppid) >= 3
  // 3+ different parents launched this child
```

---

---

## Pattern 4: Frequency / Baseline Analysis with Cross Join

### Use Case

Measure how frequently something occurs for each entity (user, host, process) and compare it against the population total. Identifies outliers without hardcoding thresholds — the data shapes the baseline.

### Why Multi-Stage + Cross Join

A single-stage query can count per-entity, but it can't simultaneously know the population total. The cross join solves this by:

1. **Stage 1** — count per entity (many rows)
2. **Stage 2** — count the full population (`limit: 1`, single row)
3. **Root** — cross join broadcasts the population total to every per-entity row, enabling a percentage or ratio calculation

### Key Constraint

The `limit: 1` stage **must use the same filter logic** as the per-entity stage. If the base populations differ, the frequency calculation is meaningless.

### Example: Login Frequency by User

```yaral
stage login_per_user {
  metadata.event_type = "USER_LOGIN"
  target.user.userid != ""
  target.user.userid != /\$$/       // exclude machine accounts

  $user   = target.user.userid
  $action = security_result[0].action

  match:
    $user, $action
  outcome:
    $login_count = count(metadata.id)
}

stage login_total {
  metadata.event_type = "USER_LOGIN"
  target.user.userid != ""
  target.user.userid != /\$$/       // same filter as stage 1

  outcome:
    $total_count = count(metadata.id)
  limit:
    1
}

cross join $login_per_user, $login_total
$user        = $login_per_user.user
$action      = $login_per_user.action
$login_count = $login_per_user.login_count
$total_count = $login_total.total_count
match:
  $user, $action, $login_count
outcome:
  $frequency_pct = max(math.round(($login_count / $total_count) * 100, 2))
order:
  $frequency_pct desc
```

**Why this is maintainable:**
- No hardcoded thresholds — the baseline is the actual population in the search window
- Surfacing the top consumers is a repeatable analytical pattern across any event type
- Add `condition: $frequency_pct > 4` to filter for dashboard visualization

### Variations

**Host-based frequency (e.g., DNS request volume):**
```yaral
stage dns_per_host {
  metadata.event_type = "NETWORK_DNS"
  principal.hostname != ""
  $host = principal.hostname
  match: $host
  outcome: $query_count = count(metadata.id)
}

stage dns_total {
  metadata.event_type = "NETWORK_DNS"
  outcome: $total = count(metadata.id)
  limit: 1
}

cross join $dns_per_host, $dns_total
$host        = $dns_per_host.host
$query_count = $dns_per_host.query_count
match: $host, $query_count
outcome:
  $pct = max(math.round(($query_count / $dns_total.total) * 100, 2))
condition:
  $pct > 5
order:
  $pct desc
```

### Building Multi-Stage Queries: Recommended Workflow

Per the SecOps team:

1. Write and run **Stage 1** alone — inspect rows and column values
2. Write and run **Stage 2** alone — confirm it produces exactly one row
3. Assemble the multi-stage search with `cross join`
4. Add `condition:` and `order:` in the root stage after confirming the join is correct

---

## General Best Practices for Maintainability

1. **Use behavioral signals, not artifacts**
   - ✅ "Multiple destination IPs"
   - ❌ "Connections to 1.2.3.4 or 5.6.7.8"

2. **Temporal proximity matters**
   - ✅ "Network connection within 2 seconds of process creation"
   - ❌ "Any network by this process ever"

3. **Context is king**
   - ✅ "SYSTEM user spawning from System32 + network"
   - ❌ "Any process + any network"

4. **Exclude the obvious**
   - Filter out system processes, update mechanisms, browsers
   - Use user context, file paths, parent relationships

5. **Avoid lists you can't maintain**
   - IOC lists go stale quickly
   - Behavioral rules adapt to adversary changes

6. **For multi-stage searches: match your populations**
   - Both stages in a cross join must filter the same base data
   - Build each stage independently before assembling
   - The `limit: 1` stage is the population denominator — protect its accuracy

