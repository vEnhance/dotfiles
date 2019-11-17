export LANG=zh_TW.utf-8
if [ "$HOSTNAME" = ArchMega ]; then
	gcalcli calw --conky --nolineart \
		--color_owner green --color_border green \
		--color_now_marker cyan --color_date white \
		-w 20 --military | sed s/green/orange/g > /tmp/conky.out &
fi
if [ "$HOSTNAME" = ArchAir ]; then
	gcalcli agenda $(date -I) $(date -I -d '+3 day') --military --conky \
		--color_owner yellow --color_date white > /tmp/conky.out &
fi
