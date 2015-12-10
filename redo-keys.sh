#!/bin/sh -e

setxkbmap dvorak

synclient TapButton1=0           # Disable tap to click
synclient TapButton2=0           # Disable double tap to paste
synclient RightButtonAreaRight=1 # Remap mouse buttons
# Make sure we're in Dvorak
