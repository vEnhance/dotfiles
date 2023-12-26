#!/bin/bash

set -euxo pipefail

# Runs some routine taskwarrior work
task sync

if command -v bugwarrior-pull >/dev/null; then
  bugwarrior-pull
fi

task rc.recurrence.limit=1 list

task sync
