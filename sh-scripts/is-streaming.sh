#!/usr/bin/env bash
# Exit 0 if this laptop should stay unlocked because a Twitch stream is live
# (streamed from another machine). Used by fuzzy-lock.sh and lock-warning.sh.
#
# decapi.me answers "vEnhance is offline" or an uptime like "1 hour, 2 minutes";
# only the uptime form counts, so errors and timeouts mean "not streaming".

{ [ "$(hostname)" = ArchUmi ] || [ "$(hostname)" = ArchScythe ]; } &&
  [ "$(whoami)" = evan ] &&
  curl -fsS -m 5 https://decapi.me/twitch/uptime/vEnhance |
  grep -qE '[0-9]+ (second|minute|hour)'
