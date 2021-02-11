#!/bin/bash

# Supports desktop files, so handled by systemd or dex:
# * xfce power manager
# * nm applet
#
# dropbox no longer, started manually

if [ "$HOSTNAME" = ArchAngel ]; then
	picom -C -G -b --no-fading-openclose
	redshift-gtk &
	dropbox-cli start
fi

if [ "$HOSTNAME" = ArchScythe ]; then
	picom -C -G -b --no-fading-openclose
	redshift-gtk &
	# cbatticon -u 300 &
	dropbox-cli start
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
	dropbox-cli start
fi

xss-lock -n ~/dotfiles/sh-scripts/lock-warning.sh -- ~/dotfiles/sh-scripts/fuzzy-lock.sh &
