#!/bin/bash

default="$(task undone rc.defaultwidth=200 | sed -n 2p | sed 's/ /-/g')"
lines="${default}\n$(task undone rc.gc=off rc.verbose=nothing rc.defaultwidth=200)"
chosen=$(echo -e "$lines" | tail -n+2 | rofi -dmenu -i -p "taskwarrior")

if [ -z "$chosen" ]; then
	echo "Empty"
elif [ "$chosen" = "$default" ]; then
	echo "Default"
elif [[ "$lines" = *"$chosen"* ]]; then
	taskid=$(echo $chosen | awk '{print $1}')
	echo $taskid
	task $taskid done
	killall -s USR1 py3status
	task sync
else
	task add $chosen
	killall -s USR1 py3status
	task sync
fi

