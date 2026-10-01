#!/bin/bash

set -euo pipefail

cmd=(
  claude
  --disallowed-tools Read Edit NotebookEdit Glob Bash Grep
  --permission-mode default
)
~/dotfiles/sh-scripts/box.sh -C "$HOME/Sync/Logs/claude/" "${cmd[@]}"
