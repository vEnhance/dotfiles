#!/bin/bash

time=600
stime=800

if [ "$1" = u ]; then
	 notify-send -i microphone-sensitivity-high-symbolic \
		"Mic volume up" \
		"Current mic volume $(ponymix -t source increase 4)%" -t $time
fi
if [ "$1" = d ]; then
	 notify-send -i microphone-sensitivity-low-symbolic \
		"Mic volume down" \
		"Current mic volume $(ponymix -t source decrease 4)%" -t $time
fi
if [ "$1" = i ]; then
	 notify-send -i audo-input-microphone \
		"Mic volume reset" \
		"Current mic volume $(ponymix -t source set-volume 90)%" -t $time
fi

if [ "$1" = k ]; then
	 notify-send -i audio-volume-high \
		"Global volume up" \
		"Current volume $(ponymix increase 4)%" -t $time
fi

if [ "$1" = j ]; then
	 notify-send -i audio-volume-medium \
		"Global volume down" \
		"Current volume $(ponymix decrease 4)%" -t $time
fi

if [ "$1" =  m ]; then
	notify-send -i microphone-sensitivity-muted-symbolic \
		"Microphone muted" \
		"Once was volume $(ponymix -t source mute)%" -t $time
fi
if [ "$1" = w ]; then
	notify-send -i microphone-sensitivity-high-symbolic \
		"Microphone unmuted" \
		"Microphone volume is $(ponymix -t source unmute)%" -t $time
fi

if [ "$1" = l ]; then
	~/dotfiles/sh-scripts/paswitch.sh speakers
	notify-send -i audio-volume-muted \
		"Microphone muted" \
		"Once was volume $(ponymix -t source mute)%" -t $time
	break
fi
if [ "$1" = r ]; then
	~/dotfiles/sh-scripts/paswitch.sh usb
	notify-send -i audio-input-microphone-high \
		"Microphone unmuted" \
		"Microphone volume is $(ponymix -t source unmute)%" -t $time
	break
fi

if [ "$1" = K ]; then
	notify-send -i audio-headphones \
		"Spotify volume up" \
		"Spotify volume $(ponymix -d Spotify --sink-input increase 10)%" -t $stime
fi
if [ "$1" = J ]; then
	notify-send -i audio-headphones \
		"Spotify volume down" \
		"Spotify volume $(ponymix -d Spotify --sink-input decrease 10)%" -t $stime
fi
if [ "$1" = z ]; then
	notify-send -i audio-headphones \
		"Spotify stream killed" \
		"$(ponymix kill -d Spotify)%" -t $stime
fi

# wait a bit after playerctl to update py3status; race condition i think
if [ "$1" = space ]; then
	playerctl play-pause
	sleep 0.1
fi
if [ "$1" = p ]; then
	playerctl previous
	sleep 0.1
fi
if [ "$1" = n ]; then
	playerctl previous
	sleep 0.1
fi

killall -s USR1 py3status
