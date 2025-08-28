#!/usr/bin/env bash
set -euxo pipefail

# if ibus is active, switch back to Eng/Dvorak
if pgrep -x ibus-daemon; then
  ibus engine "hangul"
fi

notify-send -i "airplane-mode" -t 5000 \
  "한굴어 입력 활성화됨" \
  "에반씨 너무 미쳤어"
