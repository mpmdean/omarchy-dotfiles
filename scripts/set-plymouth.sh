#!/usr/bin/env bash
# Sets the Plymouth boot screen (and the matching SDDM login screen) colors
# and logo from data/plymouth.txt. Needs sudo; skipped if already applied.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

IFS='|' read -r bg text logo < <(grep -vE '^\s*(#[^0-9a-fA-F]|$)' data/plymouth.txt | head -1)
logo="$PWD/$logo"
bg_hex="${bg#\#}"

echo "==> Setting Plymouth boot screen"

installed=/usr/share/plymouth/themes/omarchy
# Same conversion omarchy-plymouth-set uses to write the background color.
channel() { awk -v n=$((16#$1)) 'BEGIN{printf "%.3f", n/255}'; }
bg_rgb="$(channel "${bg_hex:0:2}"), $(channel "${bg_hex:2:2}"), $(channel "${bg_hex:4:2}")"

if cmp -s "$logo" "$installed/logo.png" &&
  grep -qF "Window.SetBackgroundTopColor($bg_rgb);" "$installed/omarchy.script" &&
  grep -qiF "$text" /usr/share/sddm/themes/omarchy/Main.qml; then
  echo "  - already set (background $bg, text $text, $(basename "$logo"))"
else
  omarchy plymouth set "$bg" "$text" "$logo"
fi
