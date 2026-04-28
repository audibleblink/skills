# Legacy Search → Platform (CenQL) Field Changes

Censys introduced a new data model in the Platform. If you're working from memory or old
examples, the field prefixes have changed significantly. Old queries using Legacy Search syntax
will silently return wrong results or errors.

## Key rule

Every field now has a dataset prefix: `host.*`, `cert.*`, or `web.*`.
The `web.*` dataset is new — it covers web properties (hostname:port pairs), which
replaced "virtual hosts" in the old model.

## Field mapping cheatsheet

| Legacy Search | Platform (CenQL) | Notes |
|---|---|---|
| `ip: 1.1.1.1` | `host.ip: 1.1.1.1` | |
| `services.port: 443` | `host.services.port: 443` | |
| `services.service_name: HTTP` | `host.services.protocol: "HTTP"` | field renamed too |
| `services.software.product: "GitLab"` | `host.services.software.product: "GitLab"` or `web.software.product: "GitLab"` | |
| `name: "censys.com"` | `web.hostname: "censys.com"` | |
| `dns.names: "censys.io"` | `host.dns.names: "censys.io"` | |
| `location.country: "Spain"` | `host.location.country: "Spain"` | |
| `autonomous_system.asn: 1234` | `host.autonomous_system.asn: 1234` | |
| `labels: camera` | `host.services.hardware.type="CAMERA"` | |
| `labels: ipv6` | `host.labels.value: "IPV6"` | |
| `services.http.response.html_title: "..."` | `web.endpoints.http.response.html_title: "..."` | now under web.* |
| `services.http.response.body: "..."` | `web.endpoints.http.body: "..."` | |
| `services.tls.certificate.parsed.subject_dn: "..."` | `host.services.tls.certificates.leaf_data.subject_dn: "..."` | |
| `services.banner: "..."` | `host.services.banner: "..."` or use alias `banner:` | |
| `services: (port: X and service_name: Y)` | `host.services: (port: X and protocol: Y)` | |

## Syntax changes

| Legacy | Platform | Notes |
|---|---|---|
| `field: [* TO 10)` | `field < 10` | Range operators simplified |
| `field: *foo*` | `field=~\`foo\`` | No wildcard `*`/`?` in values — use regex |
| `field: [2024-01-01 TO 2024-12-31]` | `field >= 2024-01-01 and field <= 2024-12-31` | or use relative time |

## Relative time

```
# Last 24 hours
field > now-24h

# Last 7 days, rounded to day boundary
field > now-7d/d

# Round to nearest hour
field > now-1h/h
```

## Web Properties — new dataset

The `web.*` dataset covers hostname-based assets (what used to be "virtual hosts").
If you're looking for HTTP content, headers, or responses, it's probably under `web.*` not `host.*`.

```
# HTTP title (web property)
web.endpoints.http.response.html_title: "Jenkins"

# HTTP body content
web.endpoints.http.body: "click here to login"

# Specific endpoint path
web.endpoints.path: "/wp-admin"

# Application detected (e.g. Cobalt Strike, Kubernetes)
web.endpoints.cobalt_strike: *
web.endpoints.kubernetes: *
```
