#!/bin/sh

echo "========================="
echo "= EVAN'S PONYMIX REMOTE ="
echo "========================="
echo "Press some keys! Yay!"

while : ; do
	echo ""
	read -p "> " -n 1 stroke
	echo ""

	if [ "$stroke" = u ]; then
		~/dotfiles/sh-scripts/paswitch.sh usb
		break
	fi
	if [ "$stroke" = s ]; then
		~/dotfiles/sh-scripts/paswitch.sh speakers
		break
	fi

	if [ "$stroke" = k ]; then
		echo "Main volume increased to $(ponymix increase 4)"
	fi
	if [ "$stroke" = j ]; then
		echo "Main volume decreased to $(ponymix decrease 4)"
	fi

	if [ "$stroke" =  m ]; then
		notify-send -i audio-volume-muted "Microphone muted" "Once was volume $(ponymix -t source mute)%" -t 500
		break
	fi
	if [ "$stroke" = w ]; then
		notify-send -i audio-input-microphone-high "Microphone unmuted" "Microphone volume is $(ponymix -t source unmute)%" -t 500
		break
	fi
	if [ "$stroke" = l ]; then
		~/dotfiles/sh-scripts/paswitch.sh speakers
		notify-send -i audio-volume-muted "Microphone muted" "Once was volume $(ponymix -t source mute)%" -t 500
		break
	fi
	if [ "$stroke" = r ]; then
		~/dotfiles/sh-scripts/paswitch.sh usb
		notify-send -i audio-input-microphone-high "Microphone unmuted" "Microphone volume is $(ponymix -t source unmute)%" -t 500
		break
	fi

	if [ "$stroke" = K ]; then
		echo "Spotify volume increased to $(ponymix increase 4 -d Spotify --sink-input)"
	fi
	if [ "$stroke" = J ]; then
		echo "Spotify volume decreased to $(ponymix decrease 4 -d Spotify --sink-input)"
	fi


	if [ -z "$stroke" ]; then
		break
	fi
	if [ "$stroke" = q ]; then
		break
	fi
done
