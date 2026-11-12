#!/usr/bin/env bash
# Now-playing indicator for py3status (external_script):
# prefer an MPRIS player (via playerctl) if it actually has something to show,
# otherwise fall back to mpd via mpc.
# Line 1 is the text, line 2 the color.

good='#00FF00'
paused='#9999ee'
bad='#FF0000'

# playerctl: only take precedence if some player is playing/paused with a
# nonempty title (e.g. chromium registers an MPRIS player even with no media).
# Prefer a playing player over a paused one.
paused_player=
while read -r player; do
  have_player=1
  [[ -n $(playerctl -p "$player" metadata title 2>/dev/null) ]] || continue
  case $(playerctl -p "$player" status 2>/dev/null) in
  Playing)
    printf '%s\n%s\n' "$(playerctl -p "$player" metadata --format '{{title}}🎵 {{artist}}')" "$good"
    exit 0
    ;;
  Paused) [[ -n $paused_player ]] || paused_player=$player ;;
  esac
done < <(playerctl -l 2>/dev/null)
if [[ -n $paused_player ]]; then
  printf '%s\n%s\n' "$(playerctl -p "$paused_player" metadata --format '{{title}}🎵 {{artist}}')" "$paused"
  exit 0
fi

if mpc_out=$(mpc 2>/dev/null); then
  case $mpc_out in
  *'[playing]'*) color=$good ;;
  *'[paused]'*) color=$paused ;;
  *)
    printf '🎶停止\n%s\n' "$paused"
    exit 0
    ;;
  esac
  printf '%s\n%s\n' "$(mpc current -f '[[%title%🎵 %artist%]|%file%]')" "$color"
elif [[ -n $have_player ]]; then
  printf '🎶停止\n%s\n' "$paused"
else
  printf '🎶關閉\n%s\n' "$bad"
fi
