# Threat Hunting Query Cookbook

All queries use Platform CenQL syntax. Legacy Search equivalents are noted where useful.

## C2 / Malware Infrastructure

```bash
# Cobalt Strike — application-specific scanner data
censys search "web.endpoints.cobalt_strike: *"

# Cobalt Strike by HTTP characteristics (works without Threat Hunting module)
censys search "web.endpoints.http.response.html_title: \"Cobalt Strike\""

# Deimos C2
censys search "host.services: (port: 8443 and (web.endpoints.http.response.html_title=\"Deimos C2\" or host.services.tls.certificates.leaf_data.subject.organization=\"Acme Co\"))"

# Posh C2 (by cert subject)
censys search "host.services.tls.certificates.leaf_data.subject_dn: \"C=US, ST=Minnesota, L=Minnetonka, O=Pajfds, OU=Jethpro, CN=P18055077\""

# Compromised MikroTik routers
censys search "host.services.banner: \"HACKED\" and host.services.protocol: \"MIKROTIK_BW\""
```

## Open/Suspicious Directories

```bash
# Open directory listings
censys search "web.endpoints.http.response.html_title: \"Index of /\""

# With specific file types (e.g. looking for credential dumps, configs)
censys search "web.endpoints.http.response.html_title: \"Index of /\" and web.endpoints.http.body: \".env\""
```

## Network Devices & Exposed Management Interfaces

```bash
# Exposed RDP
censys search "host.services.protocol: \"RDP\""

# SSH on non-standard ports
censys search "host.services: (protocol=SSH and not port: {22, 2222})"

# Services on port 53 that aren't DNS (possible DNS tunneling)
censys search "host.services: (port: 53 and not protocol: DNS)"

# Exposed Kubernetes API
censys search "web.endpoints.kubernetes: *"

# Exposed Elasticsearch
censys search "web.endpoints.elasticsearch: *"

# Exposed Prometheus metrics
censys search "web.endpoints.prometheus: *"

# Exposed Chrome DevTools (remote debugging)
censys search "web.endpoints.chrome_devtools: *"

# Exposed Ollama (AI model server)
censys search "web.endpoints.ollama: *"
```

## CVE / Vulnerability Hunting

```bash
# MOVEit (CVE-2023-34362) — favicon hash
censys search "host.services.http.response.favicons.md5_hash: \"af8bf513860e22425eff056332282560\""

# Cisco IOS-XE WebUI (CVE-2023-20198)
censys search "host.labels.value: \"cisco-xe-webui\""

# MikroTik RouterOS admin page (CVE-2023-30799)
censys search "web.endpoints.http.response.html_title: \"RouterOS router configuration page\""

# HTTP/2 endpoints (CVE-2023-44487 Rapid Reset — broad sweep)
censys search "host.services.http.supports_http2: true"
```

## TLS Fingerprinting (JA3 / JA4 / JARM)

These fields require the Threat Hunting module add-on.

```bash
# JA4 fingerprint (TLS client hello)
censys search "host.services.tls.ja4: \"<fingerprint>\""

# JA4S (server hello response fingerprint)  
censys search "host.services.tls.ja4s: \"<fingerprint>\""

# JARM (active TLS fingerprint of the server)
censys search "host.services.tls.jarm: \"<fingerprint>\""

# Example: find SSH services with a specific JA4S
censys search "host.services.tls.ja4s: t130200_1303_a56c5b993250"
```

## Certificate-Based Pivoting

```bash
# Find all certs for a domain (including subdomains via tokenization)
censys search "cert.names: \"example.com\""

# Exact CN — find impersonation certs
censys search "cert.parsed.subject.common_name = \"paypal.com\""

# Typosquatting detection with regex
censys search "cert.parsed.subject.common_name=~\`paypa[^l]\`"

# Self-signed certs for a specific org string
censys search "cert.parsed.issuer_dn: \"Example Corp\" and cert.parsed.subject_dn: \"Example Corp\""

# Recently issued certs — useful for tracking new infra
censys search "cert.names: \"target.com\"" --fields cert.parsed.subject.common_name,cert.parsed.validity.start,cert.names

# Wildcard certs
censys search "cert.parsed.subject.common_name=~\`^\*\.\`"
```

## ASN / Org Attribution

```bash
# All hosts in an ASN
censys search "host.autonomous_system.asn: 15169"

# By org name (tokenized — use : not =)
censys search "host.autonomous_system.name: \"Google\""

# Aggregate ports across an ASN
censys aggregate "host.autonomous_system.asn: 15169" "host.services.port"
```

## Banner Hunting

```bash
# Specific banner string (uses the banner alias)
censys search "banner: \"OpenSSH_8.9\""

# HTTP Server header value
censys search "web.endpoints.http.response.headers: (key=\"Server\" and value: \"Apache/2.4\")"
```
