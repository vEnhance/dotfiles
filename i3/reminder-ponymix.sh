#!/usr/bin/env bash
#
notify-send "i3: ponymix mode" -i "devices/media-optical-cd-audio-symbolic" \
  -t 6000 \
  -u low \
  "<b>u/d/i</b>: mic volume up/down/reset
<b>m/w</b> mic mute/unmute
<b>k/j</b>: global volume up/down
<b>v/z</b>: global volume mute/unmute
<b>l</b>: leave desk (mic mute, speaker on)
<b>r</b>: return to desk (mic unmute, headset)
<b>s</b>: switch to speakers
<b>h</b>: switch to headset
<b>K/J</b>: spotify volume up/down
<b>space</b>: play/pause
<b>p/n</b>: prev/next"
