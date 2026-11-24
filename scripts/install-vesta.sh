#!/usr/bin/env bash
# Installs VESTA the way https://jp-minerals.org/vesta/en/download.html
# describes: the official stable Linux x86_64 GTK3 tarball, unpacked into
# ~/.local/opt/VESTA-gtk3, with `vesta`/`VESTA` symlinks in ~/.local/bin and a
# desktop entry so it shows up in the app launcher. No root needed.
# Skips the download if VESTA is already unpacked there (VESTA keeps its own
# settings, e.g. VESTA.ini, inside that folder, so it is never overwritten).
set -euo pipefail

VERSION="3.5.8"
URL="https://jp-minerals.org/vesta/archives/${VERSION}/VESTA-gtk3.tar.bz2"
INSTALL_DIR="$HOME/.local/opt/VESTA-gtk3"
BIN_DIR="$HOME/.local/bin"
DESKTOP_FILE="$HOME/.local/share/applications/vesta.desktop"

echo "==> Installing VESTA ${VERSION} (GTK3 build, needs GTK >= 3.22)"

if [[ -x "$INSTALL_DIR/VESTA" ]]; then
  echo "  - already unpacked in $INSTALL_DIR"
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  echo "  - downloading $URL"
  curl -fL --proto '=https' -o "$tmp/VESTA-gtk3.tar.bz2" "$URL"
  mkdir -p "$tmp/extract"
  tar -xjf "$tmp/VESTA-gtk3.tar.bz2" -C "$tmp/extract"
  src="$(dirname "$(find "$tmp/extract" -maxdepth 2 -type f -name VESTA -print -quit)")"
  if [[ -z "$src" || ! -x "$src/VESTA" ]]; then
    echo "  ! VESTA executable not found in the tarball" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$INSTALL_DIR")"
  mv "$src" "$INSTALL_DIR"
  echo "  - unpacked to $INSTALL_DIR"
fi

mkdir -p "$BIN_DIR"
ln -sfn "$INSTALL_DIR/VESTA" "$BIN_DIR/vesta"
ln -sfn "$INSTALL_DIR/VESTA" "$BIN_DIR/VESTA"
echo "  - linked $BIN_DIR/vesta and $BIN_DIR/VESTA"

mkdir -p "$(dirname "$DESKTOP_FILE")"
cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=VESTA
Comment=Visualization for Electronic and Structural Analysis
Exec=$INSTALL_DIR/VESTA %F
Icon=$INSTALL_DIR/img/logo@2x.png
Terminal=false
Categories=Science;Education;
MimeType=chemical/x-cif;
EOF
echo "  - wrote $DESKTOP_FILE"
command -v update-desktop-database &>/dev/null &&
  update-desktop-database "$(dirname "$DESKTOP_FILE")" &>/dev/null || true
