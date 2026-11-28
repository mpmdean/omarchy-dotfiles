#!/usr/bin/env bash
# Sets the window corner radius from data/window-corners.txt by writing a
# marked block into ~/.config/hypr/looknfeel.lua (replaced on re-runs).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

radius="$(grep -vE '^\s*(#|$)' data/window-corners.txt | head -1 | tr -d '[:space:]')"
[[ $radius =~ ^[0-9]+$ ]] || { echo "Invalid radius in data/window-corners.txt: $radius" >&2; exit 1; }

file="$HOME/.config/hypr/looknfeel.lua"
begin="-- BEGIN omarchy-dotfiles: window corners"
end="-- END omarchy-dotfiles: window corners"
block="$begin
-- Loaded after the theme, so it applies to every theme.
-- \`omarchy hyprland corners sharp\` still overrides it.
hl.config({
  decoration = {
    rounding = $radius,
    rounding_power = 3,
  },
})
$end"

echo "==> Setting window corners to ${radius}px"

[[ -f $file ]] || { echo "  - $file not found; is Omarchy installed?" >&2; exit 1; }

current="$(awk -v b="$begin" -v e="$end" '$0==b{p=1} p{print} $0==e{p=0}' "$file")"
if [[ $current == "$block" ]]; then
  echo "  - already set"
elif [[ -n $current ]]; then
  tmp="$(mktemp)"
  awk -v b="$begin" -v e="$end" -v blk="$block" \
    '$0==b{print blk; skip=1; next} $0==e{skip=0; next} !skip{print}' "$file" >"$tmp"
  cat "$tmp" >"$file" && rm -f "$tmp"
  echo "  - updated $file"
else
  printf '\n%s\n' "$block" >>"$file"
  echo "  - added to $file"
fi

# Omarchy's "rounded" toggle loads after looknfeel.lua and would force 6px.
if [[ $(omarchy hyprland corners) == "rounded" ]]; then
  omarchy hyprland corners theme
fi
