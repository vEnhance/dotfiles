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

notify-send -i "status/timer-symbolic" -t 30000 \
  "Lock warning" \
  "The session will automatically lock shortly. Do literally anything to cancel."
