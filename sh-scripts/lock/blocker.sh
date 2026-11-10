#!/usr/bin/env bash
# Single source of "don't auto-lock right now" reasons, used by lock.sh,
# warning.sh and countdown.sh. If something is blocking the lock,
# prints a short reason and exits 0; otherwise exits 1.

me=$(whoami)

if pgrep -U "$me" stepmania >/dev/null; then
  echo "StepMania"
  exit 0
fi

if xdotool search --name '^Zoom Meeting$' >/dev/null 2>&1; then
  echo "Zoom"
  exit 0
fi

if [ "$me" = star ] && pgrep -U star -x obs >/dev/null; then
  echo "OBS"
  exit 0
fi

exit 1
