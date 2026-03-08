#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# <k.bumsik@gmail.com> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return. - Bumsik Kim
# ----------------------------------------------------------------------------
# Original from https://kbumsik.io/using-ipad-as-a-2nd-monitor-on-linux

# Configuration
WIDTH=800
HEIGHT=600
MODE_NAME="ipad"
DIS_NAME="VIRTUAL1"
RANDR_POS="--right-of"
VNC_PORT=5900

usage() {
  echo "Usage: $0 [options]"
  echo "  -l, --left      Position left of primary"
  echo "  -r, --right     Position right of primary (default)"
  echo "  -a, --above     Position above primary"
  echo "  -b, --below     Position below primary"
  echo "  -p, --portrait  Use portrait orientation"
  echo "  -h, --hidpi     Double resolution for HiDPI"
  echo "  --port PORT     VNC port (default: 5900)"
  echo "  --help          Show this help"
}

# Parse arguments
while [ "$#" -gt 0 ]; do
  case $1 in
  -l | --left) RANDR_POS="--left-of" ;;
  -r | --right) RANDR_POS="--right-of" ;;
  -a | --above) RANDR_POS="--above" ;;
  -b | --below) RANDR_POS="--below" ;;
  -p | --portrait)
    TMP=$WIDTH
    WIDTH=$HEIGHT
    HEIGHT=$TMP
    MODE_NAME="${MODE_NAME}_port"
    ;;
  -h | --hidpi)
    WIDTH=$((WIDTH * 2))
    HEIGHT=$((HEIGHT * 2))
    MODE_NAME="${MODE_NAME}_hidpi"
    ;;
  --port)
    shift
    VNC_PORT=$1
    ;;
  --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: '$1'"
    usage
    exit 1
    ;;
  esac
  shift
done

# Check dependencies
for cmd in xrandr cvt perl x11vnc; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is not installed."
    exit 1
  fi
done

# Check that VIRTUAL1 output exists
if ! xrandr | grep -q "^${DIS_NAME}"; then
  echo "Error: '${DIS_NAME}' output not found."
  echo "Available outputs:"
  xrandr | grep -E "^[A-Za-z].*connected"
  echo ""
  echo "You may need to enable virtual outputs. For the modesetting driver, add to /etc/X11/xorg.conf.d/20-virtual-monitor.conf:"
  echo '  Section "Device"'
  echo '    Identifier "GPU"'
  echo '    Driver "modesetting"'
  echo '    Option "VirtualHeads" "1"'
  echo '  EndSection'
  exit 1
fi

# Detect primary display
PRIMARY_DISPLAY=$(xrandr | perl -ne 'print "$1" if /(\S+)\s+connected\s+primary/')
if [ -z "$PRIMARY_DISPLAY" ]; then
  PRIMARY_DISPLAY=$(xrandr | perl -ne 'print "$1" if /(\S+)\s+connected/' | head -1)
fi
echo "Primary display: $PRIMARY_DISPLAY"

# Add display mode (clean up any stale state first)
read -ra RANDR_MODE <<<"$(cvt "$WIDTH" "$HEIGHT" 60 | sed -n '2s/.*Modeline "[^"]*"//p')"
xrandr --delmode "$DIS_NAME" "$MODE_NAME" 2>/dev/null
xrandr --rmmode "$MODE_NAME" 2>/dev/null
xrandr --newmode "$MODE_NAME" "${RANDR_MODE[@]}"
xrandr --addmode "$DIS_NAME" "$MODE_NAME"

# Cleanup on exit
X11VNC_PID=""
finish() {
  echo ""
  echo "Shutting down..."
  [ -n "$X11VNC_PID" ] && kill "$X11VNC_PID" 2>/dev/null
  xrandr --output "$DIS_NAME" --off
  xrandr --delmode "$DIS_NAME" "$MODE_NAME" 2>/dev/null
  echo "Virtual monitor disabled."
}
trap finish EXIT INT TERM

# Enable the virtual display
xrandr --output "$DIS_NAME" --mode "$MODE_NAME"
sleep 1
xrandr --output "$DIS_NAME" "$RANDR_POS" "$PRIMARY_DISPLAY"
sleep 1

# shellcheck source=/dev/null
[ -f ~/.fehbg ] && source ~/.fehbg

# Get the virtual display's geometry (e.g. 1024x768+1920+0)
CLIP_POS=$(xrandr | perl -ne "print \"\$1\" if /${DIS_NAME} connected (\\d+x\\d+\\+\\d+\\+\\d+)/")
if [ -z "$CLIP_POS" ]; then
  echo "Error: Could not determine virtual display geometry. xrandr output:"
  xrandr | grep "$DIS_NAME"
  exit 1
fi

echo "Virtual display geometry: $CLIP_POS"

if [ -f ~/secrets/vncpassword ]; then
  VNC_PASSWD=$(cat ~/secrets/vncpassword)
  echo "Using password from ~/secrets/vncpassword."
else
  read -r -s -p "VNC password (leave blank for none): " VNC_PASSWD
  echo ""
fi

LOCAL_IP=$(ip route get 1 2>/dev/null | perl -ne 'print "$1" if /src (\S+)/')
ZT_IFACE=$(ip link show | perl -ne 'print "$1" if /^\d+: (zt\S+):/')
ZT_IP=$(ip addr show "$ZT_IFACE" 2>/dev/null | perl -ne 'print "$1" if /inet (\S+?)\//')
echo "Connect your VNC client to:"
echo "  WiFi:     ${LOCAL_IP:-localhost}:${VNC_PORT}"
if [ -n "$ZT_IP" ]; then
  echo "  ZeroTier: ${ZT_IP}:${VNC_PORT}"
else
  echo "  ZeroTier: (no zt interface found)"
fi

X11VNC_OPTS=(-multiptr -repeat -clip "$CLIP_POS" -rfbport "$VNC_PORT"
  -defer 0 -wait 5 -threads -nosel -noprimary -quiet -forever)

if [ -n "$VNC_PASSWD" ]; then
  x11vnc "${X11VNC_OPTS[@]}" -passwd "$VNC_PASSWD" &
else
  echo "Warning: no password set -- use on trusted networks only."
  x11vnc "${X11VNC_OPTS[@]}" -nopw &
fi
X11VNC_PID=$!

echo "x11vnc started (PID: $X11VNC_PID). Press Ctrl+C to stop."
wait "$X11VNC_PID"
