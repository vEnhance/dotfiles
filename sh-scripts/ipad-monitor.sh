#!/bin/bash
# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# <k.bumsik@gmail.com> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return. - Bumsik Kim
# ----------------------------------------------------------------------------

# Configuration
WIDTH=1024  # 1368 for iPad Pro
HEIGHT=768  # 1024 for iPad Pro
MODE_NAME="ipad"            # Set whatever name you like, you may need to change
                            # this when you change resolution, or just reboot.
DIS_NAME="VIRTUAL1"         # Don't change it unless you know what it is
RANDR_POS="--right-of"      # Default position setting for xrandr command

# Parse arguments
while [ "$#" -gt 0 ]; do
  case $1 in
    -l|--left)      RANDR_POS="--left-of"  ;;
    -r|--right)     RANDR_POS="--right-of" ;;
    -a|--above)     RANDR_POS="--above"    ;;
    -b|--below)     RANDR_POS="--below"    ;;
    -p|--portrait)  TMP=$WIDTH; WIDTH=$HEIGHT; HEIGHT=$TMP
                    MODE_NAME="$MODE_NAME""_port"  ;;
    -h|--hidpi)     WIDTH=$(($WIDTH * 2)); HEIGHT=$(($HEIGHT * 2))
                    MODE_NAME="$MODE_NAME""_hidpi" ;;
    *) echo "'$1' cannot be a monitor position"; exit 1 ;;
  esac
  shift
done

# Detect primary display
PRIMARY_DISPLAY=$(xrandr | perl -ne 'print "$1" if /(\w*)\s*connected\s*primary/')

# Add display mode
RANDR_MODE=$(cvt "$WIDTH" "$HEIGHT" 60 | sed '2s/^.*Modeline\s*\".*\"//;2q;d')
xrandr --addmode $DIS_NAME $MODE_NAME 2>/dev/null
# If the mode doesn't exist then make mode and retry
if ! [ $? -eq 0 ]; then
  xrandr --newmode $MODE_NAME $RANDR_MODE
  xrandr --addmode $DIS_NAME $MODE_NAME
fi

# Show display first
xrandr --output $DIS_NAME --mode $MODE_NAME
# Then move display
sleep 2 # A short delay is needed. Otherwise sometimes the below command is ignored.
xrandr --output $DIS_NAME $RANDR_POS $PRIMARY_DISPLAY

#xmodmap -e "pointer = 1 2 3" &> /dev/null  # left-hand mouse
#xinput set-button-map "ETPS/2 Elantech Touchpad" 3 2 1
#setxkbmap -device 3 -layout us
#setxkbmap -device 11 -layout dvorak

## Cleanup before exit
#function finish {
#  xrandr --output $DIS_NAME --off 
#  xrandr --delmode $DIS_NAME $MODE_NAME
#  echo "Second monitor disabled."
#}
#
#trap finish EXIT
#
## Get the display's position
#CLIP_POS=$(xrandr | perl -ne 'print "$1" if /'$DIS_NAME'\s*connected\s*(\d*x\d*\+\d*\+\d*)/')
#echo $CLIP_POS
## Share screen
#x11vnc -multiptr -repeat -clip $CLIP_POS
## Possible alternative is x0vncserver but it does not show the mouse cursor.
##   x0vncserver -display :0 -geometry $DIS_NAME -overlaymode -passwordfile ~/.vnc/passwd
#if ! [ $? -eq 0 ]; then
#  echo x11vnc failed, did you \'apt-get install x11vnc\'?
#fi
