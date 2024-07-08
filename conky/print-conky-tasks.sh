#!/bin/bash
set -euo pipefail

if [ "$(whoami)" != "evan" ]; then
  exit
fi
color_num=(8 4 4 5 5 5 6 6 6 6 6 6)

task rc.verbose=nothing rc.gc=off brief | sed -r "s/(^.{32}).*? +([-0-9\.]+)\$/\1 \2/" | sed -r 's/#/\\#/' >~/.cache/todo.txt
for k in {1..12}; do
  if [ "$(wc --lines <~/.cache/todo.txt)" -ge "$k" ]; then
    echo "\${color${color_num[k - 1]}}$(tail ~/.cache/todo.txt -n +"${k}" | head -n 1)"
  fi
done

if [ -f ~/Sync/Personal/dijo/habit_record.json ]; then
  echo "\${color7}$(python ~/dotfiles/conky/dijo-today.py ~/Sync/Personal/dijo/habit_record.json)"
fi
