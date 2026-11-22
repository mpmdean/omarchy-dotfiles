#!/usr/bin/env bash
# Adds the web app launchers listed in data/webapps.txt.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

DATA_FILE="data/webapps.txt"

echo "==> Installing web apps"

while IFS='|' read -r -u3 name url icon; do
  [[ -z "$name" || "$name" == \#* ]] && continue

  if [[ -f "$HOME/.local/share/applications/${name}.desktop" ]]; then
    echo "  - webapp already installed: $name"
  else
    echo "  - installing webapp: $name ($url)"
    omarchy-webapp-install "$name" "$url" "$icon"
  fi
done 3<"$DATA_FILE"
