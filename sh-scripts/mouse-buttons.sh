#!/usr/bin/env bash

set -euo pipefail

if command -v xsetwacom && [[ "$(xsetwacom list devices)" ]]; then
  xsetwacom set "Wacom Intuos S Pen stylus" MapToOutput HEAD-0
  xsetwacom set "Wacom Intuos S Pen stylus" Button 2 "key +ctrl z -ctrl"
  xsetwacom set "Wacom Intuos S Pen stylus" Button 3 "key +ctrl y -ctrl"
  xsetwacom set "Wacom Intuos S Pad pad" Button 2 "key e"
  xsetwacom set "Wacom Intuos S Pad pad" Button 3 "key p"
  xsetwacom set "Wacom Intuos S Pad pad" Button 8 "key v"
  WACOM_ACTIVATED=1
else
  WACOM_ACTIVATED=0
fi

# Left hand mouse
if [ "$1" = h ]; then
  if [ "$WACOM_ACTIVATED" = 1 ]; then
    xsetwacom set "Wacom Intuos S Pen stylus" Button 1 "button +3"
    xsetwacom set "Wacom Intuos S Pad pad" Button 1 "button 1"
  fi
  notify-send -i input-mouse \
    "Left hand mouse" "$(xmodmap -e "pointer = 3 2 1" 2>&1)"
fi

# Right hand mouse
if [ "$1" = l ]; then
  if [ "$WACOM_ACTIVATED" = 1 ]; then
    xsetwacom set "Wacom Intuos S Pen stylus" Button 1 "button +1"
    xsetwacom set "Wacom Intuos S Pad pad" Button 1 "button 3"
  fi
  notify-send -i mousepad \
    "Right hand mouse" "$(xmodmap -e "pointer = 1 2 3" 2>&1)"
fi

# StarCraft mode
if [ "$1" = s ]; then
  xset r rate 150 40 2>&1
  notify-send -i starred "SC2 mode glhf" \
    "$(xmodmap -e "pointer = 1 2 3" 2>&1)\n$"
fi

# Normal mode
if [ "$1" = n ]; then
  xset r rate 660 25 2>&1
  notify-send -i emblem-information "gg no re" \
    "$(xmodmap -e "pointer = 3 2 1" 2>&1)\n$"
fi
