#!/bin/bash

gcalendar --no-of-days 14 --output json \
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
		"twitch.tv" > ~/.cache/agenda.json
	
mbsync -Va
task sync
# bugwarrior-pull

if [ -f /bin/pacman ]; then
	pacman -Qqtten > ~/Backups/pacman/$(hostname).pacman.paclist
	pacman -Qqttem > ~/Backups/pacman/$(hostname).aur.paclist
	cd ~/Backups/pacman/
	if ! git diff --exit-code; then
		git commit -a -m "$(hostname) $(date)"
	fi
fi
