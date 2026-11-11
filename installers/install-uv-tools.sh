#!/bin/bash
# Install Python CLI tools with `uv tool` that aren't already installed.
# These are PyPI apps whose AUR packages I don't maintain and that lag behind,
# so uv gets them from PyPI in isolated venvs under ~/.local/share/uv/tools.
# To upgrade later: uv tool upgrade --all

set -euo pipefail
# shellcheck source=installers/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

TOOLS=(
  djlint # conform.nvim formatter for htmldjango
)

if ! command -v uv >/dev/null; then
  warn "uv not found, not installing uv tools"
  exit 0
fi

# `uv tool list` prints "name vX.Y.Z" followed by "- executable" lines.
installed="$(uv tool list 2>/dev/null | awk '!/^-/ {print $1}')"
for tool in "${TOOLS[@]}"; do
  if grep -qxF "$tool" <<<"$installed"; then
    continue
  fi
  echo -e "${BOLD_GRN}INSTALL:${RESET} uv tool $tool"
  uv tool install "$tool"
done

bin_dir="$(uv tool dir --bin)"
case ":$PATH:" in
*":$bin_dir:"*) ;;
*) echo -e "${BOLD_YLW}WARNING:${RESET} $bin_dir is not on PATH" ;;
esac
