#!/bin/bash

if [ "$(whoami)" != "evan" ]; then
	exit
fi

task rc.verbose=nothing rc.gc=off brief | sed -r "s/(^.{32}).*? +([-0-9\.]+)\$/\1 \2/" >~/.cache/todo.txt

cat ~/.cache/agenda.json |
	python ~/dotfiles/conky/gcal-json-to-text.py ~/.cache/agenda.txt

echo "\${color8}$(cat ~/.cache/agenda.txt | tail -n +1 | head -n 1)"
echo "\${color4}$(cat ~/.cache/agenda.txt | tail -n +2 | head -n 1)"
echo "\${color4}$(cat ~/.cache/agenda.txt | tail -n +3 | head -n 1)"
echo "\${color5}$(cat ~/.cache/agenda.txt | tail -n +4 | head -n 1)"
echo "\${color5}$(cat ~/.cache/agenda.txt | tail -n +5 | head -n 1)"
echo "\${color5}$(cat ~/.cache/agenda.txt | tail -n +6 | head -n 1)"
echo "\${color6}$(cat ~/.cache/agenda.txt | tail -n +7 | head -n 1)"
echo "\${color6}$(cat ~/.cache/agenda.txt | tail -n +8 | head -n 1)"
echo "\${color6}$(cat ~/.cache/agenda.txt | tail -n +9 | head -n 1)"
echo "\${color6}$(cat ~/.cache/agenda.txt | tail -n +10 | head -n 1)"
echo "\${color6}$(cat ~/.cache/agenda.txt | tail -n +11 | head -n 1)"
echo "\${color6}$(cat ~/.cache/agenda.txt | tail -n +12 | head -n 1)"
echo "\${voffset -10}\${color0}\${stippled_hr}\${voffset -2}"
echo "\${color8}$(cat ~/.cache/todo.txt | tail -n +1 | head -n 1)"
echo "\${color4}$(cat ~/.cache/todo.txt | tail -n +2 | head -n 1)"
echo "\${color4}$(cat ~/.cache/todo.txt | tail -n +3 | head -n 1)"
echo "\${color5}$(cat ~/.cache/todo.txt | tail -n +4 | head -n 1)"
echo "\${color5}$(cat ~/.cache/todo.txt | tail -n +5 | head -n 1)"
echo "\${color5}$(cat ~/.cache/todo.txt | tail -n +6 | head -n 1)"
echo "\${color6}$(cat ~/.cache/todo.txt | tail -n +7 | head -n 1)"
echo "\${color6}$(cat ~/.cache/todo.txt | tail -n +8 | head -n 1)"
echo "\${color6}$(cat ~/.cache/todo.txt | tail -n +9 | head -n 1)"
echo "\${color6}$(cat ~/.cache/todo.txt | tail -n +10 | head -n 1)"
echo "\${color6}$(cat ~/.cache/todo.txt | tail -n +11 | head -n 1)"
echo "\${color6}$(cat ~/.cache/todo.txt | tail -n +12 | head -n 1)"
