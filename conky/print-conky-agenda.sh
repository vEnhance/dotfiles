#!/bin/bash
set -euo pipefail

if [ "$(whoami)" != "evan" ]; then
  exit
fi
color_num=(8 4 4 5 5 5 6 6 6 6 6 6)

python ~/dotfiles/conky/gcal-json-to-text.py ~/.cache/agenda.txt <"$HOME"/.cache/agenda.json
for k in {1..12}; do
  if [ "$(wc --lines <~/.cache/agenda.txt)" -ge "$k" ]; then
    echo "\${color${color_num[k - 1]}}$(tail ~/.cache/agenda.txt -n +"${k}" | head -n 1)"
  fi
done
