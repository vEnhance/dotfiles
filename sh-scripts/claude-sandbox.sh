#!/bin/bash

set -euo pipefail

# Create a temporary empty directory to use as the working directory
TEMP_DIR=/tmp/claude
mkdir -p "$TEMP_DIR"

echo "Starting Claude Code in sandbox mode..."
echo "Working directory: $TEMP_DIR"
echo "File access is restricted - no Read, Write, Edit, or file operations allowed."
echo

# Launch Claude Code with restricted permissions
cd "$TEMP_DIR" && claude \
  --disallowedTools "Read" "Write" "Edit" "MultiEdit" "NotebookEdit" "Glob" "LS" "Grep" \
  --permission-mode "default"
