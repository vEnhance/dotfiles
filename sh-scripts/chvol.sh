#!/bin/bash

time=2000
stime=4000

# Mic volume control
if [ "$1" = u ]; then
  notify-send -i microphone-sensitivity-high-symbolic \
    "Mic volume up" \
    "Current mic volume $(ponymix -t source increase 5)%" -t "$time"
fi
if [ "$1" = d ]; then
  notify-send -i microphone-sensitivity-low-symbolic \
    "Mic volume down" \
    "Current mic volume $(ponymix -t source decrease 5)%" -t "$time"
fi
if [ "$1" = i ]; then
  notify-send -i audo-input-microphone \
    "Mic volume reset" \
    "Current mic volume $(ponymix -t source set-volume 90)%" -t "$time"
fi
if [ "$1" = m ]; then
  notify-send -i microphone-sensitivity-muted-symbolic \
    "Microphone muted" \
    "Once was volume $(ponymix -t source mute)%" -t "$time"
fi
if [ "$1" = w ]; then
  notify-send -i microphone-sensitivity-high-symbolic \
    "Microphone unmuted" \
    "Microphone volume is $(ponymix -t source unmute)%" -t "$time"
fi

# Global volume control
if [ "$1" = k ]; then
  notify-send -i audio-volume-high \
    "Global volume up" \
    "Current volume $(ponymix increase 5)%" -t "$time"
fi
if [ "$1" = j ]; then
  notify-send -i audio-volume-medium \
    "Global volume down" \
    "Current volume $(ponymix decrease 5)%" -t "$time"
fi
if [ "$1" = v ]; then
  notify-send -i audio-volume-muted-symbolic \
    "Global volume muted" \
    "Once was volume $(ponymix mute)%" -t "$time"
fi
if [ "$1" = z ]; then
  notify-send -i audio-volume-low \
    "Global volume unmuted" \
    "Microphone volume is $(ponymix unmute)%" -t "$time"
fi

# Switch devices
if [ "$1" = l ]; then
  ~/dotfiles/sh-scripts/paswitch.sh speakers
  notify-send -i call-stop \
    "Microphone muted, speakers on" \
    "Once was volume $(ponymix -t source mute)%" -t "$time"
fi
if [ "$1" = r ]; then
  ~/dotfiles/sh-scripts/paswitch.sh usb
  notify-send -i call-start \
    "Microphone unmuted, speakers off" \
    "Microphone volume is $(ponymix -t source unmute)%" -t "$time"
fi
if [ "$1" = s ]; then
  ~/dotfiles/sh-scripts/paswitch.sh speakers
  notify-send -i audio-speakers \
    "Switched to speakers" \
    "Current volume is $(ponymix get-volume)%" -t "$time"
fi
if [ "$1" = h ]; then
  ~/dotfiles/sh-scripts/paswitch.sh usb
  notify-send -i audio-headphones \
    "Switched to headphones" \
    "Microphone volume is $(ponymix get-volume)%" -t "$time"
fi

# Spotify stuff
function kill_extra_spotify() {
  while [ "$(ponymix list | ag 'sink-input [0-9]+: Spotify' | wc --lines)" -ge 2 ]; do
    notify-send -i edit-delete-symbolic "Spotify stream killed" -u low -t "$stime"
    ponymix kill -d Spotify
  done
}
if [ "$1" = K ]; then
  kill_extra_spotify
  notify-send -i media-playback-start-symbolic \
    "Spotify volume up" \
    "Spotify volume $(ponymix -d Spotify --sink-input increase 5)%" -t "$stime"
fi
if [ "$1" = J ]; then
  kill_extra_spotify
  notify-send -i media-playback-start-rtl-symbolic \
    "Spotify volume down" \
    "Spotify volume $(ponymix -d Spotify --sink-input decrease 5)%" -t "$stime"
fi

# playerctl play/pause prev next
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
  playerctl next
  sleep 0.1
fi

killall -s USR1 py3status
