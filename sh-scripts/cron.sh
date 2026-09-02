#!/usr/bin/env bash

set -u

# Check if we have Internet connection
# as this command is kind of pointless without it
if ! wget -q --spider https://web.evanchen.cc; then
  echo "No Internet"
  exit 0
fi

if PASSWORD_STORE_GPG_OPTS="--pinentry-mode error" pass show hello >/dev/null 2>&1; then
  PASS_UNLOCKED=1
else
  PASS_UNLOCKED=0
fi
echo "PASS_UNLOCKED = $PASS_UNLOCKED"

# This command grabs all the OTIS stuff: problem sets, petitions, suggestions
# and processes all of them through venueQ
if [ "$(hostname)" = "$(jq --raw-output .otis ~/secrets/host-config.json)" ] && [ "$PASS_UNLOCKED" = 1 ]; then
  /usr/bin/python3 ~/dotfiles/py-scripts/venueQ/otis.py
fi

# This piece of software is not written by me.
# It's a program that'll read the next 14 days of my calendar
# and output the results under ~/.cache/agenda.json
# where it can be consumed by e.g. conky
if command -v gcalendar >/dev/null; then
  ~/dotfiles/sh-scripts/get-cal.sh
fi

## SYNC TASKWARRIOR
if [ "$(whoami)" = "evan" ]; then
  task sync
  if [ "$(hostname)" = "$(jq --raw-output .task ~/secrets/host-config.json)" ]; then
    task rc.recurrence.limit=1 list >/dev/null
    task sync
  fi
fi

if command -v pacman >/dev/null && [ -d ~/Sync/pacman ]; then
  ~/dotfiles/sh-scripts/pacsnap.sh
fi

## MBSYNC + MUTT
# Syncing mailboxes for use with mutt
if command -v mbsync >/dev/null && [ "$PASS_UNLOCKED" = 1 ]; then
  mbsync -q personal-inbox work-inbox records-inbox
fi
