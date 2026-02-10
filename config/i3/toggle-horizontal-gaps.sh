#!/bin/bash

set -euo pipefail

# Script to toggle horizontal gaps on the current workspace
# Uses i3's built-in gap functionality

# Get current focused workspace name and number
workspace_info=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true) | "\(.num):\(.name)"')
workspace_num=$(echo "$workspace_info" | cut -d: -f1)
workspace_name=$(echo "$workspace_info" | cut -d: -f2-)
output_name=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).output')

monitor_width=1920
if [ "$(hostname)" == "ArchDiamond" ]; then
  if [ "$output_name" == "DP-2" ]; then
    monitor_width=3840
  elif [ "$output_name" == "DP-3" ]; then
    monitor_width=2560
  fi
fi

if [ -n "$monitor_width" ] && [ "$monitor_width" -gt 2048 ]; then
  gap_size=$(((monitor_width - 2048) / 2))
else
  gap_size=0
fi

# Check current gap settings for that workspace
current_gaps=$(i3-msg -t get_tree | jq -r --arg ws "$workspace_name" '.. | objects | select(.type=="workspace" and .name==$ws) | .gaps.left // .gaps // 0')

# Get default gap values from extras file
extras_file="$HOME/dotfiles/config/i3/extras.$(hostname)"
default_left_gap=0
default_right_gap=0

if [ -f "$extras_file" ]; then
  # Parse gaps from extras file for this workspace
  if grep -q "^workspace $workspace_num gaps left" "$extras_file"; then
    default_left_gap=$(grep "^workspace $workspace_num gaps left" "$extras_file" | awk '{print $5}')
  fi
  if grep -q "^workspace $workspace_num gaps right" "$extras_file"; then
    default_right_gap=$(grep "^workspace $workspace_num gaps right" "$extras_file" | awk '{print $5}')
  fi
fi

if [ "$current_gaps" = "0" ] || [ "$current_gaps" = "null" ] || [ -z "$current_gaps" ] || [ "$current_gaps" = "$default_left_gap" ]; then
  # No gaps currently or at default, add calculated gaps
  i3-msg "gaps left current set $gap_size"
  i3-msg "gaps right current set $gap_size"
else
  # Gaps exist, reset to default values
  i3-msg "gaps left current set $default_left_gap"
  i3-msg "gaps right current set $default_right_gap"
fi
