#!/usr/bin/env bash
# Launch flameshot's region selector on the monitor under the cursor, skipping
# flameshot's multi-monitor screen-picker. Passing an explicit `screen -n <idx>`
# bypasses the picker; `--edit` still lets you select/adjust a region within it.
set -euo pipefail

eval "$(xdotool getmouselocation --shell)"  # sets X and Y

# Find the flameshot/xrandr screen index whose rectangle contains the cursor.
# `xrandr --listactivemonitors` index order matches flameshot's `-n` order.
idx=$(xrandr --listactivemonitors | tail -n +2 | while read -r num _ res _; do
  num=${num%:}                  # 0
  wh=${res%%+*}                 # 2880/331x1800/207
  off=${res#"$wh"}              # +1920+0
  w=${wh%%/*}                   # 2880
  h=${wh#*x}; h=${h%%/*}        # 1800
  off=${off#+}; mx=${off%%+*}   # 1920
  my=${off#*+}                  # 0
  if (( X >= mx && X < mx + w && Y >= my && Y < my + h )); then
    echo "$num"
    break
  fi
done)

exec flameshot screen -n "${idx:-0}" --edit
