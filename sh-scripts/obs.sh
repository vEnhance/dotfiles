#!/usr/bin/env bash
# Launch OBS with picom paused. On ArchDiamond's UHD 630, picom repainting the
# 6400x3240 screen competes with OBS for the render engine and tips it into
# dropped frames; stopping it frees ~10-25% of Render/3D. picom is restarted
# when OBS exits (including crashes), but only if it was running beforehand.
#
# conky picks its window background based on whether picom is running when it
# starts (see conky/window-bg.lua), so it's restarted after each picom change.
set -uo pipefail

me=$(whoami)
had_picom=false

restart_conky() {
  pgrep -U "$me" -x conky >/dev/null || return 0
  pkill -U "$me" -x conky
  while pgrep -U "$me" -x conky >/dev/null; do sleep 0.1; done
  "$HOME/dotfiles/conky/run-conky.sh" >/dev/null
}

if pgrep -U "$me" -x picom >/dev/null; then
  had_picom=true
  pkill -U "$me" -x picom
  while pgrep -U "$me" -x picom >/dev/null; do sleep 0.1; done
  restart_conky
fi

restore() {
  if $had_picom && ! pgrep -U "$me" -x picom >/dev/null; then
    picom -b
    restart_conky
  fi
}
trap restore EXIT

obs "$@"
