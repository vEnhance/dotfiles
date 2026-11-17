#!/bin/bash
# Install gh CLI extensions that aren't already installed.
# To upgrade later: ./UPGRADE.sh

set -euo pipefail
# shellcheck source=installers/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Script extensions: cloned directly over https, since `gh extension install`
# would clone with git_protocol (ssh), which hangs on a locked SSH key.
SCRIPT_EXTENSIONS=(
  meiji163/gh-notify
  vEnhance/gh-done
  vEnhance/gh-link
)
# Binary extensions: gh downloads a release asset, no git involved.
BINARY_EXTENSIONS=(
  yusukebe/gh-markdown-preview
)

if ! command -v gh >/dev/null; then
  warn "gh not found, not installing extensions"
  exit 0
fi

ext_dir="${XDG_DATA_HOME:-$HOME/.local/share}/gh/extensions"
mkdir -p "$ext_dir"

for ext in "${SCRIPT_EXTENSIONS[@]}"; do
  target="$ext_dir/${ext#*/}"
  [[ -e "$target" ]] && continue
  echo -e "${BOLD_GRN}INSTALL:${RESET} gh extension $ext"
  git clone --quiet "https://github.com/$ext" "$target"
done

for ext in "${BINARY_EXTENSIONS[@]}"; do
  [[ -e "$ext_dir/${ext#*/}" ]] && continue
  echo -e "${BOLD_GRN}INSTALL:${RESET} gh extension $ext"
  gh extension install "$ext"
done
