#!/bin/bash
# Symlink dotfiles from this repo into $HOME.

set -euo pipefail
# shellcheck source=installers/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cd "$HOME"

link_dot_path agignore
link_dot_path bashrc
link_dot_path chktexrc
link_dot_path eslintrc.yaml
link_dot_path gitconfig
link_dot_path gvimrc
link_dot_path latexmkrc
link_dot_path mbsyncrc
link_dot_path shellcheckrc
link_dot_path taskrc
link_dot_path xinitrc
link_dot_path xprofile

link_dot_path abook
link_dot_path jupyter/jupyter_notebook_config.py
link_dot_path vit

link_hidden_path config/bat
link_hidden_path config/biome
link_hidden_path config/borse
link_hidden_path config/dijo
link_hidden_path config/dunst
link_hidden_path config/feh
link_hidden_path config/flameshot
link_hidden_path config/fish
link_hidden_path config/ghostty
link_hidden_path config/git
link_hidden_path config/hyprwhspr
link_hidden_path config/i3
link_hidden_path config/miqin
link_hidden_path config/mpd
mkdir -p "$HOME"/.local/state/mpd/
link_hidden_path config/mutt
link_hidden_path config/ncdu
link_hidden_path config/nvim
link_hidden_path config/qutebrowser
link_hidden_path config/redshift
link_hidden_path config/rofi
link_hidden_path config/ruff
link_hidden_path config/rumdl
link_hidden_path config/spotify-player
link_hidden_path config/von
link_hidden_path config/zathura

link_hidden_path config/gh/config.yml
link_hidden_path config/gtk-3.0/settings.ini
link_hidden_path config/picom.conf
link_hidden_path config/vale/.vale.ini
link_hidden_path config/vale/vale-styles
link_hidden_path config/xfce4/terminal
link_hidden_path config/systemd/user/anki-morning.service
link_hidden_path config/systemd/user/anki-morning.timer
link_hidden_path config/systemd/user/evansync.service
link_hidden_path config/systemd/user/evansync.timer

link_dot_path asy
link_hidden_path texmf
link_dot_path task/hooks
link_hidden_path local/share/typst

mkdir -p "$HOME"/.vim/tmp/
link_hidden_path vim/after
link_hidden_path vim/ale_linters
link_hidden_path vim/autoload
link_hidden_path vim/colors
link_hidden_path vim/doc
link_hidden_path vim/snips
link_hidden_path vim/spell
link_hidden_path vim/vimrc
