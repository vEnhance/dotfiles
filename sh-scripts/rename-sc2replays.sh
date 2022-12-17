#!/bin/bash

for filename in ./*.SC2Replay; do
  if [[ $filename == *vEnhance* ]]; then
    echo "Already renamed $filename"
  else
    BASENAME="$(basename "$filename" | cut -f 1 -d '.' | cut -f 1 -d '(' | xargs)"
    TIMESTAMP="$(stat -c %W "$filename" | date +"%F %H%M%S")"
    mv "$filename" "vEnhance $BASENAME $TIMESTAMP.SC2Replay"
  fi
done
