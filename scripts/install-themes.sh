#!/usr/bin/env bash
# Installs the extra themes listed in data/themes.txt into
# ~/.config/omarchy/themes, without disturbing whichever theme is currently
# active (omarchy-theme-install activates every theme it installs, so we
# restore the original one at the end).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

THEMES_DIR="$HOME/.config/omarchy/themes"
DATA_FILE="data/themes.txt"

echo "==> Installing extra Omarchy themes"

original_theme="$(omarchy-theme-current 2>/dev/null || true)"

while IFS='|' read -r name url; do
  line="$name"
  line="${line%%#*}"
  [[ -z "${line// /}" ]] && continue
  [[ -z "$url" ]] && continue

  if [[ -d "$THEMES_DIR/$name" ]]; then
    echo "  - already installed: $name"
    continue
  fi
  echo "  - installing: $name  ($url)"
  omarchy-theme-install "$url"
done <"$DATA_FILE"

# seashells / seashells-light: the repo's own installer only downloads a
# fixed, reviewed list of theme files (see the setup script at
# https://github.com/odysseyalive/omarchy-seashells-theme/blob/main/setup),
# unlike a full `git clone` of that repo, which also drags in a bundled
# .claude/skills/ directory (a third-party "Claude Enforcer" agent/skill
# framework with its own executable hooks) that has nothing to do with the
# theme and gets silently picked up as ambient Claude Code skills. Using
# their installer avoids that; the rm -rf below is a defensive backstop in
# case that ever changes, or in case an older full clone is still present.
if [[ ! -d "$THEMES_DIR/seashells" || ! -d "$THEMES_DIR/seashells-light" ]]; then
  echo "  - installing: seashells + seashells-light"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/odysseyalive/omarchy-seashells-theme/main/setup)"
else
  echo "  - already installed: seashells, seashells-light"
fi
rm -rf "$THEMES_DIR/seashells/.claude" "$THEMES_DIR/seashells-light/.claude"

if [[ -n "$original_theme" ]]; then
  echo "==> Restoring original active theme: $original_theme"
  omarchy-theme-set "$(echo "$original_theme" | tr '[:upper:]' '[:lower:]')"
fi
