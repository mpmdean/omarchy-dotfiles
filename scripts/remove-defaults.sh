#!/usr/bin/env bash
# Removes the default Omarchy apps listed in data/remove.txt.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

DATA_FILE="data/remove.txt"

echo "==> Removing default Omarchy apps"

while IFS= read -r line; do
  line="${line%%#*}"
  [[ -z "${line// /}" ]] && continue
  kind="${line%%:*}"
  name="${line#*:}"
  name="${name#"${name%%[![:space:]]*}"}"

  case "$kind" in
  webapp)
    if [[ -f "$HOME/.local/share/applications/${name}.desktop" ]]; then
      echo "  - removing webapp: $name"
      omarchy-webapp-remove "$name"
    else
      echo "  - webapp already removed: $name"
    fi
    ;;
  pkg)
    if pacman -Qq "$name" &>/dev/null; then
      echo "  - removing package: $name"
      yay -Rns --noconfirm "$name"
    else
      echo "  - package already removed: $name"
    fi
    ;;
  *)
    echo "  ! unknown entry kind '$kind' for '$name', skipping" >&2
    ;;
  esac
done <"$DATA_FILE"
