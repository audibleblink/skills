#!/usr/bin/env bash
# recon.sh — Full recon on an IP: services, certs, censeye pivot, recent history
#
# Usage: recon.sh <ip> [history_days]
# Example: recon.sh 8.8.8.8
#          recon.sh 1.2.3.4 30

set -euo pipefail

IP="${1:?Usage: recon.sh <ip> [history_days]}"
HISTORY_DAYS="${2:-7}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

hr() { printf '\n%s\n' "$(printf '─%.0s' {1..60})"; }

echo "╔══════════════════════════════════════════════════════════╗"
printf  "║  Censys Recon: %-43s║\n" "$IP"
echo "╚══════════════════════════════════════════════════════════╝"

hr
echo "▶ SERVICES"
hr
censys search "host.ip: '$IP'" \
  --fields host.ip,host.services.port,host.services.protocol,host.services.software.product,host.services.software.version \
  || echo "(no results)"

hr
echo "▶ CERTIFICATES (recent, via cert.names)"
hr
censys search "cert.names: '$IP'" \
  --fields cert.parsed.subject.common_name,cert.names,cert.parsed.validity.start \
  --page-size 10 \
  || echo "(no results)"

hr
echo "▶ ASN / ORG"
hr
censys search "host.ip: '$IP'" \
  --fields host.autonomous_system.asn,host.autonomous_system.name,host.autonomous_system.bgp_prefix,host.location.country,host.location.city \
  || echo "(no results)"

hr
echo "▶ CENSEYE PIVOT (shared infrastructure)"
hr
if command -v bash &>/dev/null && [[ -f "$SCRIPT_DIR/pivot.sh" ]]; then
  bash "$SCRIPT_DIR/pivot.sh" "$IP" 2 100 || echo "(no pivot results)"
else
  censys censeye "$IP" || echo "(no pivot results)"
fi

hr
echo "▶ HISTORY (last ${HISTORY_DAYS}d)"
hr
censys history "$IP" --duration "${HISTORY_DAYS}d" || echo "(no history)"

hr
echo "▶ DONE"
echo ""
