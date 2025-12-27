#!/usr/bin/env bash

# Check if we have Internet connection
# as this command is kind of pointless without it

if ! wget -q --spider https://web.evanchen.cc; then
  echo "No Internet"
  exit 0
fi

# This command grabs all the OTIS stuff: problem sets, inquiries, suggestions
# and processes all of them through venueQ
if [ "$(hostname)" = "$(jq --raw-output .otis ~/Sync/Keys/dot/host-config.json)" ] && [ "$(whoami)" = "evan" ]; then
  python ~/dotfiles/venueQ/otis.py
fi

# This piece of software is not written by me.
# It's a program that'll read the next 14 days of my calendar
# and output the results under ~/.cache/agenda.json
# where it can be consumed by e.g. conky
if command -v gcalendar >/dev/null; then
  ~/dotfiles/sh-scripts/get-cal.sh
fi

## SYNC TASKWARRIOR
if [ "$(hostname)" = "$(jq --raw-output .task ~/Sync/Keys/dot/host-config.json)" ] && [ "$(whoami)" = "evan" ]; then
  ~/dotfiles/sh-scripts/task-update.sh
fi

if [ -f /bin/pacman ] && [ -d ~/Sync/pacman ]; then
  ~/dotfiles/sh-scripts/pacsnap.sh
fi

## MBSYNC + MUTT
# Syncing mailboxes for use with mutt
if command -v mbsync >/dev/null; then
  mbsync -q personal-inbox work-inbox records-inbox
fi
