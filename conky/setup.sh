#/bin/bash

sleep 5
if [ "$(hostname)" = ArchDiamond ]; then
	conky -c ~/dotfiles/conky/huge-calendar.conf
	if [ "$(date +'%Z')" = "EDT" ]; then
		conky -c ~/dotfiles/conky/thin-bar-3840x2160.conf
	else
		conky -c ~/dotfiles/conky/thin-bar-1920x1080.conf
	fi
fi

if [ "$(hostname)" = ArchMajestic ]; then
	conky -c ~/dotfiles/conky/shifted-bar.conf
	conky -c ~/dotfiles/conky/huge-calendar.conf
fi

if [ "$(hostname)" = ArchAir ]; then
	conky -c ~/dotfiles/conky/shifted-bar.conf
	conky -c ~/dotfiles/conky/large-calendar.conf
fi
