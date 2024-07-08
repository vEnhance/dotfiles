#!/bin/bash

set -euxo pipefail

HAS_RUN_DIJO=$(jq '.[]|select(.name=="dijo")|.stats|."2024-07-08"' <~/Sync/Personal/dijo/habit_record\[auto\].json)
if [ "$HAS_RUN_DIJO" != "true" ]; then
  dijo -c "track-up dijo"
fi

dijo

cd ~/Sync/Personal/dijo/ || exit 1

if [ "$HAS_RUN_DIJO" != "true" ]; then
  if ! git diff --exit-code; then
    git commit -a -m "$(date), snapshot taken on $(hostname)"
  fi
fi
