#!/bin/bash
notify-send "i3: config mode" \
	-i apps/preferences-desktop-keyboard-shortcuts-symbolic \
	-t 4000 \
	-u low \
	"<b>r/i</b>: reload & in-place restart
<b>m</b>: reset key layout
<b>f</b>: run fehbg
<b>h/l</b>: left-hand/right-hand mouse
<b>n/s</b>: normal/SC2 mode
<b>p</b>: present mode
<b>c</b>: trigger caps lock"
