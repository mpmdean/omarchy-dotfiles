#!/usr/bin/env bash
# Personal Omarchy setup. Each script under scripts/ is a standalone,
# idempotent step - see README.md for what each one does.
#
# Usage: ./install.sh [step ...]   (default: all steps, in order)
#   e.g. ./install.sh install-vpn
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

all_steps=(remove-defaults install-webapps install-themes install-extras set-default-editor install-vpn)
steps=("$@")
[[ ${#steps[@]} -eq 0 ]] && steps=("${all_steps[@]}")

for step in "${steps[@]}"; do
  echo "==> $step"
  ./scripts/"$step".sh
done
