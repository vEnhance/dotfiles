#!/bin/bash

set -o xtrace

# getting locked out in US keyboard is the worst
setxkbmap dvorak -option caps:escape

if pgrep -U "$(whoami)" i3lock >/dev/null; then
  echo "Already running"
  exit
fi

if pgrep -U "$(whoami)" stepmania >/dev/null; then
  echo "Stepmania running"
  # xset s off -dpms # don't blank screen if stepmania is running
  exit
fi

if pgrep -U "$(whoami)" zoom >/dev/null; then
  echo "Zoom running"
  exit
fi

# during twitch stream, disable laptop lock screen
if [ "$(hostname)" = ArchScythe ] && [ "$(whoami)" = evan ]; then
  if iwconfig | grep Flying; then
    if python ~/dotfiles/py-scripts/query-twitch-online.py vEnhance -s -q; then
      notify-send "Won't lock" "You're currently streaming on Twitch"
      exit
    fi
  fi
fi

if [ "$(hostname)" = ArchMajestic ] && [ "$(whoami)" = evan ]; then
  xset dpms 10 0 0
  ~/dotfiles/sh-scripts/paswitch.sh speakers
fi

if [ "$(hostname)" = ArchBootes ] && [ "$(whoami)" = evan ]; then
  xset dpms 10 0 0
  ~/dotfiles/sh-scripts/paswitch.sh speakers
fi

if [ "$(hostname)" = ArchDiamond ] && [ "$(whoami)" = evan ]; then
  xset dpms 10 0 0
fi

# mute microphone so I'm not recorded while afk
ponymix -t source mute >/dev/null

# clear the clipboards for security reasons
xsel --clipboard --delete
xsel --primary --delete
xsel --secondary --delete

dunstctl set-paused true

#################################################
# RUN THE LOCKER
#################################################

if [ "$(hostname)" = ArchAir ] && [ "$(whoami)" = evan ]; then
  xset dpms force off
  i3lock \
    --beep \
    --ignore-empty-password \
    --show-failed-attempts \
    --nofork \
    --color=000000
elif pacman -Q --quiet i3lock-color; then
  export LANG=zh_TW.UTF-8
  i3lock \
    --insidever-color=0a220a66 \
    --ringver-color=0a550aee \
    --insidewrong-color=efaaaabb --ringwrong-color=ef0a0aff \
    --inside-color=00000000 \
    --ring-color=dd0add66 \
    --line-color=0a0a0aff \
    --separator-color=ff66ff44 \
    --verif-color=efefef77 \
    --wrong-color=efefefff \
    --modif-color=efefef99 \
    --time-color=aa33aabb \
    --date-color=aa33aabb \
    --layout-color=dededebb \
    --keyhl-color=dd888899 \
    --bshl-color=dd888899 \
    --keylayout 2 \
    --radius 324 \
    --ring-width 32 \
    --date-str="%A %Y年%b%d日" \
    --time-size=48 \
    --date-size=36 \
    --layout-size=36 \
    --verif-size=64 \
    --wrong-size=64 \
    --modif-size=36 \
    --time-str="%R%Z" \
    --ind-pos="x+0.5*w:y+0.4*h" \
    --date-pos="ix:iy-0.4*r" \
    --wrong-pos="ix:iy-0.1*r" \
    --verif-pos="ix:iy-0.1*r" \
    --modif-pos="ix:iy+0.1*r" \
    --time-pos="ix:iy+0.4*r" \
    --layout-pos="ix:iy+1.3*r" \
    --color 111117dd \
    --show-failed-attempts \
    --ignore-empty-password \
    --nofork
else
  i3lock \
    --beep \
    --ignore-empty-password \
    --show-failed-attempts \
    --nofork \
    --color=d33529 \
    --pointer=win
fi

#################################################
# POST LOCK CLEANUP
#################################################

dunstctl set-paused false

if [ "$(hostname)" = ArchMajestic ] && [ "$(whoami)" = evan ]; then
  xset dpms 900 900 900
fi
if [ "$(hostname)" = ArchBootes ] && [ "$(whoami)" = evan ]; then
  xset dpms 900 900 900
fi
if [ "$(hostname)" = ArchDiamond ] && [ "$(whoami)" = evan ]; then
  xset set 14400 14400
  xset dpms 14400 14400 14400
fi

if [ "$(hostname)" = ArchMajestic ]; then
  ~/dotfiles/sh-scripts/paswitch.sh speakers
fi
if [ "$(hostname)" = Endor ]; then
  ~/dotfiles/sh-scripts/paswitch.sh speakers
fi

if pgrep -U "$(whoami)" py3status >/dev/null; then
  killall -s USR1 py3status
fi
