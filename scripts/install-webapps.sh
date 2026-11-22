#!/usr/bin/env bash
# Adds the web app launchers listed in data/webapps.txt, plus an optional
# Hyprland keybinding for each.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

DATA_FILE="data/webapps.txt"
BINDINGS_FILE="$HOME/.config/hypr/bindings.lua"
reload=false

echo "==> Installing web apps"

while IFS='|' read -r -u3 name url icon key; do
  [[ -z "$name" || "$name" == \#* ]] && continue

  if [[ -f "$HOME/.local/share/applications/${name}.desktop" ]]; then
    echo "  - webapp already installed: $name"
  else
    echo "  - installing webapp: $name ($url)"
    omarchy-webapp-install "$name" "$url" "$icon"
  fi

  if [[ -n "$key" ]]; then
    marker="-- webapp: $name"
    if [[ -f "$BINDINGS_FILE" ]] && grep -qxF -- "$marker" "$BINDINGS_FILE"; then
      echo "    keybinding already present for $name"
    else
      printf '\n%s\no.rebind("%s", "%s", { webapp = "%s" })\n' \
        "$marker" "$key" "$name" "$url" >>"$BINDINGS_FILE"
      echo "    bound $key -> $name in $BINDINGS_FILE"
      reload=true
    fi
  fi
done 3<"$DATA_FILE"

if $reload && command -v hyprctl &>/dev/null && hyprctl reload &>/dev/null; then
  echo "  - reloaded Hyprland config"
fi
