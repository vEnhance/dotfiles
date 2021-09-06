#!/bin/bash

# Supports desktop files, so handled by systemd or dex:
# * xfce power manager
# * nm applet
# * copyq
# * flameshot
# * syncthing-gtk? unclear
#
# dropbox no longer, started manually

WS1="1: Aleph"
WS2="2: Bet"
WS3="3: Gimel"
WS4="4: Dalet"
WS5="5: Hei"
WS6="6: Vav"
WS7="7: Zayin"
WS8="8: Het"
WS9="9: Tet"
WS0="10: Yod"

xss-lock -n ~/dotfiles/sh-scripts/lock-warning.sh -- ~/dotfiles/sh-scripts/fuzzy-lock.sh &

if [ "$(hostname)" = ArchAir ]; then
	dunst &
	synclient RightButtonAreaRight=1
	synclient VertScrollDelta=-237
	systemctl start --user evil-chin.service
	systemctl start --user mosp-2021.service
	systemctl start --user sentinel.service
fi

if [ "$(hostname)" = ArchAngel ]; then
	picom -C -G -b --no-fading-openclose
	redshift-gtk &
	dropbox-cli start
fi

if [ "$(hostname)" = ArchScythe ]; then
	picom -C -G -b --no-fading-openclose
	redshift-gtk &
	dropbox-cli start
	systemctl --user start evansync.timer # idfk why systemctl enable doesn't work w/e
	dunst &
	syncthing-gtk -m &
fi

if [ "$(hostname)" = ArchDiamond ]; then
	picom -C -G -b --no-fading-openclose
	redshift-gtk &
	systemctl --user start evansync.timer
	dunst &
	syncthing-gtk -m &
	if [ "$(whoami)" = "evan" ]; then
		source ~/dotfiles/conky/setup.sh &
		ibus-daemon -d -r &
	fi
	if [ "$(date +'%Z')" = "PDT" -a "$(whoami)" = "evan" ]; then
		/home/evan/dotfiles/py-scripts/ctwenty.py &
	fi
fi

if [ "$(hostname)" = ArchMajestic ]; then
	picom -C -G -b --no-fading-openclose
	if [ "$(whoami)" = "evan" ]; then
		source ~/dotfiles/conky/setup.sh &
		/home/evan/dotfiles/py-scripts/ctwenty.py &
		qtalarm &
		ibus-daemon -d -r &
	fi
	redshift-gtk &
	dropbox-cli start
	syncthing-gtk &
	systemctl --user start evansync.timer
fi
