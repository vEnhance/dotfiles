#!/usr/bin/env bash

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
  "evan@axiommath.ai" | python ~/dotfiles/py-scripts/get-cal-helper.py
