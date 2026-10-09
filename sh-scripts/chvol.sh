#!/usr/bin/env bash

time=2000

vol_pct() { wpctl get-volume "$1" | awk '{printf "%d", $2*100}'; }
mic_inc() { wpctl set-volume @DEFAULT_SOURCE@ 5%+; vol_pct @DEFAULT_SOURCE@; }
mic_dec() { wpctl set-volume @DEFAULT_SOURCE@ 5%-; vol_pct @DEFAULT_SOURCE@; }
mic_set() { wpctl set-volume @DEFAULT_SOURCE@ "$1%"; vol_pct @DEFAULT_SOURCE@; }
mic_mute() { vol_pct @DEFAULT_SOURCE@; wpctl set-mute @DEFAULT_SOURCE@ 1; }
mic_unmute() { wpctl set-mute @DEFAULT_SOURCE@ 0; vol_pct @DEFAULT_SOURCE@; }
spk_inc() { wpctl set-volume @DEFAULT_SINK@ 5%+; vol_pct @DEFAULT_SINK@; }
spk_dec() { wpctl set-volume @DEFAULT_SINK@ 5%-; vol_pct @DEFAULT_SINK@; }
spk_mute() { vol_pct @DEFAULT_SINK@; wpctl set-mute @DEFAULT_SINK@ 1; }
spk_unmute() { wpctl set-mute @DEFAULT_SINK@ 0; vol_pct @DEFAULT_SINK@; }

# Mic volume control
if [ "$1" = u ]; then
  notify-send -i "microphone-sensitivity-high" \
    "Mic volume up" \
    "Current mic volume $(mic_inc)%" -t "$time"
fi
if [ "$1" = d ]; then
  notify-send -i "microphone-sensitivity-low" \
    "Mic volume down" \
    "Current mic volume $(mic_dec)%" -t "$time"
fi
if [ "$1" = i ]; then
  notify-send -i "audio-input-microphone" \
    "Mic volume reset" \
    "Current mic volume $(mic_set 90)%" -t "$time"
fi
if [ "$1" = m ]; then
  notify-send -i "microphone-sensitivity-muted" \
    "Microphone muted" \
    "Once was volume $(mic_mute)%" -t "$time"
fi
if [ "$1" = w ]; then
  notify-send -i "microphone-sensitivity-high" \
    "Microphone unmuted" \
    "Microphone volume is $(mic_unmute)%" -t "$time"
fi
# Temporary mute for 30 seconds
if [ "$1" = t ]; then
  notify-send -i "status/appointment-soon" \
    "Microphone muted for 30 seconds..." \
    "Once was volume $(mic_mute)%" -t "$time"
  killall -s USR1 py3status
  sleep 30
  notify-send -i "microphone-sensitivity-high" \
    "Microphone unmuted again!" \
    "Microphone volume is $(mic_unmute)%" -t "$time" -u low
fi

# Global volume control
if [ "$1" = k ]; then
  notify-send -i "notification-audio-volume-high" \
    "Global volume up" \
    "Current volume $(spk_inc)%" -t "$time"
fi
if [ "$1" = j ]; then
  notify-send -i "notification-audio-volume-medium" \
    "Global volume down" \
    "Current volume $(spk_dec)%" -t "$time"
fi
if [ "$1" = v ]; then
  notify-send -i "notification-audio-volume-muted" \
    "Global volume muted" \
    "Once was volume $(spk_mute)%" -t "$time"
fi
if [ "$1" = z ]; then
  notify-send -i "notification-audio-volume-low" \
    "Global volume unmuted" \
    "Microphone volume is $(spk_unmute)%" -t "$time"
fi

# Switch devices
if [ "$1" = l ]; then
  ~/dotfiles/sh-scripts/paswitch.sh speakers
  notify-send -i "audio-speakers" \
    "Microphone muted, speakers on" \
    "Once was volume $(mic_mute)%" -t "$time"
fi
if [ "$1" = r ]; then
  ~/dotfiles/sh-scripts/paswitch.sh usb
  notify-send -i "headset" \
    "Microphone unmuted, speakers off" \
    "Microphone volume is $(mic_unmute)%" -t "$time"
fi
if [ "$1" = s ]; then
  ~/dotfiles/sh-scripts/paswitch.sh speakers
  notify-send -i "audio-speakers" \
    "Switched to speakers" \
    "Current volume is $(vol_pct @DEFAULT_SINK@)%" -t "$time"
fi
if [ "$1" = h ]; then
  ~/dotfiles/sh-scripts/paswitch.sh usb
  notify-send -i "audio-headphones" \
    "Switched to headphones" \
    "Microphone volume is $(vol_pct @DEFAULT_SINK@)%" -t "$time"
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
