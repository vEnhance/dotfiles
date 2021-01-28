#!/bin/bash

trap exit SIGINT

touch /tmp/agenda.txt
while :
do
	clear
	echo "~TODAY~ on Evan's to-do list"
	date
	echo "-------------------"
	todoist sync
	script --flush --quiet --return /tmp/todo.txt  --command "todoist --color list -f overdue\|today" > /dev/null
	cat /tmp/todo.txt | tail -n +2 | head -n -2 | cut -c 72- | sort -k 1.5
	echo "-------------------"
	cat /tmp/agenda.txt | cut -b 12-19,31-
	gcalendar --no-of-days 1 --output txt \
		--calendar "日曆" \
		"Break" \
		"Events" \
		"Friends" \
		"Garbage" \
		"Happy Events" \
		"Important" \
		"Leisure" \
		"Office Hours" \
		"Prison" \
		"Real Life" \
		"Schedule" \
		"Todoist" \
		"Unfortunate Things" \
		"Video Calls for OTIS" \
		"Zero-Minute Reminders" \
		"twitch.tv" > /tmp/agenda.txt &
	echo ""
	echo "Press ENTER to refresh..."
	echo "" >> /tmp/mbsync.log
	echo "###############################" >> /tmp/mbsync.log
	date >> /tmp/mbsync.log
	mbsync -Va >> /tmp/mbsync.log &
	read -t 1800 &> /dev/null
done
