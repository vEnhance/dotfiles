#!/usr/bin/env bash

set -o xtrace
set -e

COOP_MAPS=(
  "Chain of Ascension"
  "Cradle of Death"
  "Dead of Night"
  "Lock & Load"
  "Malwarfare"
  "Miner Evacuation"
  "Mist Opportunities"
  "Oblivion Express"
  "Part and Parcel"
  "Rifts to Korhal"
  "Scythe of Amon"
  "Temple of the Past"
  "The Vermillion Problem"
  "Void Launch"
  "Void Thrashing"
)

for filename in ./*.SC2Replay; do
  if [[ $filename == *vEnhance* ]]; then
    echo "Already renamed $filename"
  else
    BASENAME="$(basename "$filename" | cut -f 1 -d '.' | cut -f 1 -d '(' | sed 's/[[:space:]]*$//')"
    TIMESTAMP=$(date +"%F %H%M%S" -d "@$(stat -c "%W" "$filename")")

    matched=false
    # Loop through each prefix in the array
    for prefix in "${COOP_MAPS[@]}"; do
      if [[ $filename == "$prefix"* ]]; then
        matched=true
        break
      fi
    done
    if $matched; then
      mv --no-clobber "$filename" "COOP vEnhance $BASENAME $TIMESTAMP.SC2Replay"
    else
      mv --no-clobber "$filename" "vEnhance $BASENAME $TIMESTAMP.SC2Replay"
    fi
  fi
done
