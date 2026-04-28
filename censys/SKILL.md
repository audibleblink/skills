---
name: censys
description: >
  Use when the user wants to search Censys, write CenQL queries, investigate IPs/domains/certs,
  pivot from one asset to related infrastructure, hunt threats, or aggregate internet data.
  Triggers on: "search censys", "look up this IP", "find hosts running X", "pivot from this cert",
  "what else does this org own", "censeye", "censys aggregate", or any internet recon/threat hunting
  task — even if the user doesn't say "censys" explicitly.
---

# Censys Skill

You have access to the `censys` CLI. Use it to search hosts, web properties, and certificates;
pivot through infrastructure; and aggregate internet-wide data.

## Reference files

- **`references/legacy-to-platform.md`** — Read this if you're unsure whether a field name is current Platform syntax vs old Legacy Search syntax. My training likely has Legacy Search patterns baked in — this is the most common source of bad queries.
- **`references/threat-hunting-queries.md`** — Ready-to-use CenQL query cookbook: C2 detection, CVE hunting, TLS fingerprinting, open directories, certificate pivoting.

## Scripts

- **`scripts/recon.sh <ip> [days]`** — Full recon on an IP: services, certs, ASN, censeye pivot, history. Run this instead of assembling multiple commands by hand.
- **`scripts/pivot.sh <ip> [rarity_min] [rarity_max]`** — Runs censeye and emits ready-to-run `censys search` commands for each shared field. Use this after censeye to quickly turn pivot results into actionable queries.

---

## CenQL — Key syntax

The Censys Query Language (CenQL) has a few non-obvious behaviors worth knowing:

### Operators

| Operator | Behavior |
|----------|----------|
| `:` | Case-insensitive, tokenized match — good for banners, HTTP bodies, text fields |
| `=` | Exact, case-sensitive match — use for IPs, country codes, known product names |
| `=~` | Regex match (backtick-quoted) — case-sensitive, unanchored by default; use `^`/`$` at edges only |
| `:*` | Field exists / has any value |
| `<`, `>`, `<=`, `>=` | Range — works on numbers, dates, IPs, and strings |

Logical: `and`, `or`, `not`. Group with `()`.

### Tokenization gotcha

The `:` operator tokenizes text — it breaks values into chunks. For cert fields like `cert.names`
and `cert.parsed.subject.common_name`, it uses a **subdomain analyzer**, so
`cert.parsed.subject.common_name: "abcdefg-1234567.example.com"` extracts tokens
`abcdefg-1234567.example.com`, `example.com`, `com`. To match a prefix pattern, use regex:
```
cert.parsed.subject.common_name=~`^abcdefg-1234567`
```

### Useful aliases

| Alias | Expands to |
|-------|------------|
| `banner` | `host.services.banner`, `web.endpoints.banner` |
| `cpe` | All CPE fields across host, services, software, OS |

### Common field prefixes

- `host.*` — IP hosts and their services
- `web.*` — web properties (domains, endpoints)
- `cert.*` — certificates

---

## Workflows

### Recon on an IP or domain

```bash
# View a host
censys search "host.ip: '8.8.8.8'"

# Services on a host
censys search "host.ip: '8.8.8.8'" --fields host.services.port,host.services.protocol,host.services.software.product

# All hosts for a domain
censys search "web.hostname: 'example.com'"

# SSH on non-standard ports
censys search "host.services: (protocol=SSH and not port: {22, 2222})"

# Specific software version
censys search "host.services.software.product: 'GitLab' and host.services.software.version: '15.0'"
```

### Certificate recon

```bash
# Certs issued to a domain (including subdomains via tokenization)
censys search "cert.names: 'example.com'"

# Exact CN match
censys search "cert.parsed.subject.common_name = 'example.com'"

# Wildcard cert hunting
censys search "cert.parsed.subject.common_name=~\`^\*\.example\`"

# Recently issued certs for a domain (useful for discovering new infra)
censys search "cert.names: 'example.com'" --fields cert.parsed.subject.common_name,cert.parsed.validity.start,cert.names
```

### Pivoting (censeye)

censeye finds other assets sharing characteristics with a given IP — great for finding related infrastructure.

```bash
# Find assets sharing key-value pairs with a host
censys censeye 1.2.3.4

# Tune rarity: min/max host count for "interesting" shared values
censys censeye --rarity-min 2 --rarity-max 50 1.2.3.4

# Output as JSON for programmatic use
censys censeye --output-format json 1.2.3.4
```

After censeye, take the interesting shared field values and build a search query from them.

### Aggregation / reporting

```bash
# Count hosts by country running SSH
censys aggregate "host.services.protocol=SSH" "host.location.country"

# Top ports for HTTP hosts
censys aggregate "host.services.protocol=HTTP" "host.services.port" --num-buckets 20

# JSON output for piping
censys aggregate "host.services.protocol=SSH" "host.location.country" --output-format json
```

### Historical change tracking

```bash
# What changed on this IP in the last 30 days
censys history 1.2.3.4 --duration 30d

# Changes in a specific window
censys history example.com:443 --start 2025-01-01T00:00:00Z --end 2025-01-31T00:00:00Z
```

---

## Output tips

- Default output is `short`. Use `--output-format json` when you need to parse or pipe results.
- Use `--fields` with `censys search` to limit returned data and reduce noise.
- Use `--max-pages -1` to fetch all results (can be large — be careful).
- Use `--streaming` (`-S`) for large result sets to get NDJSON progressively.
