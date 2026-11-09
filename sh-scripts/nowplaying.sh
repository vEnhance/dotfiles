#!/usr/bin/env bash
# Now-playing indicator for py3status (external_script):
# prefer any MPRIS player (via playerctl), otherwise fall back to mpd via mpc.
# Line 1 is the text, line 2 the color.

good='#00FF00'
paused='#9999ee'
bad='#FF0000'

if status=$(playerctl status 2>/dev/null); then
  case $status in
  Playing) color=$good ;;
  Paused) color=$paused ;;
  *)
    printf '🎶停止\n%s\n' "$paused"
    exit 0
    ;;
  esac
  printf '%s\n%s\n' "$(playerctl metadata --format '{{title}}🎵 {{artist}}')" "$color"
elif mpc_out=$(mpc 2>/dev/null); then
  case $mpc_out in
  *'[playing]'*) color=$good ;;
  *'[paused]'*) color=$paused ;;
  *)
    printf '🎶停止\n%s\n' "$paused"
    exit 0
    ;;
  esac
  printf '%s\n%s\n' "$(mpc current -f '[[%title%🎵 %artist%]|%file%]')" "$color"
else
  printf '🎶關閉\n%s\n' "$bad"
fi
