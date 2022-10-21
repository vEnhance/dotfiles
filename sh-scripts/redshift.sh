#!/bin/bash

if [ "$(date +'%Z')" = "EDT" ] || [ "$(date +'%Z')" = "EST" ]; then
	redshift-gtk -l 42.360047332672245:-71.08832414389188 &
elif [ "$(date +'%Z')" = "PDT" ] || [ "$(date +'%Z')" = "PST" ]; then
	redshift-gtk -l 37.48822383413607:-121.9304748269479 &
else
	redshift-gtk &
fi
