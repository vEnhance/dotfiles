sleep 5
if [ "$(hostname)" = ArchDiamond ]; then
	conky -c ~/dotfiles/conky/conky.conf
	if [ "$(date +'%Z')" = "EDT" ]; then
		conky -c ~/dotfiles/conky/large-calendar.conf
	else
		conky -c ~/dotfiles/conky/huge-calendar.conf
	fi
fi
