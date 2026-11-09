#!/bin/bash
# Install gh CLI extensions that aren't already installed.
# To upgrade later: gh extension upgrade --all

set -euo pipefail
# shellcheck source=installers/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

EXTENSIONS=(
  meiji163/gh-notify
  vEnhance/gh-done
  vEnhance/gh-link
  yusukebe/gh-markdown-preview
)

if ! command -v gh >/dev/null; then
  warn "gh not found, not installing extensions"
  exit 0
fi

installed="$(gh extension list)"
for ext in "${EXTENSIONS[@]}"; do
  if grep -qiF "$ext" <<<"$installed"; then
    continue
  fi
  echo -e "${BOLD_GRN}INSTALL:${RESET} gh extension $ext"
  gh extension install "$ext"
done
