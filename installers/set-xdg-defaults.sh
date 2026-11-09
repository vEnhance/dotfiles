#!/bin/bash
# Set default applications via xdg-settings.

set -euo pipefail
# shellcheck source=installers/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

if [ "$USER" != "evan" ]; then
  warn "xdg defaults only set for evan"
  exit 0
fi

xdg-settings set default-web-browser firefox.desktop
xdg-settings set default-url-scheme-handler https firefox.desktop
