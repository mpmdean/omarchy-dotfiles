#!/usr/bin/env bash
# Sets the Omarchy default editor (used by omarchy-launch-editor / $EDITOR)
# from data/editor.txt.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

editor="$(grep -v '^#' data/editor.txt | grep -v '^\s*$' | head -1)"
current="$(omarchy-default-editor)"

echo "==> Setting default editor"

if [[ "$current" == "$editor" ]]; then
  echo "  - already set to $editor"
else
  omarchy-default-editor "$editor"
fi
