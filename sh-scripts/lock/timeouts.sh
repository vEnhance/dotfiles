#!/usr/bin/env bash
# Idle auto-lock timing: the one place the per-host timeouts live.
#
#   timeouts.sh apply    set the normal timeouts (xprofile, and after unlock)
#   timeouts.sh extend   lock after EXTENDED seconds instead (presentations);
#                         lasts until the next lock or `apply`
#   timeouts.sh toggle   extend, or back to normal if already extended
#   timeouts.sh normal   print the normal lock-after seconds
#
# xss-lock runs warning.sh at the screensaver timeout and lock.sh
# one cycle (WARN seconds) later; the screen turns off when it locks.
set -euo pipefail

WARN=60
EXTENDED=$((3 * 3600))

normal() {
  case "$(hostname)/$(whoami)" in
  ArchDiamond/star | ArchMajestic/star | ArchBootes/star) echo 1800 ;;
  ArchDiamond/* | ArchMajestic/* | ArchBootes/*) echo 900 ;;
  *) echo 600 ;; # laptops and anything else
  esac
}

set_lock_after() {
  xset s $(($1 - WARN)) "$WARN"
  xset dpms "$1" "$1" "$1"
}

notify() {
  notify-send -i "system-lock-screen" -a "Auto-lock" \
    -h string:x-dunst-stack-tag:idle-lock "$@"
  killall -s USR1 py3status 2>/dev/null || true
}

case "${1:-}" in
apply) set_lock_after "$(normal)" ;;
extend)
  set_lock_after "$EXTENDED"
  notify "Auto-lock extended" "Locks after $((EXTENDED / 3600))h idle, until the next lock."
  ;;
toggle)
  timeout=$(xset q | awk '/timeout:/ { print $2 }')
  if [ $((timeout + WARN)) -gt "$(normal)" ]; then
    set_lock_after "$(normal)"
    notify "Auto-lock normal" "Locks after $(($(normal) / 60))min idle."
  else
    "$0" extend
  fi
  ;;
normal) normal ;;
*)
  echo "usage: $0 apply|extend|toggle|normal" >&2
  exit 2
  ;;
esac
