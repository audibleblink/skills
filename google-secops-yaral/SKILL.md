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
metadata.event_type = "NETWORK_CONNECTION"
target.ip in ["1.2.3.4", "5.6.7.8"]

// ✅ Behavioral (survives infrastructure changes)
metadata.event_type = "NETWORK_CONNECTION"
principal.process.file.full_path != ""
$proc = principal.process.file.full_path
match: $proc
outcome: $distinct_ips = count(distinct target.ip)
condition: $distinct_ips >= 5
```

## Query Structure

Single-stage — filter, assign variables, aggregate:

```yaral
metadata.event_type = "USER_LOGIN"
target.user.userid != ""
$user   = target.user.userid
$action = security_result[0].action
match:
  $user, $action
outcome:
  $count = count(metadata.id)
order:
  $count desc
```

Multi-stage — named `stage {}` blocks assembled with `cross join` for population-level analysis:

```yaral
stage per_entity {
  metadata.event_type = "USER_LOGIN"
  $user = target.user.userid
  match: $user
  outcome: $entity_count = count(metadata.id)
}
stage population {
  metadata.event_type = "USER_LOGIN"   // same filters as per_entity
  outcome: $total = count(metadata.id)
  limit: 1                             // required for cross join
}
cross join $per_entity, $population
$user = $per_entity.user
match: $user
outcome:
  $pct = max(math.round(($per_entity.entity_count / $population.total) * 100, 2))
order: $pct desc
```

**UDM field prefixes:** `principal` (actor/source), `target` (acted-upon)

**Key event types:** `PROCESS_LAUNCH`, `NETWORK_CONNECTION`, `FILE_CREATION`, `USER_LOGIN`, `NETWORK_DNS`

**Operators:** `=`, `!=`, `<`, `>`, `in`, `notin`, `and`, `or`, `not`, regex `/pattern/`

**Array indexing:** `security_result[0].action`, `security_result[0].severity`

See **references/api_reference.md** for complete UDM fields, functions, and multi-stage search reference.

## Detection Patterns

Four core patterns for low-maintenance detections:

| Pattern | Use Case | Key Signal |
|---------|----------|------------|
| Network from App | Track app connectivity | Path + user context |
| Multi-Destination Beaconing | C2 identification | `count(distinct target.ip)` |
| Multi-Parent Child | Lateral movement | Parent-child + network |
| Frequency / Baseline | Outlier detection | Per-entity count vs. population via `cross join` |

See **references/detection-patterns.md** for full examples, variations, and best practices.

## Best Practices

1. **Behavioral signals** - Count uniqueness, not artifact strings
2. **Temporal proximity** - Correlate with `within Xs:`
3. **System context** - Filter by UDM path, user, parent-child relationships
4. **Exclude the obvious** - Filter system accounts, browsers, update mechanisms
5. **Stack weak signals** - Combine multiple conditions for precision
6. **Multi-stage: match your populations** - Both stages in a cross join must use the same base filters; build each stage independently before assembling

## Resources

### Reference Documentation

- **references/api_reference.md** - Complete YARAL syntax, UDM fields, functions, multi-stage search, and cross join reference
- **references/detection-patterns.md** - Detailed examples of all four patterns with variations

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
| No results | Check UDM field spelling, widen search time range, remove filters one at a time |
| Too noisy | Add more filters, raise thresholds in `condition:`, stack more signals with `and` |
| Slow query | Reduce time range, add `metadata.event_type` filter first (it's indexed) |
| Cross join error | Ensure the `limit: 1` stage outputs exactly one row; run it standalone to verify |
| Wrong counts | Confirm both cross join stages use identical base filters |
