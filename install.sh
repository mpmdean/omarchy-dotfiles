#!/usr/bin/env bash
# Personal Omarchy setup: remove unwanted default apps, install extra
# themes, install extra tools. See README.md for details on each step.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

usage() {
  cat <<EOF
Usage: $0 [--remove] [--themes] [--extras] [--all] [--yes]

  --remove   Remove default apps listed in data/remove.txt (Basecamp, xournalpp)
  --themes   Install extra themes listed in data/themes.txt
  --extras   Install extra tools listed in data/extras.txt (hyprmoncfg)
  --all      Do all of the above
  --yes      Skip the confirmation prompt
EOF
}

do_remove=false
do_themes=false
do_extras=false
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
  --all)
    do_remove=true
    do_themes=true
    do_extras=true
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
echo

if ! $assume_yes; then
  read -r -p "Continue? [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
fi

$do_remove && ./scripts/remove-defaults.sh
$do_themes && ./scripts/install-themes.sh
$do_extras && ./scripts/install-extras.sh

echo "==> Done."
