#!/bin/bash

# Use at your own risk ;)
# Runs each script in installers/; they can also be run on their own.

set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/installers"

for name in make-symlinks set-xdg-defaults install-gh-ext check-packages; do
  echo -e "\033[1;35m==>\033[0m $name"
  "$dir/$name.sh"
done
