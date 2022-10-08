#!/bin/bash

if [ "$(whoami)" != "evan" ]; then
	exit
fi

task rc.verbose=nothing rc.gc=off brief | sed -r "s/(^.{32}).*? +([-0-9\.]+)\$/\1 \2/" >~/.cache/todo.txt

"$HOME"/.cache/agenda.json <python ~/dotfiles/conky/gcal-json-to-text.py ~/.cache/agenda.txt

echo "\${color8}$(tail ~/.cache/agenda.txt -n +1 | head -n 1)"
echo "\${color4}$(tail ~/.cache/agenda.txt -n +2 | head -n 1)"
echo "\${color4}$(tail ~/.cache/agenda.txt -n +3 | head -n 1)"
echo "\${color5}$(tail ~/.cache/agenda.txt -n +4 | head -n 1)"
echo "\${color5}$(tail ~/.cache/agenda.txt -n +5 | head -n 1)"
echo "\${color5}$(tail ~/.cache/agenda.txt -n +6 | head -n 1)"
echo "\${color6}$(tail ~/.cache/agenda.txt -n +7 | head -n 1)"
echo "\${color6}$(tail ~/.cache/agenda.txt -n +8 | head -n 1)"
echo "\${color6}$(tail ~/.cache/agenda.txt -n +9 | head -n 1)"
echo "\${color6}$(tail ~/.cache/agenda.txt -n +10 | head -n 1)"
echo "\${color6}$(tail ~/.cache/agenda.txt -n +11 | head -n 1)"
echo "\${color6}$(tail ~/.cache/agenda.txt -n +12 | head -n 1)"
# shellcheck disable=SC2016
echo '${voffset -10}${color0}${stippled_hr}${voffset -2}'
echo "\${color8}$(tail ~/.cache/todo.txt -n +1 | head -n 1)"
echo "\${color4}$(tail ~/.cache/todo.txt -n +2 | head -n 1)"
echo "\${color4}$(tail ~/.cache/todo.txt -n +3 | head -n 1)"
echo "\${color5}$(tail ~/.cache/todo.txt -n +4 | head -n 1)"
echo "\${color5}$(tail ~/.cache/todo.txt -n +5 | head -n 1)"
echo "\${color5}$(tail ~/.cache/todo.txt -n +6 | head -n 1)"
echo "\${color6}$(tail ~/.cache/todo.txt -n +7 | head -n 1)"
echo "\${color6}$(tail ~/.cache/todo.txt -n +8 | head -n 1)"
echo "\${color6}$(tail ~/.cache/todo.txt -n +9 | head -n 1)"
echo "\${color6}$(tail ~/.cache/todo.txt -n +10 | head -n 1)"
echo "\${color6}$(tail ~/.cache/todo.txt -n +11 | head -n 1)"
echo "\${color6}$(tail ~/.cache/todo.txt -n +12 | head -n 1)"
