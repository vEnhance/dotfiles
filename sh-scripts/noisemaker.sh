#!/bin/bash

if [ -f /usr/bin/mpg321 ]; then
	PLAYER=mpg321
else
	PLAYER=mpg123
fi

if pgrep -U $(whoami) $PLAYER > /dev/null
then
	if [ "$1" = a ]; then
		$PLAYER -q -f -18000 $HOME/dotfiles/noisemaker/Sa-horn.mp3 &
		exit
	else
		pkill $PLAYER
	fi
fi

if [ "$1" = 1 ]; then
	$PLAYER -q $HOME/dotfiles/noisemaker/S1-applause.mp3 &
fi

if [ "$1" = 2 ]; then
	$PLAYER -q -f -9000 $HOME/dotfiles/noisemaker/S2-success.mp3 &
fi

if [ "$1" = 3 ]; then
	$PLAYER -q -f 15000 $HOME/dotfiles/noisemaker/S3-fanfare.mp3 &
fi

if [ "$1" = 4 ]; then
	$PLAYER -q $HOME/dotfiles/noisemaker/S4-correct.mp3 &
fi

if [ "$1" = 5 ]; then
	$PLAYER -q $HOME/dotfiles/noisemaker/S5-cashreg.mp3 &
fi

if [ "$1" = 6 ]; then
	$PLAYER -q -f -13000 $HOME/dotfiles/noisemaker/S6-metal.mp3 &
fi

if [ "$1" = 7 ]; then
	$PLAYER -q $HOME/dotfiles/noisemaker/S7-drum.mp3 &
fi

if [ "$1" = 8 ]; then
	$PLAYER -q $HOME/dotfiles/noisemaker/S8-boo.mp3 &
fi

if [ "$1" = 9 ]; then
	$PLAYER -q -f -18000 $HOME/dotfiles/noisemaker/S9-taratata.mp3 &
fi

if [ "$1" = 0 ]; then
	$PLAYER -q $HOME/dotfiles/noisemaker/S0-success.mp3 &
fi

if [ "$1" = a ]; then
	$PLAYER -q -f -18000 $HOME/dotfiles/noisemaker/Sa-horn.mp3 &
fi
