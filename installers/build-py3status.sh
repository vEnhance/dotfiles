#!/bin/bash
# Build py3status modules and link the host-dependent config.

set -euo pipefail
# shellcheck source=installers/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cd "$DOTFILES/py3status"
if ! make -q 2>/dev/null; then
  make
fi

case "$USER" in
evan) conf="py3status.$(hostname).conf" ;;
star) conf="py3status.star.conf" ;;
*)
  warn "no py3status config for user $USER"
  exit 0
  ;;
esac
mkdir -p "$HOME/.config/py3status"
ln -sf "$DOTFILES/py3status/$conf" "$HOME/.config/py3status/config"
