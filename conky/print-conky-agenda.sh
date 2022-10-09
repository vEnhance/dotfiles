#!/bin/bash

if [ "$(whoami)" != "evan" ]; then
	exit
fi

task rc.verbose=nothing rc.gc=off brief | sed -r "s/(^.{32}).*? +([-0-9\.]+)\$/\1 \2/" >~/.cache/todo.txt

"$HOME"/.cache/agenda.json <python ~/dotfiles/conky/gcal-json-to-text.py ~/.cache/agenda.txt

color_num=(8 4 4 5 5 5 6 6 6 6 6 6)

for k in {1..12}; do
	if [ "$(wc --lines <~/.cache/agenda.txt)" -ge "$k" ]; then
		echo "\${color${color_num[k - 1]}}$(tail ~/.cache/agenda.txt -n +"${k}" | head -n 1)"
	fi
done

# shellcheck disable=SC2016
echo '${voffset -10}${color0}${stippled_hr}${voffset -2}'

for k in {1..12}; do
	if [ "$(wc --lines <~/.cache/todo.txt)" -ge "$k" ]; then
		echo "\${color${color_num[k - 1]}}$(tail ~/.cache/todo.txt -n +"${k}" | head -n 1)"
	fi
done
