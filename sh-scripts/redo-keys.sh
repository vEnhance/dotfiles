#!/bin/sh -e

# Make sure we're in Dvorak
xmodmap -e "remove lock = Caps_Lock"
setxkbmap dvorak -option caps:escape
numlockx on

# synclient TapButton1=0           # Disable tap to click
# synclient TapButton2=0           # Disable double tap to paste
# synclient RightButtonAreaRight=1 # Remap mouse buttons
