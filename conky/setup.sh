#/bin/bash

sleep 5
if [ "$(hostname)" = ArchDiamond ]; then
	if [ "$(date +'%Z')" = "EDT" ] || [ "$(date +'%Z')" = "EST" ]; then
		conky -c ~/dotfiles/conky/thin-bar-3840x2160.conf
		conky -c ~/dotfiles/conky/cal4.conf
	else
		conky -c ~/dotfiles/conky/thin-bar-1920x1080.conf
		conky -c ~/dotfiles/conky/cal3.conf
	fi
fi

if [ "$(hostname)" = ArchMajestic ]; then
	conky -c ~/dotfiles/conky/shifted-bar.conf
	conky -c ~/dotfiles/conky/cal3.conf
fi

if [ "$(hostname)" = ArchScythe ]; then
	conky -c ~/dotfiles/conky/thin-bar-1920x1080.conf
	conky -c ~/dotfiles/conky/cal2.conf
fi
