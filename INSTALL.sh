#!/bin/sh

# Use at your own risk ;)
# makes many symlinks

set -e
set -o xtrace

# Helper functions for creating symlinks
# Symlink a directory from dotfiles to $HOME (with dot prefix)
link_home_dir() {
  if ! test -d "$HOME/.$1"; then
    ln -s "$HOME/dotfiles/$1" "$HOME/.$1"
  fi
}

# Symlink a file from dotfiles to $HOME (with dot prefix)
link_home_file() {
  if ! test -f "$HOME/.$1"; then
    ln -s "$HOME/dotfiles/$1" "$HOME/.$1"
  fi
}

# Symlink a directory from dotfiles to ~/.config
link_config_dir() {
  if ! test -d "$HOME/.config/$1"; then
    ln -s "$HOME/dotfiles/$1" "$HOME/.config/$1"
  fi
}

# Symlink a vim subdirectory
link_vim_dir() {
  if ! test -d "$HOME/.vim/$1"; then
    ln -s "$HOME/dotfiles/vim/$1" "$HOME/.vim/$1"
  fi
}

cd "$HOME"/dotfiles/py3status/ || exit 1
make

cd "$HOME" || exit 1

link_home_dir asy
link_home_dir texmf
link_home_dir vit

link_home_file agignore
link_home_file bashrc
link_home_file chktexrc
link_home_file eslintrc.yaml
link_home_file gitconfig
link_home_file gvimrc
link_home_file latexmkrc
link_home_file mbsyncrc
link_home_file screenrc
link_home_file shellcheckrc
link_home_file taskrc
link_home_file tidyrc
link_home_file xinitrc
link_home_file xprofile

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
link_config_dir rofi
link_config_dir von
link_config_dir zathur

# .claude directory and settings
mkdir -p "$HOME"/.claude
if ! test -f "$HOME/.claude/settings.json"; then
  ln -s "$HOME"/dotfiles/claude-settings.json "$HOME"/.claude/settings.json
fi

# nested config
if ! test -f "$HOME/.config/picom.conf"; then
  ln -s "$HOME"/dotfiles/picom.conf "$HOME"/.config/picom.conf
fi
if ! test -d "$HOME/.config/py3status"; then
  mkdir -p "$HOME"/.config/py3status
  ln -s "$HOME/dotfiles/py3status/py3status.$(hostname).conf" "$HOME"/.config/py3status/config
fi
if ! test -f "$HOME/.config/gtk-3.0/settings.ini"; then
  mkdir -p "$HOME"/.config/gtk-3.0
  ln -s "$HOME"/dotfiles/gtk3-settings.ini "$HOME"/.config/gtk-3.0/settings.ini
fi
if ! test -d "$HOME/.config/xfce4/terminal"; then
  mkdir -p "$HOME"/.config/xfce4/
  ln -s "$HOME"/dotfiles/terminal "$HOME"/.config/xfce4/terminal
fi
if ! test -f "$HOME/.config/gh/config.yml"; then
  mkdir -p "$HOME"/.config/gh
  ln -s "$HOME"/dotfiles/gh-config.yml "$HOME"/.config/gh/config.yml
fi
if ! test -f "$HOME/.config/redshift/redshift.conf"; then
  mkdir -p "$HOME"/.config/redshift/
  ln -s "$HOME"/dotfiles/redshift.conf "$HOME"/.config/redshift/redshift.conf
fi
if ! test -d "$HOME/.config/ruff"; then
  mkdir -p "$HOME"/.config/ruff
  ln -s "$HOME/dotfiles/ruff.toml" "$HOME"/.config/ruff/ruff.toml
fi
if ! test -d "$HOME/.config/nerd-dictation"; then
  mkdir -p "$HOME"/.config/nerd-dictation
  ln -s "$HOME"/dotfiles/nerd-dictation.py "$HOME"/.config/nerd-dictation
fi
if test -d "$HOME/.jupyter" && ! test -f "$HOME/.jupyter/jupyter_notebook_config.py"; then
  ln -s "$HOME"/dotfiles/jupyter_notebook_config.py "$HOME"/.jupyter/
fi
if ! test -d "$HOME/.config/vale/"; then
  mkdir -p "$HOME"/.config/vale/
  ln -s "$HOME"/dotfiles/vale.ini "$HOME"/.config/vale/.vale.ini
  ln -s "$HOME"/dotfiles/vale-styles "$HOME"/.config/vale/vale-styles
fi

# .local
if ! test -d "$HOME/.local/share/gh/extensions"; then
  mkdir -p "$HOME"/.local/share/gh
  ln -s "$HOME"/dotfiles/gh-extensions "$HOME"/.local/share/gh/extensions
fi
if ! test -d "$HOME/.local/share/typst"; then
  mkdir -p "$HOME"/.local/share/
  ln -s "$HOME"/dotfiles/typst "$HOME"/.local/share/typst
fi

# taskwarrior hooks
mkdir -p .task/hooks
if [ -z "$(ls -A "$HOME/.task/hooks")" ]; then
  rmdir "$HOME/.task/hooks"
fi
if ! test -d "$HOME/.task/hooks"; then
  ln -s "$HOME"/dotfiles/tw-hooks "$HOME"/.task/hooks
fi

# vim
mkdir -p "$HOME"/.vim/tmp/
mkdir -p "$HOME"/.vim/after/
mkdir -p "$HOME"/.vim/tags/
link_vim_dir after/ftplugin
link_vim_dir after/syntax
link_vim_dir colors
link_vim_dir doc
link_vim_dir snips
# stopgap
if ! test -d "$HOME/.vim/spell"; then
  if test -d "$HOME"/dotfiles/vim/spell; then
    ln -s "$HOME"/dotfiles/vim/spell "$HOME"/.vim/spell
  fi
fi
if ! test -f "$HOME/.vim/vimrc"; then
  ln -s "$HOME"/dotfiles/vim/vimrc "$HOME"/.vim/vimrc
fi
if ! test -f "$HOME/.vimrc"; then
  ln -s "$HOME"/dotfiles/vim/vimrc "$HOME"/.vimrc
fi

if [ "$USER" = "evan" ]; then
  xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop
  xdg-settings set default-url-scheme-handler https org.qutebrowser.qutebrowser.desktop
  # xfconf-query -c xfce4-session -p /general/LockCommand -s "loginctl lock-session"
fi
