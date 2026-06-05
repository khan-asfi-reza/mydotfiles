#!/usr/bin/env bash

set -euo pipefail

case "$(uname -s)" in
  Darwin)
    DEST="$HOME/Library/Fonts"
    REFRESH=""
    ;;
  Linux)
    DEST="$HOME/.local/share/fonts"
    REFRESH="fc-cache -f"
    ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

mkdir -p "$DEST"

dl() {
  local url="$1" name="$2"
  if [ -e "$DEST/$name" ]; then
    echo "  - $name (skip, already installed)"
    return
  fi
  echo "  + $name"
  curl -fsSL -o "$DEST/$name" "$url"
}

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "missing: $1" >&2; exit 1; }
}

need curl
need unzip

echo "==> MesloLGS NF (from powerlevel10k-media)"
P10K="https://github.com/romkatv/powerlevel10k-media/raw/master"
dl "$P10K/MesloLGS%20NF%20Regular.ttf"      "MesloLGS NF Regular.ttf"
dl "$P10K/MesloLGS%20NF%20Bold.ttf"         "MesloLGS NF Bold.ttf"
dl "$P10K/MesloLGS%20NF%20Italic.ttf"       "MesloLGS NF Italic.ttf"
dl "$P10K/MesloLGS%20NF%20Bold%20Italic.ttf" "MesloLGS NF Bold Italic.ttf"

echo "==> Hack Nerd Font (from ryanoasis/nerd-fonts release)"
if [ ! -e "$DEST/HackNerdFont-Regular.ttf" ]; then
  TMP="$(mktemp -d)"
  curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip" -o "$TMP/Hack.zip"
  unzip -q "$TMP/Hack.zip" -d "$TMP/Hack"
  cp "$TMP/Hack"/*.ttf "$DEST/"
  rm -rf "$TMP"
  echo "  + Hack Nerd Font (full set)"
else
  echo "  - Hack Nerd Font (skip, already installed)"
fi

if [ -n "$REFRESH" ]; then
  echo "==> refreshing font cache"
  $REFRESH
fi

echo "done. dest=$DEST"
