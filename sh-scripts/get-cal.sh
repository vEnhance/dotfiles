#!/usr/bin/env bash
set -euo pipefail

# Caches the next two weeks of events at ~/.cache/agenda.json,
# where conky/agenda.py consumes them.
# Pass --notify to get desktop notifications when the sync starts and ends.

notify=false
if [[ ${1:-} == "--notify" ]]; then
  notify=true
fi

tmpfile=$(mktemp)

cleanup() {
  local status=$?
  rm -f "$tmpfile"
  if $notify; then
    if [[ $status -eq 0 ]]; then
      notify-send "get-cal.sh" "Agenda updated"
    else
      notify-send -u critical "Calendar sync failed" "get-cal.sh exited with status $status"
    fi
  fi
}
trap cleanup EXIT

if $notify; then
  notify-send "get-cal.sh" "Fetching events..."
fi

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
if ! jq -e 'type == "array"' "$tmpfile" >/dev/null; then
  echo "No data" >&2
  exit 1
fi

chmod 644 "$tmpfile"
mv "$tmpfile" ~/.cache/agenda.json
