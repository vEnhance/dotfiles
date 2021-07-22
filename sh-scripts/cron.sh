#!/bin/bash

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
		"twitch.tv" > ~/.cache/_agenda.txt
		
cat ~/.cache/_agenda.txt | cut -b 12-19,31- | sed "s/\ -\ /~/" | sed "s/\ -\ /~/" | tail -n +2 > ~/.cache/agenda.txt

mbsync -Va

task sync
