#!/bin/bash
pactl load-module module-null-sink sink_name=zoom sink_properties=device.description=zoom
pactl load-module module-loopback sink=zoom
pactl set-default-source zoom.monitor
pactl load-module module-null-sink sink_name=media sink_properties=device.description=media
pactl load-module module-loopback source=media.monitor
pactl load-module module-loopback source=media.monitor sink=zoom
