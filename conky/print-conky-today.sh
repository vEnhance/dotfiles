#!/usr/bin/env bash
set -euo pipefail

if [ "$(whoami)" != "evan" ]; then
  exit
fi
color_num=(9 8 4 5 6)

for k in {1..5}; do
  if [ "$(wc --lines <~/.cache/agenda_today.txt)" -ge "$k" ]; then
    echo "\${color${color_num[k - 1]}}$(tail ~/.cache/agenda_today.txt -n +"${k}" | head -n 1)"
  fi
done
