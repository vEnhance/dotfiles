#!/bin/fish

i3-msg '[class="^(?!Anki)"] move scratchpad'

i3-msg workspace 8
countdown 25m

~/dotfiles/sh-scripts/noisemaker.sh H
touch "/tmp/pomodoro/$now.md"
set now (date +%Y%m%d-%H%M%S)
mkdir -p /tmp/pomodoro

i3-msg split h
xfce4-terminal -e "nvim /tmp/pomodoro/$now.md" &
