#!/bin/bash

task rc.verbose=nothing rc.report.min.columns:due.relative,description \
	min rc.report.min.sort:urgency- status:pending +READY \
	| sed "s/[\ ]{3,}/\t/" | sed 's/^/ /' \
	> ~/.cache/todo.conky.txt

grep $(date +"%Y-%m-%d") ~/.cache/agenda.txt | cut -b 12-16,36- > ~/.cache/agenda.conky.txt
grep -v $(date +"%Y-%m-%d") ~/.cache/agenda.txt \
	| cut -b 1-16,36- \
	| sed "s/:/\t/" \
	| gawk -F "\t" '{ print strftime("%a", $1) "\t" $2 " " $3 }' - >> ~/.cache/agenda.conky.txt

echo "\${color4}$(cat ~/.cache/agenda.conky.txt | tail -n +1 | head -n 1)"
echo "\${color5}$(cat ~/.cache/agenda.conky.txt | tail -n +2 | head -n 1)"
echo "\${color6}$(cat ~/.cache/agenda.conky.txt | tail -n +3 | head -n 1)"
echo "\${voffset -10}\${color0}\${stippled_hr}\${voffset -2}"
echo "\${color4}$(cat ~/.cache/todo.conky.txt | tail -n +1 | head -n 1)"
echo "\${color5}$(cat ~/.cache/todo.conky.txt | tail -n +2 | head -n 1)"
echo "\${color5}$(cat ~/.cache/todo.conky.txt | tail -n +3 | head -n 1)"
echo "\${color6}$(cat ~/.cache/todo.conky.txt | tail -n +4 | head -n 1)"
echo "\${color6}$(cat ~/.cache/todo.conky.txt | tail -n +5 | head -n 1)"
echo "\${color6}$(cat ~/.cache/todo.conky.txt | tail -n +6 | head -n 1)"
