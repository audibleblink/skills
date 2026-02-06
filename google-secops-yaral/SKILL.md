---
name: google-secops-yaral
description: Write and debug YARAL queries for behavioral threat hunting and detection in Google SecOps. Use when creating YARAL detections, hunting for network/process behavior, or learning YARAL syntax.
refs:
  - references/*.md
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

## Detection Patterns

Three core behavioral patterns for low-maintenance detections:

| Pattern | Use Case | Key Signal |
|---------|----------|------------|
| Network from App | Track app connectivity | Path + user context |
| Multi-Destination Beaconing | C2 identification | `count(distinct dst_ipv4)` |
| Multi-Parent Child | Lateral movement | Parent-child + network |

See **references/detection-patterns.md** for full examples, variations, and best practices.

## Best Practices

1. **Behavioral signals** - Count uniqueness: `count(distinct nc.dst_ipv4) >= 5`
2. **Temporal proximity** - Correlate with `within Xs:`
3. **System context** - Filter by path, user, parent-child relationships
4. **Exclude the obvious** - Filter SYSTEM processes, browsers, update mechanisms
5. **Stack weak signals** - Combine multiple conditions for precision

## Resources

### Reference Documentation

- **references/api_reference.md** - Complete YARAL syntax, data types, operators, functions, and object schemas
- **references/detection-patterns.md** - Detailed examples of the three core patterns with variations

### Python Query Builder

Generate queries programmatically:

```bash
python scripts/query_builder.py
```

Methods:
- `network_from_application()` - App network detection
- `multi_destination_beaconing()` - C2 identification
- `multi_parent_child_network()` - Lateral movement detection
- `suspicious_child_from_office_app()` - Office exploit detection
- `geographic_beaconing()` - Country-based anomaly detection

## Debugging

| Problem | Solution |
|---------|----------|
| No results | Check field spelling, widen time windows, remove filters one at a time |
| Too noisy | Narrow `within` window, add exclusions, stack more signals with `and` |
| Slow query | Reduce time range, add indexed field filters first |
