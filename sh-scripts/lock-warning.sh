#!/bin/bash

if [ "$(hostname)" = ArchScythe ] && [ "$(whoami)" = evan ]; then
  # during twitch stream, disable laptop lock screen
  if [ "$(date +%u)" -eq 5 ] && [ "$(date +%H)" -ge 20 ]; then
    exit
  fi
  if [ "$(date +%u)" -eq 6 ] && [ "$(date +%H)" -le 2 ]; then
    exit
  fi
fi

notify-send -i timer-symbolic -t 30000 \
  "Lock warning" \
  "The session will automatically lock shortly. Do literally anything to cancel."

#if [ "$(hostname)" = ArchMajestic ] && [ "$(whoami)" = evan ]; then
#	cvlc --play-and-exit "/usr/share/sounds/freedesktop/stereo/complete.oga" vlc://quit
#fi
