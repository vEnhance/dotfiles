#!/bin/bash
# Shared helpers for installers/*.sh. Source this; don't run it.

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES

BOLD_CYN="\033[1;36m"
BOLD_GRN="\033[1;32m"
BOLD_YLW="\033[1;33m"
BOLD_RED="\033[1;31m"
RESET="\033[0m"

do_link() {
  local src="$1"
  local target="$2"
  if [ -L "$target" ] && [ ! -e "$target" ]; then
    echo -e "${BOLD_CYN}UPDATED:${RESET} Fixed broken symlink: $target"
    rm "$target"
    ln -s "$src" "$target"
  elif [ ! -e "$target" ]; then
    echo -e "${BOLD_GRN}CREATED:${RESET} New symlink created:  $target"
    ln -s "$src" "$target"
  elif [ -d "$target" ] && [ ! -L "$target" ] && [ -d "$src" ]; then
    echo -e "${BOLD_RED}WARNING:${RESET} Real directory found: $target"
  fi
}

# link_dot_path foo  =>  ~/.foo -> $DOTFILES/dot/foo
link_dot_path() {
  mkdir -p "$(dirname "$HOME/.$1")"
  do_link "$DOTFILES/dot/$1" "$HOME/.$1"
}

# link_hidden_path foo  =>  ~/.foo -> $DOTFILES/foo
link_hidden_path() {
  mkdir -p "$(dirname "$HOME/.$1")"
  do_link "$DOTFILES/$1" "$HOME/.$1"
}

warn() {
  echo -e "${BOLD_YLW}SKIPPED:${RESET} $*"
}
