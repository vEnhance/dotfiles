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

# mute microphone so I'm not recorded while afk
ponymix -t source mute > /dev/null

if [ "$HOSTNAME" = ArchAir -a "$(whoami)" = evan ]; then
	i3lock \
		--beep \
		--ignore-empty-password \
		--show-failed-attempts \
		--nofork \
		--color=000000
elif pacman -Q --quiet i3lock-color; then
	export LANG=zh_TW.UTF-8
	i3lock \
		--insidever-color=0a220a66  \
		--ringver-color=0a550aee    \
		--insidewrong-color=efaaaabb\
		--ringwrong-color=ef0a0aff  \
		--inside-color=00000000     \
		--ring-color=dd0add66       \
		--line-color=0a0a0aff       \
		--separator-color=ff66ff44  \
		--verif-color=efefef77      \
		--wrong-color=efefefff      \
		--modif-color=efefef99      \
		--time-color=aa33aabb       \
		--date-color=aa33aabb       \
		--layout-color=dededebb     \
		--keyhl-color=dd888899      \
		--bshl-color=dd888899       \
		--keylayout 2               \
		--radius 384                \
		--ring-width 32             \
		--date-str="%A %Y年%b%d日"  \
		--time-size=48              \
		--date-size=36              \
		--layout-size=36            \
		--verif-size=64             \
		--wrong-size=64             \
		--modif-size=36             \
		--time-str="%R%Z"           \
		--date-pos="ix:iy-0.4*r"    \
		--wrong-pos="ix:iy-0.1*r"   \
		--verif-pos="ix:iy-0.1*r"   \
		--modif-pos="ix:iy+0.1*r"   \
		--time-pos="ix:iy+0.4*r"    \
		--layout-pos="ix:iy+1.3*r"  \
		--date-font="Exo2"          \
		--time-font="Exo2"          \
		--layout-font="Exo2"        \
		--color 111117dd            \
		--show-failed-attempts      \
		--ignore-empty-password
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
	killall -s CONT ctwenty.py
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
