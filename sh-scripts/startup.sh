#!/bin/bash

# Supports desktop files, so handled by dex:
# * xfce power manager
# * nm applet
# * dropbox

if [ "$HOSTNAME" = ArchAngel ]; then
	picom -C -G -b --no-fading-openclose
	redshift-gtk &
fi

if [ "$HOSTNAME" = ArchScythe ]; then
	picom -C -G -b --no-fading-openclose
	redshift-gtk &
	# cbatticon -u 300 &
fi

if [ "$HOSTNAME" = ArchMajestic ]; then
	picom -b &
	# clipmenud &
	if [ "$(whoami)" = "evan" ]; then
		xfce4-terminal -e "/home/evan/dotfiles/sh-scripts/get-todo.sh --email" &
		workrave &
		qtalarm &
		# ibus-daemon -d -r &
	fi
	redshift-gtk &
fi

xss-lock -n ~/dotfiles/sh-scripts/lock-warning.sh -- ~/dotfiles/sh-scripts/fuzzy-lock.sh &
