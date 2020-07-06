#!/bin/bash

# https://gist.github.com/tomjnixon/1348383/68a1783a111f5eed7b1f8a4a70adb157c9118e1b

# Script to switch all programs to a specific sync. Why this isn't easy, i
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
if [ "$HOSTNAME" = ArchMajestic ]; then
	declare -A sink_names=(
		[usb]=alsa_output.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.analog-stereo
		[speakers]=alsa_output.pci-0000_00_1f.3.analog-stereo
		[hdmi]=alsa_output.pci-0000_01_00.1.hdmi-stereo
	)
fi

sink=${sink_names[$1]:-$1}

(
	echo set-default-sink $sink
	
	pacmd list-sink-inputs |
		grep -E '^\s*index:' |
		grep -oE '[0-9]+' |
		while read input
	do
		echo move-sink-input $input $sink
	done
) | pacmd > /dev/null

notify-send -i audio-card "Sink changed" "Sound now on sink $sink"
