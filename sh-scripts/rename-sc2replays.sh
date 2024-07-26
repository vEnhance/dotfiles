#!/usr/bin/env bash

set -o xtrace
set -e

for filename in ./*.SC2Replay; do
  if [[ $filename == *vEnhance* ]]; then
    echo "Already renamed $filename"
  else
    BASENAME="$(basename "$filename" | cut -f 1 -d '.' | cut -f 1 -d '(' | xargs)"
    TIMESTAMP=$(date +"%F %H%M%S" -d "@$(stat -c "%W" "$filename")")
    mv --no-clobber "$filename" "vEnhance $BASENAME $TIMESTAMP.SC2Replay"
  fi
done
