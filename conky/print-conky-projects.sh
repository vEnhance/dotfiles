#!/usr/bin/env bash
set -euo pipefail

if [ "$(whoami)" != "evan" ]; then
  exit
fi
grep "^# " ~/Sync/HQ/Projects.md | cut -c 3-
