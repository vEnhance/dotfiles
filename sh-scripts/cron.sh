#!/usr/bin/env bash

# Check if we have Internet connection
# as this command is kind of pointless without it

if ! wget -q --spider https://web.evanchen.cc; then
  echo "No Internet"
  exit 0
fi

# This command grabs all the OTIS stuff: problem sets, inquiries, suggestions
# and processes all of them through venueQ
if [ "$(hostname)" = "$(cat ~/dotfiles/host-config/otis)" ] && [ "$(whoami)" = "evan" ]; then
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
if [ "$(hostname)" = "$(cat ~/dotfiles/host-config/task)" ] && [ "$(whoami)" = "evan" ]; then
  ~/dotfiles/sh-scripts/task-update.sh
fi

## PACMAN SNAPSHOTS
if [ -f /bin/pacman ]; then
  pacman -Qqtten >~/Sync/pacman/"$(hostname)".pacman.paclist
  pacman -Qqttem >~/Sync/pacman/"$(hostname)".aur.paclist
  paclist chaotic-aur | grep -vE "^chaotic" | cut -d " " -f 1 >~/Sync/pacman/"$(hostname)".vote.paclist
  pacman -Qqm >>~/Sync/pacman/"$(hostname)".vote.paclist
  if [ "$(hostname)" = "$(cat ~/dotfiles/host-config/pacman)" ] && [ "$(whoami)" = "evan" ]; then
    cd ~/Sync/pacman/ || exit 1
    if ! git diff --exit-code; then
      git commit -a -m "$(date), snapshot taken on $(hostname)"
    fi
  fi
fi

## MBSYNC + MUTT
# Syncing mailboxes for use with mutt
if command -v mbsync >/dev/null; then
  mbsync -q personal-inbox work-inbox records-inbox
fi
