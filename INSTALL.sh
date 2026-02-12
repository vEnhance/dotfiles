#!/bin/bash

# Use at your own risk ;)
# makes many symlinks

set -euo pipefail

do_link() {
  src="$1"
  target="$2"
  if [ -L "$target" ] && [ ! -e "$target" ]; then
    echo "Replacing broken symlink: $target"
    rm "$target"
    ln -s "$src" "$target"
  elif [ ! -e "$target" ]; then
    echo "Creating: $target"
    ln -s "$src" "$target"
  elif [ -d "$target" ] && [ ! -L "$target" ] && [ -d "$src" ]; then
    echo "WARNING: real directory exists where symlink expected: $target"
  fi
}

link_dot_path() {
  mkdir -p "$(dirname "$HOME/.$1")"
  do_link "$HOME/dotfiles/dot/$1" "$HOME/.$1"
}

link_hidden_path() {
  mkdir -p "$(dirname "$HOME/.$1")"
  do_link "$HOME/dotfiles/$1" "$HOME/.$1"
}

cd "$HOME" || exit 1

link_dot_path agignore
link_dot_path bashrc
link_dot_path chktexrc
link_dot_path eslintrc.yaml
link_dot_path gitconfig
link_dot_path gvimrc
link_dot_path latexmkrc
link_dot_path lisprc
link_dot_path mbsyncrc
link_dot_path screenrc
link_dot_path shellcheckrc
link_dot_path taskrc
link_dot_path tidyrc
link_dot_path xinitrc
link_dot_path xprofile

link_dot_path abook
link_dot_path claude/settings.json
link_dot_path jupyter/jupyter_notebook_config.py
link_dot_path vit

link_hidden_path config/bat
link_hidden_path config/borse
link_hidden_path config/dijo
link_hidden_path config/dunst
link_hidden_path config/feh
link_hidden_path config/fish
link_hidden_path config/i3
link_hidden_path config/miqin
link_hidden_path config/mutt
link_hidden_path config/ncdu
link_hidden_path config/nvim
link_hidden_path config/qutebrowser
link_hidden_path config/redshift
link_hidden_path config/rofi
link_hidden_path config/ruff
link_hidden_path config/von
link_hidden_path config/zathura

link_hidden_path config/gh/config.yml
link_hidden_path config/gtk-3.0/settings.ini
link_hidden_path config/nerd-dictation/nerd-dictation.py
link_hidden_path config/picom.conf
link_hidden_path config/vale/.vale.ini
link_hidden_path config/vale/vale-styles
link_hidden_path config/xfce4/terminal

link_hidden_path asy
link_hidden_path texmf
link_hidden_path task/hooks
link_hidden_path local/share/gh/extensions
link_hidden_path local/share/typst

mkdir -p "$HOME"/.vim/tmp/
link_hidden_path vim/after
link_hidden_path vim/colors
link_hidden_path vim/doc
link_hidden_path vim/snips
link_hidden_path vim/vimrc

# py3status installation (host-dependent)
cd "$HOME"/dotfiles/py3status/ || exit 1
if ! make -q 2>/dev/null; then
  make
fi
cd "$HOME" || exit 1
mkdir -p "$HOME"/.config/py3status
ln -sf "$HOME/dotfiles/py3status/py3status.$(hostname).conf" "$HOME"/.config/py3status/config

if [ "$USER" = "evan" ]; then
  xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop
  xdg-settings set default-url-scheme-handler https org.qutebrowser.qutebrowser.desktop
  # xfconf-query -c xfce4-session -p /general/LockCommand -s "loginctl lock-session"
fi
