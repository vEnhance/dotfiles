#!/usr/bin/env bash

# Checks whether $1 (an xrandr output name) lists $2 (a resolution like
# 3840x2160) among its supported modes.
xrandr_output_supports_mode() {
  xrandr --query | awk -v out="$1" -v mode="$2" '
    $0 ~ "^"out" " { found=1; next }
    /^[A-Za-z]/ { found=0 }
    found && $1 == mode { ok=1 }
    END { exit !ok }
  '
}

if [ "$(hostname)" = ArchDiamond ]; then
  if xrandr_output_supports_mode DP-2 3840x2160; then
    xrandr --output "DP-2" --mode 3840x2160 --primary \
      --output "DP-3" --mode 1920x1080 --below "DP-2" \
      --output "DP-1" --mode 2560x1440 --right-of "DP-2"
  else
    xrandr --output "DP-2" --auto --primary \
      --output "DP-3" --auto --below "DP-2" \
      --output "DP-1" --auto --right-of "DP-2"
  fi
fi

if [ "$(hostname)" = ArchUmi ]; then
  xrandr --output "eDP-1" --mode 2880x1800 --primary \
    --output "DP-1" --auto --left-of "eDP-1"
fi

if [ "$(hostname)" = ArchScythe ]; then
  xrandr --output "eDP1" --mode 1920x1080 --primary \
    --output "HDMI1" --auto --left-of "eDP1"
fi

if [ "$(hostname)" = ArchMajestic ]; then
  xrandr \
    --output "DP-0" --primary \
    --output "DP-4" --left-of "DP-0" \
    --output "DP-2" --right-of "DP-0" \
    --output "HDMI-0" --left-of "DP-4" \
    ;
fi

if [ "$(hostname)" = ArchBootes ]; then
  xrandr \
    --output HDMI-0 --mode 1920x1080 --pos 0x2160 --rotate normal \
    --output DP-2 --primary --mode 3840x2160 --pos 0x0 --rotate normal \
    --output DP-0 --mode 2560x1440 --pos 3840x0 --rotate normal \
    --output DP-4 --mode 2560x1440 --pos 7040x0 \
    ;
fi

# Load background image, if not existent already
# shellcheck source=/dev/null
[[ -f ~/.fehbg ]] && source ~/.fehbg
