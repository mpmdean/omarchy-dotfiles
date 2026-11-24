#!/usr/bin/env bash
# Creates (or updates) the `main` conda environment from data/conda-main.yml.
# Installs Miniforge into ~/miniforge3 first, from the official installer
# (github.com/conda-forge/miniforge), if no conda is there yet. No root needed.
# An existing env is updated in place: missing packages are added, nothing
# you installed yourself is removed.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

ENV_FILE="data/conda-main.yml"
PREFIX="$HOME/miniforge3"
CONDA="$PREFIX/condabin/conda"
ENV_NAME="$(sed -n 's/^name:[[:space:]]*//p' "$ENV_FILE")"

echo "==> Setting up the '$ENV_NAME' conda environment"

if [[ -x "$CONDA" ]]; then
  echo "  - Miniforge already installed in $PREFIX"
else
  installer="Miniforge3-Linux-$(uname -m).sh"
  url="https://github.com/conda-forge/miniforge/releases/latest/download/$installer"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  echo "  - downloading $url"
  curl -fL --proto '=https' -o "$tmp/$installer" "$url"
  curl -fL --proto '=https' -o "$tmp/$installer.sha256" "$url.sha256"
  (cd "$tmp" && sha256sum -c "$installer.sha256")
  bash "$tmp/$installer" -b -p "$PREFIX"
  echo "  - installed Miniforge to $PREFIX"
  echo "    To get 'conda activate' in your shell, run: $CONDA init bash"
fi

if "$CONDA" env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
  echo "  - env '$ENV_NAME' exists, updating from $ENV_FILE"
  "$CONDA" env update -n "$ENV_NAME" -f "$ENV_FILE"
else
  echo "  - creating env '$ENV_NAME' from $ENV_FILE"
  "$CONDA" env create -f "$ENV_FILE"
fi

echo "    Use it with: conda activate $ENV_NAME"
