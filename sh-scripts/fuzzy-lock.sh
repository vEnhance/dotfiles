#!/bin/bash

if pgrep i3lock > /dev/null
then
	echo "Already running"
	exit
fi

if pgrep stepmania > /dev/null
then
	echo "Stepmania running"
	# xset s off -dpms # don't blank screen if stepmania is running
	exit
fi

RESTART_WORKRAVE_AFTER=false
if pgrep workrave > /dev/null
then
	killall workrave
	RESTART_WORKRAVE_AFTER=true
fi


# Take a screenshot
scrot --overwrite /tmp/screen_locked.png

# mogrify -scale 10% -scale 1000% /tmp/screen_locked.png
mogrify -blur 3x4 +level 35% -brightness-contrast -30x0 /tmp/screen_locked.png

# Lock screen displaying this image.
i3lock -f -b -e -p win -i /tmp/screen_locked.png
# i3lock -f -b -e -p win -i /home/evan/Dropbox/Photos/Pictures/backgrounds/sans-papyrus.png -t


if $RESTART_WORKRAVE_AFTER
then
	workrave &
fi
