#!/usr/bin/env bash

set -euxo pipefail

DATE="$(date +"%Y-%m-%d")"
HAS_RUN_DIJO=$(jq ".[]|select(.name==\"dijo\")|.stats|.\"$DATE\"" <~/Sync/Personal/dijo/habit_record\[auto\].json)

if [ "$HAS_RUN_DIJO" != "true" ]; then
  dijo -c "track-up dijo"
fi

dijo

cd ~/Sync/Personal/dijo/ || exit 1
jq -S "." <"habit_record.json" | sponge "habit_record.json"
jq -S "." <"habit_record[auto].json" | sponge "habit_record[auto].json"

if [ "$HAS_RUN_DIJO" != "true" ]; then
  if ! git diff --exit-code; then
    git commit -a -m "$(date), snapshot taken on $(hostname)"
  fi
fi
