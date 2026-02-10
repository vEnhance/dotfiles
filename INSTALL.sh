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

link_config_dir() {
  do_link "$HOME/dotfiles/$1" "$HOME/.config/$1"
}

link_home_hidden_object() {
  mkdir -p "$(dirname "$HOME/.$1")"
  do_link "$HOME/dotfiles/$1" "$HOME/.$1"
}

link_single_dotfile() {
  do_link "$HOME/dotfiles/dot/$1" "$HOME/.$1"
}

cd "$HOME" || exit 1

link_config_dir bat
link_config_dir borse
link_config_dir dijo
link_config_dir dunst
link_config_dir feh
link_config_dir fish
link_config_dir i3
link_config_dir miqin
link_config_dir mutt
link_config_dir ncdu
link_config_dir nvim
link_config_dir qutebrowser
link_config_dir redshift
link_config_dir rofi
link_config_dir ruff
link_config_dir von
link_config_dir zathura

link_home_hidden_object asy
link_home_hidden_object texmf
link_home_hidden_object vit

link_single_dotfile agignore
link_single_dotfile bashrc
link_single_dotfile chktexrc
link_single_dotfile eslintrc.yaml
link_single_dotfile gitconfig
link_single_dotfile gvimrc
link_single_dotfile latexmkrc
link_single_dotfile mbsyncrc
link_single_dotfile screenrc
link_single_dotfile shellcheckrc
link_single_dotfile taskrc
link_single_dotfile tidyrc
link_single_dotfile xinitrc
link_single_dotfile xprofile

link_home_hidden_object config/gh/config.yml
link_home_hidden_object config/gtk-3.0/settings.ini
link_home_hidden_object config/nerd-dictation/nerd-dictation.py
link_home_hidden_object config/picom.conf
link_home_hidden_object config/vale/.vale.ini
link_home_hidden_object config/vale/vale-styles
link_home_hidden_object config/xfce4/terminal

mkdir -p "$HOME"/.vim/tmp/
link_home_hidden_object vim/after
link_home_hidden_object vim/colors
link_home_hidden_object vim/doc
link_home_hidden_object vim/snips
link_home_hidden_object vim/vimrc

link_home_hidden_object claude/settings.json
link_home_hidden_object jupyter/jupyter_notebook_config.py
link_home_hidden_object local/share/gh/extensions
link_home_hidden_object local/share/typst
link_home_hidden_object task/hooks

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
