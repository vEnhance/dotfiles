#!/bin/bash

set -euo pipefail

CLAUDE_DIR=~/Sync/Logs/claude

echo "Starting Claude Code in sandbox mode..."
echo "Working directory: $CLAUDE_DIR"
echo "File access is restricted - no Read, Edit, or file operations allowed."
echo

# Launch Claude Code with restricted permissions
cd "$CLAUDE_DIR" && claude \
  --disallowed-tools "Read" "Edit" "MultiEdit" "NotebookEdit" "Glob" "Bash" "Grep" \
  --permission-mode "default"
