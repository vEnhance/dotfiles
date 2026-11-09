#!/usr/bin/env bash
# Launch OBS with picom paused. On ArchDiamond's UHD 630, picom repainting the
# 6400x3240 screen competes with OBS for the render engine and tips it into
# dropped frames; stopping it frees ~10-25% of Render/3D. picom is restarted
# when OBS exits (including crashes), but only if it was running beforehand.
#
# conky picks its window background based on whether picom is running when it
# starts (see conky/common.lua), so it's restarted after each picom change.
#
# Also runs py-scripts/obs-frame-watch.py alongside OBS, which sends a critical
# notification when OBS reports dropped frames (needs obs-websocket enabled).
set -uo pipefail

me=$(whoami)
had_picom=false

restart_conky() {
  pgrep -U "$me" -x conky >/dev/null || return 0
  pkill -U "$me" -x conky
  "$HOME/dotfiles/conky/run-conky.sh" >/dev/null
}

if pgrep -U "$me" -x picom >/dev/null; then
  had_picom=true
  pkill -U "$me" -x picom
  # common.lua checks for picom as conky starts, so let picom finish exiting.
  # pidwait (unlike a pgrep loop) returns for zombies; the timeout is a backstop.
  timeout 2 pidwait -U "$me" -x picom
  restart_conky
fi

watch_pid=
restore() {
  [ -n "$watch_pid" ] && kill "$watch_pid" 2>/dev/null
  if $had_picom && ! pgrep -U "$me" -x picom >/dev/null; then
    picom -b
    restart_conky
  fi
}
trap restore EXIT

"$HOME/dotfiles/py-scripts/obs-frame-watch.py" &
watch_pid=$!

obs "$@"
