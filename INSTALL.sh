#!/bin/bash

# Use at your own risk ;)
# Runs each script in installers/; they can also be run on their own.

set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/installers"
# shellcheck source=installers/lib.sh
source "$dir/lib.sh"

for name in make-symlinks set-xdg-defaults install-gh-ext install-uv-tools check-packages; do
  echo -e "${BOLD_MAG}==>${RESET} $name"
  "$dir/$name.sh"
done
