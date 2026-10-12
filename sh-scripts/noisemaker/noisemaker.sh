#!/usr/bin/env bash

DIR="$(dirname "$0")"

# play <file> [volume]
play() {
  pw-play --latency 20ms --volume "${2:-1}" "$DIR/$1" &
}

if pgrep -U "$(whoami)" pw-play >/dev/null; then
  if [ "$1" = a ]; then
    play Sa-horn.mp3 0.549
    exit
  else
    pkill -U "$(whoami)" pw-play
  fi
fi

case "$1" in
  1) play S1-applause.mp3 ;;
  2) play S2-success.mp3 0.275 ;;
  3) play S3-fanfare.mp3 0.458 ;;
  4) play S4-correct.mp3 ;;
  5) play S5-cashreg.mp3 ;;
  6) play S6-metal.mp3 0.397 ;;
  7) play S7-drum.mp3 ;;
  8) play S8-boo.mp3 ;;
  9) play S9-taratata.mp3 0.549 ;;
  0) play S0-success.mp3 ;;
  a) play Sa-horn.mp3 0.549 ;;
  B) play SB-buzz.mp3 2.441 ;;
  N) play SN-nooo.mp3 2.441 ;;
  H) play SH-holy.mp3 2.441 ;;
  g) ;; # just stop whatever is playing (done above)
esac
