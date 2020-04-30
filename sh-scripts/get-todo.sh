#!/bin/bash

while :
do
	clear
	echo "TODAY on the to-do list"
	date
	echo "-------------"
	todoist sync
	script --flush --quiet --return /tmp/todo.txt  --command "todoist --color list -f today" > /dev/null
	cat /tmp/todo.txt | tail -n +2 | head -n -2 | cut -c 72- | sort -k 1.5
	echo ""
	echo "Press ENTER to refresh..."
	read -t 1800 &> /dev/null
done
