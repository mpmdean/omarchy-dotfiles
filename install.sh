#!/usr/bin/env bash
# Personal Omarchy setup: remove unwanted default apps, install extra
# themes, install extra tools. See README.md for details on each step.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

usage() {
  cat <<EOF
Usage: $0 [--remove] [--themes] [--extras] [--editor] [--vpn] [--all] [--yes]

  --remove   Remove default apps listed in data/remove.txt (Basecamp, xournalpp)
  --themes   Install extra themes listed in data/themes.txt
  --extras   Install extra tools listed in data/extras.txt (hyprmoncfg)
  --editor   Set the default editor from data/editor.txt (code)
  --vpn      Install the BNL VPN toggle + SUPER+SHIFT+V keybinding
             (pulls the private mpmdean/VPN_helper repo; needs sudo)
  --all      Do all of the above
  --yes      Skip the confirmation prompt
EOF
}

do_remove=false
do_themes=false
do_extras=false
do_editor=false
do_vpn=false
assume_yes=false

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

for arg in "$@"; do
  case "$arg" in
  --remove) do_remove=true ;;
  --themes) do_themes=true ;;
  --extras) do_extras=true ;;
  --editor) do_editor=true ;;
  --vpn) do_vpn=true ;;
  --all)
    do_remove=true
    do_themes=true
    do_extras=true
    do_editor=true
    do_vpn=true
    ;;
  --yes) assume_yes=true ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $arg" >&2
    usage
    exit 1
    ;;
  esac
done

echo "This will:"
$do_remove && echo "  - remove default apps in data/remove.txt"
$do_themes && echo "  - install extra themes in data/themes.txt"
$do_extras && echo "  - install extra tools in data/extras.txt"
$do_editor && echo "  - set the default editor from data/editor.txt"
$do_vpn && echo "  - install the BNL VPN toggle + keybinding (sudo required)"
echo

if ! $assume_yes; then
  read -r -p "Continue? [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
fi

$do_remove && ./scripts/remove-defaults.sh
$do_themes && ./scripts/install-themes.sh
$do_extras && ./scripts/install-extras.sh
$do_editor && ./scripts/set-default-editor.sh
$do_vpn && ./scripts/install-vpn.sh

echo "==> Done."
