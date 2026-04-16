# YARAL Query Language Reference

## Table of Contents
1. [YARAL Basics](#yaral-basics)
2. [Data Types and Fields](#data-types-and-fields)
3. [Operators](#operators)
4. [Functions](#functions)
5. [Common Objects (UDM Fields)](#common-objects-udm-fields)
6. [Timeline Functions](#timeline-functions)
7. [Multi-Stage Search](#multi-stage-search)

## YARAL Basics

### Query Structure

Single-stage search queries filter and aggregate events:

```yaral
metadata.event_type = "PROCESS_LAUNCH"
$user = principal.user.userid
$proc = target.process.file.full_path
match:
  $user, $proc
outcome:
  $count = count(metadata.id)
order:
  $count desc
```

### Variable Placeholders

Field values must be assigned to `$variables` before use in `match:` or `outcome:`:

```yaral
$user = target.user.userid        // assign field to variable
$action = security_result[0].action  // array indexing then assign
match:
  $user, $action                  // group by these variables
outcome:
  $count = count(metadata.id)     // aggregate
```

### Query Sections

| Section | Purpose | Required |
|---------|---------|----------|
| filters | Narrow the event set (before `match:`) | Yes |
| `match:` | Group-by fields (placeholder variables) | For aggregations |
| `outcome:` | Computed aggregates or derived fields | For aggregations |
| `condition:` | Filter on aggregated results (post-aggregate WHERE) | No |
| `order:` | Sort results | No |
| `limit:` | Cap the number of output rows | No |

### Case Sensitivity

- Field names: **Case-insensitive** (e.g., `process.pid` = `Process.PID`)
- Values: **Case-sensitive** unless using `.i` modifier
- Operators: **Case-insensitive**

## Data Types and Fields

### Primitive Types

| Type | Description | Example |
|------|-------------|----------|
| string | Text value | `"cmd.exe"` |
| int | Integer number | `1234` |
| bool | True/False | `true`, `false` |
| timestamp | Date/time ISO 8601 | `2024-01-15T10:30:00Z` |
| ipv4 | IP address | `192.168.1.1` |
| domain | Domain name | `example.com` |
| bytes | Size in bytes | `1024` |

### String Modifiers

| Modifier | Meaning | Example |
|----------|---------|----------|
| `.i` | Case-insensitive | `process.name.i == "powershell"` |
| `.startsWith` | Prefix match | `file.path.startsWith("C:")` |
| `.endsWith` | Suffix match | `file.name.endsWith(".exe")` |
| `.contains` | Substring match | `process.command_line.contains("whoami")` |
| `.regex` | Regex pattern | `process.name.regex("^(cmd\|powershell)")` |

## Operators

### Comparison Operators

| Operator | Usage | Type |
|----------|-------|------|
| `==` | Equals | All types |
| `!=` | Not equals | All types |
| `<` | Less than | Numbers, timestamps |
| `<=` | Less than or equal | Numbers, timestamps |
| `>` | Greater than | Numbers, timestamps |
| `>=` | Greater than or equal | Numbers, timestamps |
| `in` | Value in list | All types |
| `!in` | Value not in list | All types |

### Logical Operators

| Operator | Meaning |
|----------|----------|
| `and` | Both conditions true |
| `or` | Either condition true |
| `not` | Negates condition |

## Functions

### String Functions

```yaral
len(string_field)              // Returns length of string
upper(string_field)            // Converts to uppercase
lower(string_field)            // Converts to lowercase
trim(string_field)             // Removes leading/trailing whitespace
replace(field, old, new)       // Replaces substring
substring(field, start, end)   // Extracts substring
split(field, delimiter)        // Splits string into array
```

### Aggregation Functions

```yaral
count(metadata.id)          // Count of events
count(distinct $field)      // Count unique values
min($numeric_field)         // Minimum value
max($numeric_field)         // Maximum value (also used to "select" a value in outcome)
sum($numeric_field)         // Sum of values
avg($numeric_field)         // Average value
```

### Math Functions

```yaral
math.round(value, decimals)    // Round to N decimal places
                               // e.g. math.round(($count / $total) * 100, 2)
```

### Network Functions

```yaral
ipv4InCIDR(ip_field, "10.0.0.0/8")    // Check if IP in CIDR range
ipv4InList(ip_field, list)              // Check if IP in list
getCountry(ip_field)                    // Get country of IP
```

### Array Indexing

Repeated fields (like `security_result`) are accessed by index:

```yaral
security_result[0].action          // First security result action
security_result[0].severity        // First security result severity
```

## Common Objects (UDM Fields)

Google SecOps uses the **Unified Data Model (UDM)**. Fields are prefixed by noun: `principal` (actor/source), `target` (acted-upon), `intermediary`, `src`, `dst`. Filter by `metadata.event_type` to scope to a specific event class.

### Event Types

```yaral
metadata.event_type = "PROCESS_LAUNCH"
metadata.event_type = "NETWORK_CONNECTION"
metadata.event_type = "FILE_CREATION"
metadata.event_type = "USER_LOGIN"
metadata.event_type = "NETWORK_DNS"
```

### Process Fields

```yaral
// Actor process (initiating)
principal.process.pid                      // Process ID
principal.process.file.full_path           // Full path to executable
principal.process.command_line             // Full command line
principal.process.parent_process.pid       // Parent PID
principal.user.userid                      // User who owns the process

// Target process (spawned)
target.process.pid
target.process.file.full_path
target.process.command_line
```

### Network Fields

```yaral
principal.ip                   // Source IP
target.ip                      // Destination IP
principal.port                 // Source port
target.port                    // Destination port
network.ip_protocol            // Protocol (TCP, UDP, etc.)
principal.hostname             // Source hostname
target.hostname                // Destination hostname
```

### File Fields

```yaral
target.file.full_path          // Full file path
target.file.md5                // MD5 hash
target.file.sha256             // SHA256 hash
target.file.size               // File size in bytes
```

### Auth / User Login Fields

```yaral
metadata.event_type = "USER_LOGIN"
target.user.userid             // User attempting login
target.user.user_display_name  // Display name
principal.hostname             // Source machine
target.hostname                // Target machine
security_result[0].action      // ALLOW or BLOCK
security_result[0].severity    // Severity of result
metadata.id                    // Unique event ID (use for count())
```

## Timeline Functions

Timeline functions help correlate events across time:

### seconds_since

Returns number of seconds since event timestamp:

```yaral
seconds_since(event.timestamp) > 60  // Event occurred >60 seconds ago
```

### seconds_between

Returns seconds between two timestamps:

```yaral
seconds_between(event1.timestamp, event2.timestamp) < 30
```

### within

Filters events within time window:

```yaral
process
| process.name == "chrome.exe"
| within 5m: network_connection
  // Find network connections from chrome within 5 minutes
```

### any_of

Matches if any event meets condition:

```yaral
process
| any_of(childprocess) where childprocess.name == "cmd.exe"
```

### all_of

Matches if all events meet condition:

```yaral
process
| all_of(childprocess) where childprocess.name == "powershell.exe"
```

## Multi-Stage Search

Multi-stage searches let you build named intermediate result sets and combine them in a root stage. This is the mechanism for population-level analysis, frequency scoring, outlier detection, and cross-dataset correlation.

### Stage Block Syntax

```yaral
stage stage_name {
  // filter conditions
  metadata.event_type = "USER_LOGIN"
  target.user.userid != ""

  // variable assignments
  $user   = target.user.userid
  $action = security_result[0].action

  match:
    $user, $action           // group-by

  outcome:
    $count = count(metadata.id)

  // optional
  condition:
    $count > 5
  order:
    $count desc
  limit:
    100
}
```

### Cross Join

A cross join combines two stages **without a shared key** — it produces a Cartesian product. In Google SecOps, cross joins are guardrailed: **one of the two stages must output exactly one row** (enforced via `limit: 1`), otherwise the query returns an error:

```
compilation error: at least one operand in a cross join must be a stage that outputs at most one row
```

The one-row stage acts as a "broadcast" — its single value is appended to every row from the other stage, enabling per-row calculations against a population aggregate.

```yaral
stage per_user {
  metadata.event_type = "USER_LOGIN"
  target.user.userid != ""
  $user   = target.user.userid
  $action = security_result[0].action
  match:
    $user, $action
  outcome:
    $login_count = count(metadata.id)
}

stage population_total {
  metadata.event_type = "USER_LOGIN"
  target.user.userid != ""
  outcome:
    $total_count = count(metadata.id)
  limit:
    1                        // required for cross join
}

// Root stage assembles the result
cross join $per_user, $population_total
$user        = $per_user.user
$action      = $per_user.action
$login_count = $per_user.login_count
$total_count = $population_total.total_count
match:
  $user, $action, $login_count
outcome:
  $frequency_pct = max(math.round(($login_count / $total_count) * 100, 2))
order:
  $frequency_pct desc
```

### Cross Join Rules

- `cross join $stage_a, $stage_b` — command syntax, stage names separated by comma
- One stage **must** have `limit: 1`
- Both stages should filter the **same base population** so the comparison is apples-to-apples
- The root stage's output is determined by its own `match:` and `outcome:` sections
- Fields from named stages are referenced as `$stage_name.field_name`

### When to Use Multi-Stage Search

| Use Case | Approach |
|----------|----------|
| Frequency analysis | Per-entity count vs. population total via cross join |
| Outlier / z-score detection | Per-entity stats + population mean/stdev via cross join |
| Time-window bucketing | Named stages per time bucket, joined in root |
| Enrichment | One stage produces a lookup value; cross join appends it |

### Building Multi-Stage Queries

Best practice (from the SecOps team): **build and validate each named stage independently first**, inspect its output, then assemble the multi-stage search. This makes it far easier to debug which stage produces unexpected results.