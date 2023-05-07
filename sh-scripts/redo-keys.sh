#!/bin/sh

# Make sure we're in Dvorak
setxkbmap dvorak -option caps:escape
numlockx on
if [ "$(hostname)" = ArchScythe ] || [ "$(hostname)" = ArchSapphire ]; then
  synclient VertScrollDelta=-237
fi

# if caps lock is on, kill it
if [ "$(xset -q | sed -n 's/^.*Caps Lock:\s*\(\S*\).*$/\1/p')" = "on" ]; then
  echo "OH NO CAPS LOCK"
  xdotool key Caps_Lock
  if [ "$(xset -q | sed -n 's/^.*Caps Lock:\s*\(\S*\).*$/\1/p')" = "off" ]; then
    echo "OK we turned it off, phew"
  else
    echo "FUCK!"
    notify-send -u critical -t 5000 "Turn off caps lock!"
    exit 1
  fi
fi

xmodmap -e "remove lock = Caps_Lock"

# synclient TapButton1=0           # Disable tap to click
# synclient TapButton2=0           # Disable double tap to paste
# synclient RightButtonAreaRight=1 # Remap mouse buttons
