#!/usr/bin/env bash
# pivot.sh — Run censeye on an IP and emit ready-to-run censys search queries
# for the most interesting shared fields (within the specified rarity window).
#
# Usage: pivot.sh <ip> [rarity_min] [rarity_max]
# Example: pivot.sh 1.2.3.4
#          pivot.sh 1.2.3.4 2 50

set -euo pipefail

IP="${1:?Usage: pivot.sh <ip> [rarity_min] [rarity_max]}"
RARITY_MIN="${2:-2}"
RARITY_MAX="${3:-100}"

echo "=== CensEye pivot: $IP (rarity $RARITY_MIN–$RARITY_MAX) ===" >&2
echo "" >&2

# Run censeye and capture JSON
RAW=$(censys censeye \
  --output-format json \
  --rarity-min "$RARITY_MIN" \
  --rarity-max "$RARITY_MAX" \
  "$IP" 2>/dev/null)

if [[ -z "$RAW" || "$RAW" == "null" || "$RAW" == "[]" ]]; then
  echo "No censeye results for $IP with rarity $RARITY_MIN–$RARITY_MAX" >&2
  exit 0
fi

echo "--- Interesting shared fields (sorted by host count) ---"
echo ""

# Parse and emit queries. censeye JSON is an array of objects with:
# { "field": "...", "value": "...", "host_count": N, "query": "..." }
# Fall back to constructing field: "value" if no query field present.
echo "$RAW" | jq -r '
  if type == "array" then . 
  elif type == "object" and .results then .results
  else [.] end |
  sort_by(.host_count // 0) |
  .[] |
  "[\(.host_count // "?") hosts]  \(.field // "unknown"): \(.value // "?")\n  Query: \(.query // ((.field // "field") + ": \"" + (.value | tostring) + "\""))\n"
'

echo ""
echo "--- Raw censys search commands ---"
echo ""

echo "$RAW" | jq -r '
  if type == "array" then . 
  elif type == "object" and .results then .results
  else [.] end |
  sort_by(.host_count // 0) |
  .[] |
  "censys search " + ((.query // ((.field // "field") + ": \"" + (.value | tostring) + "\"")) | @sh)
'
