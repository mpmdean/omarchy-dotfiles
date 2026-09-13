#!/usr/bin/env bash
# Installs the BNL VPN toggle: pulls the user-side script, the privileged
# helper, and the sudoers rule from the private mpmdean/VPN_helper repo, then
# wires up the SUPER+SHIFT+V Hyprland keybinding. Requires sudo (for the
# root-owned helper + sudoers rule) and access to the private VPN_helper repo
# (works out of the box if `gh auth status` is logged in, since gh is set up
# as the git credential helper).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

REPO_URL="https://github.com/mpmdean/VPN_helper.git"
CACHE_DIR="$HOME/.cache/omarchy-dotfiles/VPN_helper"
BINDINGS_FILE="$HOME/.config/hypr/bindings.lua"

echo "==> Installing BNL VPN helper"

if [[ -d "$CACHE_DIR/.git" ]]; then
  git -C "$CACHE_DIR" pull --ff-only
else
  mkdir -p "$(dirname "$CACHE_DIR")"
  git clone "$REPO_URL" "$CACHE_DIR"
fi

bash "$CACHE_DIR/install.sh"

echo "==> Wiring up the Hyprland keybinding"
if [[ -f "$BINDINGS_FILE" ]] && grep -q "Toggle BNL VPN" "$BINDINGS_FILE"; then
  echo "  - keybinding already present in $BINDINGS_FILE"
else
  {
    echo
    cat "$CACHE_DIR/hypr-bindings.lua"
  } >>"$BINDINGS_FILE"
  echo "  - appended to $BINDINGS_FILE"
  if command -v hyprctl &>/dev/null && hyprctl reload &>/dev/null; then
    echo "  - reloaded Hyprland config"
  fi
fi

cat <<'EOF'

Next (one-time, as your normal user - never store these in a repo):
  secret-tool store --label='BNL VPN username' service bnl-vpn field username
  secret-tool store --label='BNL VPN password' service bnl-vpn field password

Then press SUPER+SHIFT+V to connect/disconnect.
EOF
