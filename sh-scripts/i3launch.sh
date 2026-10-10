#!/usr/bin/env bash
# Usage: i3launch.sh SLUG
#
# Things bound in i3/config that need more than a bare command.
# Plain one-command launches (e.g. `discord &`) stay inline in i3/config;
# anything that needs a terminal with custom settings, several steps,
# or a small amount of logic lives here instead.
set -euo pipefail

# Run the rest of the arguments inside xfce4-terminal.
# Terminal options (--title, --zoom, --working-directory, ...) go first.
term() {
  local opts=()
  while [[ $# -gt 0 && $1 == --* ]]; do
    opts+=("$1")
    shift
  done
  exec xfce4-terminal "${opts[@]}" -x "$@"
}

# Run the rest of the arguments in ghostty with a big font.
# SIZE is tuned for ArchDiamond and scaled down on smaller setups.
bigterm() {
  local size=$1
  shift
  case "$(hostname)" in
    ArchMajestic) size=$((size * 85 / 100)) ;;
    ArchScythe | ArchUmi) size=$((size * 60 / 100)) ;;
  esac
  exec ghostty --font-size="$size" -e "$@"
}

case "${1:-}" in
  anki)
    export LANG="ko_KR.UTF-8"
    export LC_ALL="ko_KR.UTF-8"
    case "$(hostname)" in
      ArchDiamond) export QT_SCALE_FACTOR=3 ;;
      ArchBootes | ArchMajestic) export QT_SCALE_FACTOR=2.5 ;;
      ArchScythe | ArchUmi) export QT_SCALE_FACTOR=2 ;;
    esac
    exec anki
    ;;
  asy)
    term sh -c "/usr/bin/python3 ~/dotfiles/py-scripts/export-ggb-clean-asy.py --speedy && ~/dotfiles/sh-scripts/getclip.sh"
    ;;
  borse)
    bigterm 42 borse
    ;;
  cards)
    term ~/dotfiles/sh-scripts/grab-password-from-vault.sh cards
    ;;
  claude)
    term ~/dotfiles/boxed-claude/ro-claude.sh
    ;;
  diary)
    latest="$(python ~/diary/scripts/latest.py)"
    term --working-directory="$HOME/diary" vim "$latest"
    ;;
  hq)
    term --working-directory="$HOME/Sync/HQ" vim Projects.md
    ;;
  miqin)
    bigterm 29 python3 ~/Sync/Projects/miqin/miqin.py
    ;;
  orch)
    term --title=OTIS-ARCH ~/dotfiles/py-scripts/orch.py
    ;;
  otis)
    exec gvim \
      -c ":let g:venue_entry='~/dotfiles/py-scripts/venueQ/otis.py'" \
      -c ":source ~/dotfiles/py-scripts/venueQ/venueQ.vim"
    ;;
  password)
    # Clear the secondary selection 10 minutes later,
    # whether or not the terminal is still open.
    xfce4-terminal -x ~/dotfiles/sh-scripts/grab-password-from-vault.sh &
    sleep 600
    xsel --secondary --delete
    ;;
  pyjo)
    bigterm 29 /usr/bin/python3 ~/dotfiles/py-scripts/pyjo.py
    ;;
  spotify)
    exec ghostty -e spotify_player
    ;;
  vit)
    term --title=VIMTODO vit
    ;;
  yap)
    term fish --login --command yap
    ;;
  *)
    echo "i3launch.sh: unknown slug '${1:-}'" >&2
    exit 1
    ;;
esac
