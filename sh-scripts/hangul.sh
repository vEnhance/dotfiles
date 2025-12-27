#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Enable Hangul input via ibus.

Options:
  -r, --remap   Remap Dvorak keys to QWERTY punctuation via xmodmap
  -h, --help    Show this help message and exit
EOF
}

remap=false
while [[ $# -gt 0 ]]; do
  case $1 in
  -r | --remap)
    remap=true
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
done

if $remap; then
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
fi

if pgrep -x ibus-daemon; then
  ibus engine "hangul"
else
  notify-send --urgency=critical "ibus 이용 불가" "한글 입력을 활성화할 수 없습니다"
  exit 1
fi

if $remap; then
  notify-send -i "network-workgroup" -t 5000 \
    "전체 한글어 입력 활성화됨!" \
    "에반씨 너무 미쳤어"
else
  notify-send -i "airplane-mode" -t 5000 \
    "기본 한글어 입력 활성화됨." \
    "에반씨 너무 멍청해"
fi
