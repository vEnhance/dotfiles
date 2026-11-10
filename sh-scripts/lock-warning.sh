#!/usr/bin/env bash

# fuzzy-lock.sh won't lock during a stream, so don't warn either
if ~/dotfiles/sh-scripts/is-streaming.sh; then
  exit
fi

if [ "$(whoami)" = star ] && pgrep -U star -x obs >/dev/null; then
  exit
fi

notify-send -i "alarm-timer" -t 30000 \
  "Lock warning" \
  "The session will automatically lock shortly. Do literally anything to cancel."
