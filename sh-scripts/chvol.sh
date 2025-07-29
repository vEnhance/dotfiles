#!/usr/bin/env bash

time=2000
stime=4000

# Mic volume control
if [ "$1" = u ]; then
  notify-send -i "microphone-sensitivity-high" \
    "Mic volume up" \
    "Current mic volume $(ponymix -t source increase 5)%" -t "$time"
fi
if [ "$1" = d ]; then
  notify-send -i "microphone-sensitivity-low" \
    "Mic volume down" \
    "Current mic volume $(ponymix -t source decrease 5)%" -t "$time"
fi
if [ "$1" = i ]; then
  notify-send -i "audio-input-microphone" \
    "Mic volume reset" \
    "Current mic volume $(ponymix -t source set-volume 90)%" -t "$time"
fi
if [ "$1" = m ]; then
  notify-send -i "microphone-sensitivity-muted" \
    "Microphone muted" \
    "Once was volume $(ponymix -t source mute)%" -t "$time"
fi
if [ "$1" = w ]; then
  notify-send -i "microphone-sensitivity-high" \
    "Microphone unmuted" \
    "Microphone volume is $(ponymix -t source unmute)%" -t "$time"
fi
# Temporary mute for 30 seconds
if [ "$1" = t ]; then
  notify-send -i "status/appointment-soon" \
    "Microphone muted for 30 seconds..." \
    "Once was volume $(ponymix -t source mute)%" -t "$time"
  killall -s USR1 py3status
  sleep 30
  notify-send -i "microphone-sensitivity-high" \
    "Microphone unmuted again!" \
    "Microphone volume is $(ponymix -t source unmute)%" -t "$time" -u low
fi

# Global volume control
if [ "$1" = k ]; then
  notify-send -i "notification-audio-volume-high" \
    "Global volume up" \
    "Current volume $(ponymix increase 5)%" -t "$time"
fi
if [ "$1" = j ]; then
  notify-send -i "notification-audio-volume-medium" \
    "Global volume down" \
    "Current volume $(ponymix decrease 5)%" -t "$time"
fi
if [ "$1" = v ]; then
  notify-send -i "notification-audio-volume-muted" \
    "Global volume muted" \
    "Once was volume $(ponymix mute)%" -t "$time"
fi
if [ "$1" = z ]; then
  notify-send -i "notification-audio-volume-low" \
    "Global volume unmuted" \
    "Microphone volume is $(ponymix unmute)%" -t "$time"
fi

# Switch devices
if [ "$1" = l ]; then
  ~/dotfiles/sh-scripts/paswitch.sh speakers
  notify-send -i "audio-speakers" \
    "Microphone muted, speakers on" \
    "Once was volume $(ponymix -t source mute)%" -t "$time"
fi
if [ "$1" = r ]; then
  ~/dotfiles/sh-scripts/paswitch.sh usb
  notify-send -i "headset" \
    "Microphone unmuted, speakers off" \
    "Microphone volume is $(ponymix -t source unmute)%" -t "$time"
fi
if [ "$1" = s ]; then
  ~/dotfiles/sh-scripts/paswitch.sh speakers
  notify-send -i "audio-speakers" \
    "Switched to speakers" \
    "Current volume is $(ponymix get-volume)%" -t "$time"
fi
if [ "$1" = h ]; then
  ~/dotfiles/sh-scripts/paswitch.sh usb
  notify-send -i "audio-headphones" \
    "Switched to headphones" \
    "Microphone volume is $(ponymix get-volume)%" -t "$time"
fi

# Spotify stuff
function kill_extra_spotify() {
  while [ "$(ponymix list | ag 'sink-input [0-9]+: Spotify' | wc --lines)" -ge 2 ]; do
    notify-send -i "spotify" "Spotify stream killed" -u low -t "$stime"
    ponymix kill -d Spotify
  done
}
if [ "$1" = K ]; then
  kill_extra_spotify
  notify-send -i "audio-speaker-center-back-testing" \
    "Spotify volume up" \
    "Spotify volume $(ponymix -d Spotify --sink-input increase 5)%" -t "$stime"
fi
if [ "$1" = J ]; then
  kill_extra_spotify
  notify-send -i "audio-speaker-center-testing" \
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
