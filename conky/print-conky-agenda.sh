#!/bin/bash

if [ "$(whoami)" != "evan" ]; then
	exit;
fi

task rc.verbose=nothing rc.report.min.columns:due.relative,description \
	min rc.report.min.sort:urgency- status:pending +READY \
	| sed "s/[\ ]{3,}/\t/" | sed 's/^/ /' \
	> ~/.cache/todo.txt

cat ~/.cache/agenda.json | python ~/dotfiles/conky/gcal-json-to-text.py > ~/.cache/agenda.txt
echo "\${color4}$(cat ~/.cache/agenda.txt | tail -n +1 | head -n 1)"
echo "\${color5}$(cat ~/.cache/agenda.txt | tail -n +2 | head -n 1)"
echo "\${color6}$(cat ~/.cache/agenda.txt | tail -n +3 | head -n 1)"
echo "\${voffset -10}\${color0}\${stippled_hr}\${voffset -2}"
echo "\${color4}$(cat ~/.cache/todo.txt | tail -n +1 | head -n 1)"
echo "\${color5}$(cat ~/.cache/todo.txt | tail -n +2 | head -n 1)"
echo "\${color5}$(cat ~/.cache/todo.txt | tail -n +3 | head -n 1)"
echo "\${color6}$(cat ~/.cache/todo.txt | tail -n +4 | head -n 1)"
echo "\${color6}$(cat ~/.cache/todo.txt | tail -n +5 | head -n 1)"
echo "\${color6}$(cat ~/.cache/todo.txt | tail -n +6 | head -n 1)"
