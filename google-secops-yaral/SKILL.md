---
name: google-secops-yaral
description: Master YARAL query language for low-maintenance threat hunting and detection in Google SecOps. Build behavioral detections without magic strings or IOC lists. Use when writing YARAL queries, creating custom detections based on network/process behavior, debugging failing queries, or learning YARAL syntax and best practices.
---

# Google SecOps YARAL Mastery

YARAL is Google SecOps's query language for threat hunting. This skill emphasizes **behavioral detection** over artifact-based approaches.

## Core Philosophy

Build detections on behavioral signals, not artifacts:

```yaral
// ❌ Artifact-based (goes stale quickly)
network_connection | network_connection.dst_ipv4 in ["1.2.3.4", "5.6.7.8"]

// ✅ Behavioral (survives infrastructure changes)
process | within 2m: network_connection as nc | count(distinct nc.dst_ipv4) >= 5
```

## Quick Start: Three Core Patterns

See **references/detection-patterns.md** for full examples and variations.

### Pattern 1: Network from Specific Application

```yaral
process
| process.name in ["chrome.exe", "firefox.exe"]
| process.user.user_name != "SYSTEM"
| within 10s: network_connection
```

### Pattern 2: Multi-Destination Beaconing

```yaral
process
| process.ppid != 0
| within 2m: network_connection as nc
| count(distinct nc.dst_ipv4) >= 5
```

### Pattern 3: Multi-Parent Child with Network

```yaral
process as child_process
| child_process.ppid != 0
| within 10s: network_connection
| any_of(process as parent) where parent.pid == child_process.ppid
| count(distinct parent.ppid) >= 2
```

## Query Structure

```yaral
object_type
| filter1
| filter2
| within Xs: correlated_object
```

**Objects:** `process`, `network_connection`, `file`, `authentication`

**Operators:** `==`, `!=`, `<`, `>`, `in`, `!in`, `and`, `or`, `not`

**Time windows:** `within 5s`, `within 2m`, `within 1h`, `within 1d`

**String modifiers:** `.i` (case-insensitive), `.contains()`, `.startsWith()`, `.endsWith()`, `.regex()`

See **references/api_reference.md** for complete syntax, fields, and functions.

## Best Practices for Low-Maintenance Detections

1. **Use behavioral signals** - Count uniqueness: `count(distinct nc.dst_ipv4) >= 5`
2. **Leverage temporal proximity** - Correlate with `within Xs:`
3. **Use system context** - Filter by path, user context, parent-child relationships
4. **Exclude the obvious** - Filter out SYSTEM processes, browsers, update mechanisms
5. **Stack weak signals** - Combine multiple conditions for precision

## Resources

### Reference Documentation

- **references/api_reference.md** - Complete YARAL syntax, data types, operators, functions, and object schemas
- **references/detection-patterns.md** - Detailed examples of the three core patterns with variations and best practices

### Python Query Builder

Run `scripts/example.py` to generate queries:

```bash
python scripts/example.py
```

Methods available:
- `network_from_application()` - App network detection
- `multi_destination_beaconing()` - C2 identification
- `multi_parent_child_network()` - Lateral movement detection
- `suspicious_child_from_office_app()` - Office exploit detection
- `geographic_beaconing()` - Country-based anomaly detection

## Debugging

**No results?**
- Check field spelling and value types
- Widen time windows
- Simplify by removing filters one at a time

**Too noisy?**
- Narrow `within` window
- Add exclusions for known-good processes
- Stack more signals with `and`
- Use `count(distinct ...)` for outliers
