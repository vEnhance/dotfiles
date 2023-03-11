#!/bin/bash

set -e

pactl load-module module-null-sink sink_name=soundboard_mix sink_properties=device.description=SoundboardMix
pactl load-module module-combine-sink sink_name=soundboard_router slaves="$(pactl list sinks short | grep output.usb-C | cut -f 2)",soundboard_mix sink_properties=device.description="SoundboardRouter"
pactl load-module module-loopback sink=soundboard_mix source="$(pactl list sinks short | grep input.usb-C | cut -f 2)"
pactl load-module module-remap-source master=soundboard_mix.monitor source_properties=device.description=SoundboardMic
