#!/usr/bin/env bash

# https://gist.github.com/tomjnixon/1348383/68a1783a111f5eed7b1f8a4a70adb157c9118e1b

# Script to switch all programs to a specific sink. Why this isn't easy, I
# don't know.

# This script takes a single argument, the sink name, index, or alias (defined
# below).
# To make this work, you will need to:
#   - In /etc/pulse/default.pa:
#       change "load-module module-stream-restore"
#       to     "load-module module-stream-restore restore_device=false"
#     This makes all streams use the default device when they start, rather
#     than the last device.
#   - Set up the sink_names array below.
#     PulseAudio sink names are usually rather obtuse, and the indices can
#     change, so you can declare short names for sinks in the array below.
#
#     The format is '[alias]=device_name'. The sink names can be found with:
#       $ pacmd list-sinks | grep '^\s*name'
#     , and are the monstrosities between the angle brackets.

# eventually split this
if [ "$(hostname)" = ArchMajestic ]; then
  declare -A sink_names=(
    [usb]="$(pactl list sinks short | grep usb | cut -f 2)"
    [speakers]="$(pactl list sinks short | grep pci | grep analog-stereo | cut -f 2)"
  )
fi
if [ "$(hostname)" = ArchDiamond ]; then
  declare -A sink_names=(
    [usb]="$(pactl list sinks short | grep usb | cut -f 2)"
    [speakers]="$(pactl list sinks short | grep hdmi-stereo | cut -f 2)"
  )
fi
if [ "$(hostname)" = ArchBootes ]; then
  declare -A sink_names=(
    [usb]="$(pactl list sinks short | grep usb | cut -f 2)"
    [speakers]="$(pactl list sinks short | grep 'pci-.*\.analog-stereo' | cut -f 2)"
  )
fi

sink=${sink_names[$1]:-$1}
echo "Sink: $sink"

pactl set-default-sink "$sink"
pactl --format json list sink-inputs |
  jq '.[]|(.index|tostring)+"\t"+(.properties."device.description"|tostring)' -r |
  grep -v 'loopback' |
  grep -vi 'soundboard' |
  grep -oE '^[0-9]+' |
  while read -r input; do
    pactl move-sink-input "$input" "$sink"
  done

# if dunst running, send a notification
if pgrep -U "$(whoami)" dunst >/dev/null; then
  notify-send -i audio-card "Sink changed" "Sound now on sink $sink"
fi
