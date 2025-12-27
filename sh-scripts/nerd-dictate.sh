#!/usr/bin/env bash

set -euo pipefail

ON_MIC_FLAG="/tmp/nd.1.$(whoami)"
OFF_MIC_FLAG="/tmp/nd.0.$(whoami)"
COOKIE_PATH="/tmp/nd.$(whoami)"

#!/usr/bin/env bash
if [ $# -ge 1 ]; then
  COMMAND="$1"
else
  COMMAND="toggle"
fi

# End dictation if either of the flag files is present
if [ -f "$ON_MIC_FLAG" ] || [ -f "$OFF_MIC_FLAG" ] || [ "$COMMAND" = "stop" ]; then
  # nerd-dictation end
  if [ -f "$ON_MIC_FLAG" ]; then
    rm "$ON_MIC_FLAG"
  fi
  if [ -f "$OFF_MIC_FLAG" ]; then
    ~/dotfiles/sh-scripts/chvol.sh m
    rm "$OFF_MIC_FLAG"
  fi

  nerd-dictation end --cookie "$COOKIE_PATH"
  notify-send -i "checkmark" \
    "All done!" \
    "Nerd Dictation has completed."
  ~/dotfiles/sh-scripts/noisemaker.sh 0

  exit 0
fi

# Otherwise, unmute microphone and start dictation
nerd-dictation begin --full-sentence --cookie "$COOKIE_PATH" &
if ponymix is-muted --source; then
  ~/dotfiles/sh-scripts/chvol.sh w
  touch "$OFF_MIC_FLAG"
else
  touch "$ON_MIC_FLAG"
fi
notify-send -i "sound-recorder" \
  "Recording in progress" \
  "In the words of Taylor Swift, speak now."
~/dotfiles/sh-scripts/noisemaker.sh 6
