#!/usr/bin/env bash

set -euo pipefail

if pgrep -x dijo >/dev/null; then
  echo "Already running dijo. Not starting a new process."
  read -r -p "Press any key to continue."
  exit 0
fi

DATE="$(date +"%Y-%m-%d")"
HAS_RUN_DIJO=$(jq ".[]|select(.name==\"dijo\")|.stats|.\"$DATE\"" <~/Sync/share/dijo/habit_record\[auto\].json)

if [ "$HAS_RUN_DIJO" != "true" ]; then
  dijo -c "track-up dijo"
fi

dijo

cd ~/.local/share/dijo/ || exit 1
jq -S "." <"habit_record.json" | sponge "habit_record.json"
jq -S "." <"habit_record[auto].json" | sponge "habit_record[auto].json"

if [ "$HAS_RUN_DIJO" != "true" ]; then
  if ! git diff --exit-code; then
    git commit -a -m "$(date), snapshot taken on $(hostname)"
  fi
fi
