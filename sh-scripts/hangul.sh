#!/usr/bin/env bash
set -euxo pipefail

# Dvorak w -> QWERTY comma
xmodmap -e "keycode 59 = comma less comma less"
# Dvorak v -> QWERTY period
xmodmap -e "keycode 60 = period greater period greater"
# Dvorak z -> QWERTY slash
xmodmap -e "keycode 61 = slash question slash question"
# Dvorak s -> QWERTY colon
xmodmap -e "keycode 47 = semicolon colon semicolon colon"
# Dvorak - -> QWERTY colon
xmodmap -e "keycode 48 = apostrophe quotedbl apostrophe quotedbl"

if pgrep -x ibus-daemon; then
  ibus engine "hangul"
fi

notify-send -i "airplane-mode" -t 5000 \
  "한굴어 입력 활성화됨" \
  "에반씨 너무 미쳤어"
