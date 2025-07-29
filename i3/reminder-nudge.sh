#!/usr/bin/env bash
#
notify-send "i3: nudge mode" -i preferences-system-windows-move \
  -t 6000 \
  -u low \
  "<b>a/b</b>: focus parent/child
<b>hjkl</b>: move
<b>w</b>: 5px wider
<b>u</b>: 5px narrower
<b>s</b>: 5px shorter (shrink)
<b>t</b>: 5px taller (grow)"
