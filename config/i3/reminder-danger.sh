#!/usr/bin/env bash
#
notify-send "i3: danger mode" -i uninterruptible-power-supply \
  -t 2000 \
  -u low \
  "<b>e</b>: exit (logout)
<b>n</b>: suspend
<b>p</b>: power off
<b>z</b>: reboot
<b>x</b>: xrandr"
