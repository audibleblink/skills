# YARAL Query Language Reference

## Table of Contents
1. [YARAL Basics](#yaral-basics)
2. [Data Types and Fields](#data-types-and-fields)
3. [Operators](#operators)
4. [Functions](#functions)
5. [Common Objects](#common-objects)
6. [Timeline Functions](#timeline-functions)

## YARAL Basics

### Query Structure

YARAL queries follow this basic pattern:

```yaral
object_type
| filter_condition
| additional_filters
```

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
count()                 // Count of events
count(distinct field)   // Count unique values
min(numeric_field)      // Minimum value
max(numeric_field)      // Maximum value
sum(numeric_field)      // Sum of values
avg(numeric_field)      // Average value
```

### Network Functions

```yaral
ipv4InCIDR(ip_field, "10.0.0.0/8")    // Check if IP in CIDR range
ipv4InList(ip_field, list)              // Check if IP in list
getCountry(ip_field)                    // Get country of IP
```

## Common Objects

### Process Object

```yaral
process.pid                    // Process ID
process.ppid                   // Parent process ID
process.name                   // Process executable name
process.command_line           // Full command line
process.creation_time          // When process started
process.user.user_name         // Username who started process
process.image_file.name        // Path to executable
process.working_directory      // Process working directory
```

### Network Object

```yaral
network_connection.src_ipv4    // Source IP
network_connection.dst_ipv4    // Destination IP
network_connection.src_port    // Source port
network_connection.dst_port    // Destination port
network_connection.protocol    // Protocol (tcp, udp, etc.)
network_connection.created_time // When connection created
network_connection.process_id  // PID that initiated connection
```

### File Object

```yaral
file.name                      // Filename
file.path                      // Full file path
file.creation_time             // File creation time
file.modified_time             // Last modified time
file.size                      // File size in bytes
file.md5                       // MD5 hash
file.sha256                    // SHA256 hash
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

## Authentication Object

### Fields

```yaral
authentication.type              // Auth type (e.g., "INTERACTIVE", "NETWORK")
authentication.status            // Success/failure status
authentication.user.user_name    // Username attempting authentication
authentication.user.domain       // User's domain
authentication.target_host       // Target machine for auth
authentication.source_host       // Source machine initiating auth
authentication.logon_id          // Unique session identifier
authentication.timestamp         // When authentication occurred
```

### Example: Failed Auth Spray Detection

```yaral
authentication
| authentication.status == "FAILURE"
| within 5m: authentication as a
| count(distinct a.user.user_name) >= 10
  // 10+ different users failing auth = password spray
```

### Example: Lateral Auth Chain

```yaral
authentication
| authentication.type == "NETWORK"
| authentication.status == "SUCCESS"
| within 10m: authentication as a2
  where a2.source_host == authentication.target_host
  // Successful auth followed by auth FROM that target = lateral movement
```