#!/bin/bash

notify-send -i timer-symbolic -t 60000 -u critical \
	"Lock warning" \
	"The session will automatically lock shortly. Do literally anything to cancel."

cvlc --play-and-exit "/usr/share/sounds/freedesktop/stereo/complete.oga"
