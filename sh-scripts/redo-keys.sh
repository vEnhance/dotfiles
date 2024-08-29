#!/usr/bin/env bash

# Make sure we're in Dvorak
setxkbmap us -variant dvorak -option caps:escape
numlockx on
if [ "$(hostname)" = ArchScythe ] || [ "$(hostname)" = ArchSapphire ]; then
  synclient VertScrollDelta=-237
fi

# In case we're at home with that one keyboard that has no tilde key...
usb_out=$(lsusb)
if [ "$(date +'%Z')" = "PDT" ] || [ "$(date +'%Z')" = "PST" ]; then
  if [ "$(hostname)" = ArchDiamond ] && grep "Logitech, Inc. Unifying Receiver" <<<"$usb_out"; then
    xmodmap -e "keycode  9 = grave asciitilde grave asciitilde dead_grave dead_tilde dead_grave"
  fi
fi

if [ "$(hostname)" = ArchSapphire ]; then
  # replace the useless menu key with extra ctrl
  xmodmap -e "remove Control = Control_R"
  xmodmap -e "keycode 135 = Control_R Control_R Control_R Control_R"
  xmodmap -e "add Control = Control_R"
fi

# if caps lock is on, kill it
if [ "$(xset -q | sed -n 's/^.*Caps Lock:\s*\(\S*\).*$/\1/p')" = "on" ]; then
  echo "OH NO CAPS LOCK IS ON AAAAAAAA"
  xdotool key Caps_Lock
  if [ "$(xset -q | sed -n 's/^.*Caps Lock:\s*\(\S*\).*$/\1/p')" = "off" ]; then
    echo "OK we turned it off, phew"
  else
    echo "씨발!"
    notify-send -u critical -t 5000 "Turn off caps lock!"
    exit 1
  fi
fi

xmodmap -e "remove lock = Caps_Lock"
notify-send -i "devices/input-keyboard-symbolic" -t 5000 \
  "Rebound complete" \
  "Successfully ran redo-keys.sh. Enjoy!"

# synclient TapButton1=0           # Disable tap to click
# synclient TapButton2=0           # Disable double tap to paste
# synclient RightButtonAreaRight=1 # Remap mouse buttons
