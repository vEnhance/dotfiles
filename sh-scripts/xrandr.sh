#!/bin/bash

if [ "$(hostname)" = ArchAngel ]; then
  if xrandr | grep 1920x1080; then
    xrandr --output "HDMI-2" --primary 1920x1080
  else
    xrandr --output "HDMI-2" --primary
  fi
fi

if [ "$(hostname)" = ArchDiamond ]; then
  if [ "$(date +'%Z')" = "EDT" ] || [ "$(date +'%Z')" = "EST" ]; then
    xrandr --output "DP-3" --mode 3840x2160 --primary
  else
    xrandr \
      --output "DP-1" --mode 2560x1440 --primary \
      --output "DP-3" --mode 1920x1080 --left-of "DP-1" \
      --output "DP-2" --mode 1440x900 --right-of "DP-1" \
      ;
  fi
fi

if [ "$(hostname)" = ArchMajestic ]; then
  xrandr \
    --output "DP-0" --primary \
    --output "DP-4" --left-of "DP-0" \
    --output "DP-2" --right-of "DP-0" \
    --output "HDMI-0" --right-of "DP-2" \
    ;
fi

if [ "$(hostname)" = ArchBootes ]; then
  xrandr \
    --output HDMI-0 --mode 1920x1080 --pos 0x0 --rotate normal \
    --output DP-2 --primary --mode 2560x1440 --pos 1920x0 --rotate normal \
    --output DP-0 --mode 2560x1440 --pos 4480x0 --rotate normal \
    --output DP-4 --mode 2560x1440 --pos 7040x0 \
    ;
fi

if [ "$(hostname)" = dagobah ]; then
  xrandr \
    --output "DP-2" --primary \
    --output "DP-4" --right-of "DP-2" \
    --output "HDMI-0" --left-of "DP-2" \
    ;
fi
