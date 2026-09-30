#!/usr/bin/env bash
# Launch OBS with picom paused. On ArchDiamond's UHD 630, picom repainting the
# 6400x3240 screen competes with OBS for the render engine and tips it into
# dropped frames; stopping it frees ~10-25% of Render/3D. picom is restarted
# when OBS exits (including crashes), but only if it was running beforehand.
set -uo pipefail

me=$(whoami)
had_picom=false

if pgrep -U "$me" -x picom >/dev/null; then
  had_picom=true
  pkill -U "$me" -x picom
fi

restore() {
  if $had_picom && ! pgrep -U "$me" -x picom >/dev/null; then
    picom -b
  fi
}
trap restore EXIT

obs "$@"
