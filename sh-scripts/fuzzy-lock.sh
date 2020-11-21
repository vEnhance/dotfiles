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
	killall workrave
fi

# mute microphone so I'm not recorded while afk
ponymix -t source mute > /dev/null

# Take a screenshot
scrot -q 10 --overwrite /tmp/screen_locked_$(whoami).jpg
convert -blur 3x4 +level 35% -brightness-contrast -30x0 /tmp/screen_locked_$(whoami).jpg /tmp/screen_locked_$(whoami).png

if [ $(stat --printf="%s" /tmp/screen_locked_evan.png) -gt 25000 ]; then
	xset s 20 20
	i3lock \
		--beep \
		--ignore-empty-password \
		--show-failed-attempts \
		--nofork \
		--pointer=win \
		--image=/tmp/screen_locked_$(whoami).png
	xset s 600 600
else
	# in this case, the image is so small that I am led to believe
	# that the X server is not even focused
	# so we just use a solid background
	i3lock \
		--beep \
		--ignore-empty-password \
		--show-failed-attempts \
		--nofork \
		--pointer=win \
		--color=d33529 # superficial burn
fi

# And now that we're done...
rm /tmp/screen_locked_$(whoami).jpg
rm /tmp/screen_locked_$(whoami).png

if [ "$HOSTNAME" = ArchMajestic ]; then
	~/dotfiles/sh-scripts/paswitch.sh speakers
	if [ "$(whoami)" = "evan" ]; then
		dbus-send --print-reply \
			--dest=org.workrave.Workrave \
			/org/workrave/Workrave/Core \
			org.workrave.CoreInterface.SetOperationMode \
			string:'normal'
	fi
fi
if [ "$HOSTNAME" = Endor ]; then
	~/dotfiles/sh-scripts/paswitch.sh speakers
fi
