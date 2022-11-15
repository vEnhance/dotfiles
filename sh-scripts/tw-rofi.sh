#!/bin/bash

default="Available tasks"
lines="${default}\n$(task rofi rc.gc=off rc.verbose=nothing | sed -r 's/^([0-9]+)/#\1;/')"
chosen=$(echo -e "$lines" | rofi -dmenu -i -p "taskwarrior")

if [ "$chosen" = "" ]; then
  echo "Empty"
elif [ "$chosen" = "$default" ]; then
  echo "Default"
elif [[ $lines == *"$chosen"* ]]; then
  taskid=$(echo "$chosen" | sed -r "s/[^ 0-9]//g" | awk '{print $1}')
  echo "$taskid"
  task "$taskid" "done"
  killall -s USR1 py3status
else
  task add "$chosen"
  killall -s USR1 py3status
fi
