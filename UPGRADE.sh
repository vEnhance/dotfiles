#!/bin/bash

# Upgrade the tools that installers/ only install-if-missing.

set -euo pipefail
# shellcheck source=installers/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/installers/lib.sh"

echo -e "\033[1;35m==>\033[0m gh extensions"
if command -v gh >/dev/null; then
  gh extension upgrade --all
else
  warn "gh not found, not upgrading extensions"
fi

echo -e "\033[1;35m==>\033[0m uv tools"
if command -v uv >/dev/null; then
  uv tool upgrade --all
else
  warn "uv not found, not upgrading uv tools"
fi
