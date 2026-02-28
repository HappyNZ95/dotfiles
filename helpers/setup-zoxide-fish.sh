#!/usr/bin/env bash
set -euo pipefail

BIN="$HOME/.local/bin"
FISH_CONF_DIR="$HOME/.config/fish/conf.d"
ZOXIDE_CONF="$FISH_CONF_DIR/zoxide.fish"

echo "==> Ensuring directories"
mkdir -p "$BIN"
mkdir -p "$FISH_CONF_DIR"

install_zoxide() {
  if command -v zoxide >/dev/null 2>&1; then
    echo "zoxide already installed"
    return
  fi

  echo "==> Installing zoxide"

  # Arch/CachyOS path (preferred)
  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm zoxide
  else
    # portable fallback
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi
}

configure_fish_path() {
  echo "==> Ensuring Fish PATH contains ~/.local/bin"
  fish -c "fish_add_path -m $BIN" || true
}

configure_zoxide() {
  echo "==> Generating Fish integration (cd replacement)"

  # --cmd cd replaces cd safely (not alias)
  zoxide init fish --cmd cd >"$ZOXIDE_CONF"
}

main() {
  install_zoxide
  configure_fish_path
  configure_zoxide

  echo
  echo "Done."
  echo "Restart Fish or run: exec fish"
  echo "Now 'cd' uses zoxide smart jumping."
}

main
