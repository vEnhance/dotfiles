#!/bin/bash

if pgrep -U $(whoami) i3lock > /dev/null
then
	echo "Already running"
	exit
fi

if pgrep -U $(whoami) stepmania > /dev/null
then
	echo "Stepmania running"
	# xset s off -dpms # don't blank screen if stepmania is running
	exit
fi

if [ -f "$HOME/.cache/ctwenty.lock" ]; then
	echo "ctwenty.lock running"
	exit
fi

if [ "$HOSTNAME" = ArchScythe -a "$(whoami)" = evan ]; then
	# during twitch stream, disable laptop lock screen
	if [ "$(date +%u)" -eq 5 -a "$(date +%H)" -ge 20 ]; then
		exit
	fi
	if [ "$(date +%u)" -eq 6 -a "$(date +%H)" -le 2 ]; then
		exit
	fi
fi

if [ "$HOSTNAME" = ArchMajestic -a "$(whoami)" = evan ]; then
	xset dpms 10 0 0
	pacmd set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo
	(
		pactl list sink-inputs short |
			grep -v 'module-loopback.c' |
			grep -oE '^[0-9]+' |
			while read input
		do
			echo move-sink-input $input alsa_output.pci-0000_00_1f.3.analog-stereo
		done
	) | pacmd
	~/dotfiles/sh-scripts/paswitch.sh speakers
fi

if [ "$HOSTNAME" = ArchDiamond -a "$(whoami)" = evan ]; then
	xset dpms 10 0 0
fi

# xset dpms force off

# mute microphone so I'm not recorded while afk
ponymix -t source mute > /dev/null

# if [ $(stat --printf="%s" /tmp/screen_locked_evan.png) -gt 25000 ]; then
#	i3lock \
#		--beep \
#		--ignore-empty-password \
#		--show-failed-attempts \
#		--nofork \
#		--pointer=win \
#		--image=/tmp/screen_locked_$(whoami).png
#fi

if pacman -Q i3lock-color; then
	export LANG=zh_TW.UTF-8
	i3lock \
		--beep \
		--ignore-empty-password \
		--show-failed-attempts \
		--nofork \
		--pointer=win \
		--keylayout 2 \
		--clock \
		--time-color=ffffff \
		--date-color=33ddff \
		--layout-color=aaaaaa \
		--verif-color=ffffff \
		--wrong-color=ffffff \
		--greeter-color=ffffff \
		--date-str="%A %Y年%b%d日" \
		--time-size=36 \
		--date-size=24 \
		--layout-size=24 \
		--time-str="%R%Z" \
		--radius 160 \
		--ring-width 20 \
		--greeter-text="$(whoami)@$(cat /etc/hostname)" \
		--greeter-pos="ix:iy+0.3*h" \
		--greeter-color=00ffff \
		--indicator \
		--blur 8
		# --color d33529
		# --image ~/Pictures/nature/bg-arch-majestic.png \
else
	i3lock \
		--beep \
		--ignore-empty-password \
		--show-failed-attempts \
		--nofork \
		--color=d33529 \
		--pointer=win
fi

if [ "$HOSTNAME" = ArchMajestic -a "$(whoami)" = evan ]; then
	xset dpms 900 900 900
fi
if [ "$HOSTNAME" = ArchDiamond -a "$(whoami)" = evan ]; then
	xset dpms 900 900 900
	killall -s CONT ctwenty.py
fi

if [ "$HOSTNAME" = ArchMajestic ]; then
	~/dotfiles/sh-scripts/paswitch.sh speakers
fi
if [ "$HOSTNAME" = Endor ]; then
	~/dotfiles/sh-scripts/paswitch.sh speakers
fi
