#!/usr/bin/env bash

set -euo pipefail

contents="$(xsel --clipboard | ~/dotfiles/py-scripts/uclean.py)"

mkdir -p /tmp/clipboard/
printf '%s\n' "$contents" | tee "/tmp/clipboard/$(date --iso-8601=seconds)" | xsel --clipboard

notify-send -u low -i "xclipboard" "xsel --clipboard" "${contents:0:160}"
