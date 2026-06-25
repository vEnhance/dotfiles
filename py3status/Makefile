all: py3status.ArchMajestic.conf py3status.ArchScythe.conf py3status.ArchDiamond.conf py3status.star.conf py3status.ArchBootes.conf py3status.ArchMillie.conf py3status.ArchUmi.conf

py3status.%.conf: main.conf order.%.conf tagline
	cat $^ > $@
