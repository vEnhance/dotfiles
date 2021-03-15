#!/bin/bash

if pgrep -U $(whoami) mpg123 > /dev/null
then
	if [ "$1" = a ]; then
		mpg123 -f -18000 $HOME/dotfiles/noisemaker/Sa-horn.mp3
		exit
	else
		pkill mpg123
	fi
fi

if [ "$1" = 1 ]; then
	mpg123 $HOME/dotfiles/noisemaker/S1-applause.mp3
fi

if [ "$1" = 2 ]; then
	mpg123 -f -9000 $HOME/dotfiles/noisemaker/S2-success.mp3
fi

if [ "$1" = 3 ]; then
	mpg123 -f 15000 $HOME/dotfiles/noisemaker/S3-fanfare.mp3
fi

if [ "$1" = 4 ]; then
	mpg123 $HOME/dotfiles/noisemaker/S4-correct.mp3
fi

if [ "$1" = 5 ]; then
	mpg123 $HOME/dotfiles/noisemaker/S5-cashreg.mp3
fi

if [ "$1" = 6 ]; then
	mpg123 -f -13000 $HOME/dotfiles/noisemaker/S6-metal.mp3
fi

if [ "$1" = 7 ]; then
	mpg123 $HOME/dotfiles/noisemaker/S7-drum.mp3
fi

if [ "$1" = 8 ]; then
	mpg123 $HOME/dotfiles/noisemaker/S8-boo.mp3
fi

if [ "$1" = 9 ]; then
	mpg123 -f -18000 $HOME/dotfiles/noisemaker/S9-taratata.mp3
fi

if [ "$1" = 0 ]; then
	mpg123 $HOME/dotfiles/noisemaker/S0-success.mp3
fi

if [ "$1" = a ]; then
	mpg123 -f -18000 $HOME/dotfiles/noisemaker/Sa-horn.mp3
fi


