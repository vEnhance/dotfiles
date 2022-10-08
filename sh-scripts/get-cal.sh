#!/bin/bash

gcalendar --no-of-days 14 --output json \
	--calendar "日曆" \
	"Break" \
	"Events" \
	"Friends" \
	"Garbage" \
	"Happiness" \
	"Important" \
	"Leisure" \
	"Office Hours" \
	"Prison" \
	"Real Life" \
	"Schedule" \
	"Unfortunate Things" \
	"Video Calls for OTIS" \
	"White" \
	"Zero-Minute Reminders" \
	"twitch.tv" | python ~/dotfiles/py-scripts/get-cal-helper.py ~/.cache/agenda.json
