#!/usr/bin/env bash
# Sets up Superwhisper dictation from data/dictation.txt: its shortcuts, the
# Wayland input-method flags for Chromium/VS Code, and a Right Ctrl remap for
# keyboards that lack one (written as a marked block in hypr/input.lua).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

entries() { grep -vE '^\s*(#|$)' data/dictation.txt | awk -F'|' -v k="$1" '$1==k'; }

echo "==> Setting up Superwhisper dictation"

# 1. Shortcuts
if command -v superwhisper >/dev/null; then
  current="$(superwhisper shortcuts show)"
  while IFS='|' read -r _ name chord; do
    if [[ $(jq -r --arg n "$name" '.shortcuts[$n] // ""' <<<"$current") == "$chord" ]]; then
      echo "  - $name shortcut already $chord"
    else
      superwhisper shortcuts set "$name" "$chord" >/dev/null
      echo "  - set $name shortcut to $chord"
    fi
  done < <(entries shortcut)
else
  echo "  - superwhisper not installed; skipping shortcuts (install with: omarchy install dictation superwhisper)"
fi

# 2. Input-method flags for Chromium and VS Code
while IFS='|' read -r _ file line; do
  path="$HOME/.config/$file"
  if [[ -f $path ]] && grep -qxF -- "$line" "$path"; then
    echo "  - $file already has $line"
  else
    mkdir -p "$(dirname "$path")"
    # Make sure the appended line starts on its own line.
    [[ -s $path && -n $(tail -c1 "$path") ]] && echo >>"$path"
    echo "$line" >>"$path"
    echo "  - added $line to $file"
  fi
done < <(entries flag)

# 3. Keyboard remaps, as a marked block in hypr/input.lua
file="$HOME/.config/hypr/input.lua"
begin="-- BEGIN omarchy-dotfiles: dictation keyboard remap"
end="-- END omarchy-dotfiles: dictation keyboard remap"
base_layout="$(hyprctl getoption input:kb_layout -j | jq -r .str)"
base_options="$(hyprctl getoption input:kb_options -j | jq -r .str)"

devices=""
while IFS='|' read -r _ pattern option; do
  while IFS= read -r name; do
    [[ -n $name ]] || continue
    devices+="hl.device({
  name = \"$name\",
  kb_layout = \"$base_layout\",
  kb_options = \"${base_options:+$base_options,}$option\",
})
"
  done < <(hyprctl devices -j | jq -r --arg p "$pattern" '.keyboards[].name | select(contains($p))')
done < <(entries keyboard)

current=""
[[ -f $file ]] && current="$(awk -v b="$begin" -v e="$end" '$0==b{p=1} p{print} $0==e{p=0}' "$file")"
if [[ ! -f $file ]]; then
  echo "  - $file not found; skipping keyboard remap"
elif [[ -z $devices ]]; then
  if [[ -n $current ]]; then
    echo "  - no matching keyboard connected; keeping the existing remap in input.lua"
  else
    echo "  - no matching keyboard connected; connect it and re-run to add the remap"
  fi
else
  block="$begin
-- Give keyboards without a Right Ctrl one (here: right Command), so holding
-- Right Ctrl for Superwhisper sits where it does on the laptop keyboard.
${devices}$end"
  if [[ $current == "$block" ]]; then
    echo "  - keyboard remap already in input.lua"
  elif [[ -n $current ]]; then
    tmp="$(mktemp)"
    awk -v b="$begin" -v e="$end" -v blk="$block" \
      '$0==b{print blk; skip=1; next} $0==e{skip=0; next} !skip{print}' "$file" >"$tmp"
    cat "$tmp" >"$file" && rm -f "$tmp"
    echo "  - updated keyboard remap in input.lua"
  else
    printf '\n%s\n' "$block" >>"$file"
    echo "  - added keyboard remap to input.lua"
  fi
fi
