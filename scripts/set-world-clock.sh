#!/usr/bin/env bash
# Sets the cities shown by the World Clock bar widget (omarchy.elsewhen)
# from data/world-clock.json.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

cities="$(jq -c . data/world-clock.json)"
current="$(omarchy bar get omarchy.elsewhen cities 2>/dev/null | jq -c . 2>/dev/null || true)"

echo "==> Setting World Clock cities"

if [[ "$current" == "$cities" ]]; then
  echo "  - already set ($(jq -r 'map(.name) | join(", ")' <<<"$cities"))"
else
  omarchy bar set omarchy.elsewhen cities "$cities" --json --section centerEnd
fi
