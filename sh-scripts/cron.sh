#!/bin/bash

#if [ "$(hostname)" = "ArchDiamond" -a "$(whoami)" = "evan" ]; then
#	## OTIS: UPDATE BILLING
#	## this is when we copy the gnucash record and send them to otis web server
#	## this is done by running `make` in the billing directory
#	# first, let's update the directory
#	cd ~/ProGamer/OTIS/
#	# find the largest year
#	cd $(ls | ag "[0-9]{4}" | sort -rn | head -n 1)/billing
#	make
#
#	## OLYMPIAD: update the von database
#	# this means both committing any recent changes
#	# as well as re-running the index cem
#	cd ~/OlyBase
#	if ! git diff --exit-code; then
#		git add .
#		git commit -a -m "Snapshot $(date) on $(hostname)"
#		git push
#	fi
#	python -m von index
#
#fi

# This command grabs all the OTIS stuff: problem sets, inquiries, suggestions
# and processes all of them through venueQ
if [ "$(hostname)" = "ArchMajestic" -a "$(whoami)" = "evan" ]; then
	python ~/dotfiles/venueQ/otis.py
fi

# This piece of software is not written by me.
# It's a program that'll read the next 14 days of my calendar
# and output the results under ~/.cache/agenda.json
# where it can be consumed by e.g. conky
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

## MBSYNC + MUTT
# Syncing mailboxes for use with mutt
mbsync -Va

## SYNC TASKWARRIOR
task rc.gc=on sync
# bugwarrior-pull
# task sync

## PACMAN SNAPSHOTS
if [ -f /bin/pacman ]; then
	pacman -Qqtten > ~/Sync/pacman/$(hostname).pacman.paclist
	pacman -Qqttem > ~/Sync/pacman/$(hostname).aur.paclist
	if [ "$(hostname)" = "ArchDiamond" -a "$(whoami)" = "evan" ]; then
		cd ~/Sync/pacman/
		if ! git diff --exit-code; then
			git commit -a -m "$(hostname) $(date)"
		fi
	fi
fi
