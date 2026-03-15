#!/bin/bash

# Usage: clip-type.sh --primary|--secondary|--clipboard
# Types clipboard contents via xdotool if <= 64 char

contents="$(xsel "$1")"
len="$(printf '%s' "$contents" | wc -c)"

if [ "$len" -gt 64 ]; then
  notify-send -u critical "xsel $1 too long" "Content too long (${len} chars). Refusing to proceed."
  exit 1
fi

if [ "$len" -eq 0 ]; then
  notify-send -u critical "xsel $1 empty" "There is no content to type."
fi

sleep 0.2
xdotool type "$contents"
