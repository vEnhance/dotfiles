#!/bin/bash

# This command grabs all the OTIS stuff: problem sets, inquiries, suggestions
# and processes all of them through venueQ
if [ "$(hostname)" = "ArchDiamond" ] && [ "$(whoami)" = "evan" ]; then
  python ~/dotfiles/venueQ/otis.py
fi
if [ "$(hostname)" = "dagobah" ] && [ "$(whoami)" = "evan" ]; then
  python ~/dotfiles/venueQ/otis.py
fi

# This piece of software is not written by me.
# It's a program that'll read the next 14 days of my calendar
# and output the results under ~/.cache/agenda.json
# where it can be consumed by e.g. conky
if command -v gcalendar >/dev/null; then
  ~/dotfiles/sh-scripts/get-cal.sh
fi

## MBSYNC + MUTT
# Syncing mailboxes for use with mutt
if command -v mbsync >/dev/null; then
  mbsync -Va
fi

## SYNC TASKWARRIOR
if [ "$(hostname)" = "ArchDiamond" ] && [ "$(whoami)" = "evan" ]; then
  task rc.recurrence.limit=1 list
fi
if command -v task >/dev/null; then
  task rc.gc=on sync
fi
if command -v bugwarrior-pull >/dev/null; then
  bugwarrior-pull
  task rc.gc=on sync
fi

## PACMAN SNAPSHOTS
if [ -f /bin/pacman ]; then
  pacman -Qqtten >~/Sync/pacman/"$(hostname)".pacman.paclist
  pacman -Qqttem >~/Sync/pacman/"$(hostname)".aur.paclist
  paclist chaotic-aur | grep -vE "^chaotic" | cut -d " " -f 1 >~/Sync/pacman/"$(hostname)".vote.paclist
  pacman -Qqm >>~/Sync/pacman/"$(hostname)".vote.paclist
  if [ "$(hostname)" = "ArchDiamond" ] && [ "$(whoami)" = "evan" ]; then
    cd ~/Sync/pacman/ || exit
    if ! git diff --exit-code; then
      git commit -a -m "$(date), snapshot taken on $(hostname)"
    fi
  fi
fi
