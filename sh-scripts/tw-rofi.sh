#!/bin/bash

default="$(task undone rc.gc=off | sed -n 2p | sed 's/ /-/g' | sed 's/^ID/-ID-/')"
lines="${default}\n$(task undone rc.gc=off rc.verbose=nothing | sed -r 's/^([0-9]+)/#\1;/' )"
chosen=$(echo -e "$lines" | rofi -dmenu -i -p "taskwarrior")

if [ -z "$chosen" ]; then
	echo "Empty"
elif [ "$chosen" = "$default" ]; then
	echo "Default"
elif [[ "$lines" = *"$chosen"* ]]; then
	taskid=$(echo $chosen | sed -r "s/[^ 0-9]//g" | awk '{print $1}')
	echo $taskid
	task $taskid done
	killall -s USR1 py3status
	task sync
else
	task add $chosen
	killall -s USR1 py3status
	task sync
fi
