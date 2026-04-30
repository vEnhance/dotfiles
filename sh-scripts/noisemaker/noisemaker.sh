#!/usr/bin/env bash

if [ -f /usr/bin/mpg321 ]; then
  PLAYER=mpg321
else
  PLAYER=mpg123
fi

DIR="$(dirname "$0")"

if pactl list sinks short | grep soundboard_mix >/dev/null; then
  export PULSE_SINK=soundboard_router
fi

if pgrep -U "$(whoami)" "$PLAYER" >/dev/null; then
  if [ "$1" = a ]; then
    "$PLAYER" -o pulse -q -f -18000 "$DIR"/Sa-horn.mp3 &
    exit
  else
    pkill "$PLAYER"
  fi
fi

if [ "$1" = 1 ]; then
  "$PLAYER" -o pulse -q "$DIR"/S1-applause.mp3 &
fi
if [ "$1" = 2 ]; then
  "$PLAYER" -o pulse -q -f -9000 "$DIR"/S2-success.mp3 &
fi
if [ "$1" = 3 ]; then
  "$PLAYER" -o pulse -q -f 15000 "$DIR"/S3-fanfare.mp3 &
fi
if [ "$1" = 4 ]; then
  "$PLAYER" -o pulse -q "$DIR"/S4-correct.mp3 &
fi
if [ "$1" = 5 ]; then
  "$PLAYER" -o pulse -q "$DIR"/S5-cashreg.mp3 &
fi
if [ "$1" = 6 ]; then
  "$PLAYER" -o pulse -q -f -13000 "$DIR"/S6-metal.mp3 &
fi
if [ "$1" = 7 ]; then
  "$PLAYER" -o pulse -q "$DIR"/S7-drum.mp3 &
fi
if [ "$1" = 8 ]; then
  "$PLAYER" -o pulse -q "$DIR"/S8-boo.mp3 &
fi
if [ "$1" = 9 ]; then
  "$PLAYER" -o pulse -q -f -18000 "$DIR"/S9-taratata.mp3 &
fi
if [ "$1" = 0 ]; then
  "$PLAYER" -o pulse -q "$DIR"/S0-success.mp3 &
fi

if [ "$1" = a ]; then
  "$PLAYER" -o pulse -q -f -18000 "$DIR"/Sa-horn.mp3 &
fi
if [ "$1" = B ]; then
  "$PLAYER" -o pulse -q -f -80000 "$DIR"/SB-buzz.mp3 &
fi
if [ "$1" = N ]; then
  "$PLAYER" -o pulse -q -f -80000 "$DIR"/SN-nooo.mp3 &
fi
if [ "$1" = H ]; then
  "$PLAYER" -o pulse -q -f -80000 "$DIR"/SH-holy.mp3 &
fi
