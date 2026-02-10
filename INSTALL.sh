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

link_single_dotfile() {
  do_link "$HOME/dotfiles/dot/$1" "$HOME/.$1"
}

link_hidden_object() {
  mkdir -p "$(dirname "$HOME/.$1")"
  do_link "$HOME/dotfiles/$1" "$HOME/.$1"
}

cd "$HOME" || exit 1

link_hidden_object asy
link_hidden_object texmf
link_hidden_object vit

link_single_dotfile agignore
link_single_dotfile bashrc
link_single_dotfile chktexrc
link_single_dotfile eslintrc.yaml
link_single_dotfile gitconfig
link_single_dotfile gvimrc
link_single_dotfile latexmkrc
link_single_dotfile lisprc
link_single_dotfile mbsyncrc
link_single_dotfile screenrc
link_single_dotfile shellcheckrc
link_single_dotfile taskrc
link_single_dotfile tidyrc
link_single_dotfile xinitrc
link_single_dotfile xprofile

link_hidden_object config/bat
link_hidden_object config/borse
link_hidden_object config/dijo
link_hidden_object config/dunst
link_hidden_object config/feh
link_hidden_object config/fish
link_hidden_object config/i3
link_hidden_object config/miqin
link_hidden_object config/mutt
link_hidden_object config/ncdu
link_hidden_object config/nvim
link_hidden_object config/qutebrowser
link_hidden_object config/redshift
link_hidden_object config/rofi
link_hidden_object config/ruff
link_hidden_object config/von
link_hidden_object config/zathura

link_hidden_object config/gh/config.yml
link_hidden_object config/gtk-3.0/settings.ini
link_hidden_object config/nerd-dictation/nerd-dictation.py
link_hidden_object config/picom.conf
link_hidden_object config/vale/.vale.ini
link_hidden_object config/vale/vale-styles
link_hidden_object config/xfce4/terminal

mkdir -p "$HOME"/.vim/tmp/
link_hidden_object vim/after
link_hidden_object vim/colors
link_hidden_object vim/doc
link_hidden_object vim/snips
link_hidden_object vim/vimrc

link_hidden_object claude/settings.json
link_hidden_object jupyter/jupyter_notebook_config.py
link_hidden_object local/share/gh/extensions
link_hidden_object local/share/typst
link_hidden_object task/hooks

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
