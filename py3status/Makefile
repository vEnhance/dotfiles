all: py3status.ArchMajestic.conf py3status.ArchScythe.conf py3status.ArchAngel.conf py3status.ArchDiamond.conf py3status.ArchAir.conf py3status.ArchSapphire.conf

py3status.%.conf: main.conf order.%.conf tagline
	cat $^ > $@
