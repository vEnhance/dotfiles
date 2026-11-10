#!/usr/bin/env bash
# py3status external_script: time until xss-lock auto-locks the session.
# Normally shown only during the last 5 minutes, orange in the final minute
# (when the warning fires), or the reason from blocker.sh if the lock
# won't happen. Always shown while `timeouts.sh extend` is in effect, so
# it can't be forgotten on.
#
# Blind spot: apps that suspend the screensaver (SDL games, video players)
# aren't visible to xset, so the countdown can run out without a lock.
set -uo pipefail

idle_ms=$(xprintidle) || exit 0
read -r timeout cycle < <(xset q | awk '/timeout:/ { print $2, $4 }')
[ -n "${timeout:-}" ] && [ "$timeout" -gt 0 ] || exit 0 # no idle lock at all

lock_after=$((timeout + cycle))
left=$((lock_after - idle_ms / 1000))
[ "$left" -gt 0 ] || exit 0 # lock time passed; skipped or covered by i3lock

if [ "$lock_after" -gt "$(~/dotfiles/sh-scripts/lock/timeouts.sh normal)" ]; then
  printf '⏳%d:%02d:%02d\n#00AAFF\n' $((left / 3600)) $((left % 3600 / 60)) $((left % 60))
  exit 0
fi

[ "$left" -le 300 ] || exit 0

if reason=$(~/dotfiles/sh-scripts/lock/blocker.sh); then
  echo "🔓$reason"
  exit 0
fi

if [ "$left" -le 60 ]; then
  printf '🔒%d:%02d\n#FFAA00\n' $((left / 60)) $((left % 60))
else
  printf '🔒%d:%02d\n' $((left / 60)) $((left % 60))
fi
