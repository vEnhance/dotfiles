#!/usr/bin/env bash
set -euo pipefail

# Caches the next two weeks of events at ~/.cache/agenda.json,
# where conky/agenda.py consumes them.

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

gcalendar --no-of-days 14 --output json \
  --calendar "日曆" \
  "Break" \
  "Events" \
  "Friends" \
  "Garbage" \
  "Happiness" \
  "Important" \
  "Leisure" \
  "Prison" \
  "Real Life" \
  "Schedule" \
  "Unfortunate Things" \
  "White" \
  "Zero-Minute Reminders" \
  "evan@evanchen.cc" \
  "twitch.tv" \
  "evanchen.records" \
  "evan@axiommath.ai" >"$tmpfile"

# gcalendar reports failure as an object with an "error" key, so only clobber
# the cache once we know we got an actual list of events back
if ! jq -e 'type == "array"' >/dev/null "$tmpfile"; then
  echo "No data" >&2
  exit 1
fi

chmod 644 "$tmpfile"
mv "$tmpfile" ~/.cache/agenda.json
