#!/usr/bin/env bash

# lock.sh won't lock either, so don't warn
if ~/dotfiles/sh-scripts/lock/blocker.sh >/dev/null; then
  exit
fi

notify-send -i "alarm-timer" -t 30000 \
  "Lock warning" \
  "The session will automatically lock shortly. Do literally anything to cancel."
