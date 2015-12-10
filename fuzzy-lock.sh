#!/bin/sh -e

# Take a screenshot
scrot /tmp/screen_locked.png

# mogrify -scale 10% -scale 1000% /tmp/screen_locked.png
mogrify -negate -blur 0x4 /tmp/screen_locked.png

# Lock screen displaying this image.
if pgrep i3lock > /dev/null
	then
		echo "Already running"
	else
		i3lock -b -e -p win -i /tmp/screen_locked.png
	fi
