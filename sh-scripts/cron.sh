#!/bin/bash

if [ "$(hostname)" = "ArchDiamond" -a "$(whoami)" = "evan" ]; then
	cd ~/ProGamer/OTIS/
	# find the largest year
	cd $(ls | ag "[0-9]{4}" | sort -rn | head -n 1)/billing
	make

	cd ~/OlyBase
	if ! git diff --exit-code; then
		git add .
		git commit -a -m "Snapshot $(date) on $(hostname)"
		git push
	fi

	cd ~/vimwiki
	if ! git diff --exit-code; then
		git add .
		git commit -a -m "Snapshot $(date) on $(hostname)"
	fi
fi

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
bugwarrior-pull
task sync

if [ -f /bin/pacman ]; then
	pacman -Qqtten > ~/Backups/pacman/$(hostname).pacman.paclist
	pacman -Qqttem > ~/Backups/pacman/$(hostname).aur.paclist
	cd ~/Backups/pacman/
	if [ "$(hostname)" = "ArchDiamond" -a "$(whoami)" = "evan" ]; then
		if ! git diff --exit-code; then
			git commit -a -m "$(hostname) $(date)"
		fi
	fi
fi
