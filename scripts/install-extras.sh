#!/usr/bin/env bash
# Installs the extra tools listed in data/extras.txt: a pacman package and,
# where applicable, its matching Omarchy shell plugin and a systemd --user
# service to enable.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

DATA_FILE="data/extras.txt"

echo "==> Installing extras"
echo "    Note: Omarchy plugins run as unsandboxed code inside omarchy-shell."
echo "    Only entries you've reviewed and trust belong in data/extras.txt."

while IFS='|' read -r -u3 name pkg plugin_url plugin_id service desc; do
  [[ -z "$name" || "$name" == \#* ]] && continue

  echo "  - $name: $desc"

  if [[ -n "$pkg" ]]; then
    if pacman -Qq "$pkg" &>/dev/null; then
      echo "    package '$pkg' already installed"
    else
      yay -S "$pkg"
    fi
  fi

  if [[ -n "$plugin_url" ]]; then
    if omarchy-plugin-list --json 2>/dev/null | jq -e --arg id "$plugin_id" 'any(.[]; .id == $id)' >/dev/null; then
      echo "    plugin '$plugin_id' already added"
    else
      omarchy-plugin-add "$plugin_url" --enable
    fi
  fi

  if [[ -n "$service" ]]; then
    if systemctl --user is-enabled --quiet "$service" && systemctl --user is-active --quiet "$service"; then
      echo "    service '$service' already enabled and running"
    else
      systemctl --user enable --now "$service"
    fi
  fi
done 3<"$DATA_FILE"
