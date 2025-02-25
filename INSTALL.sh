#!/bin/sh

# Use at your own risk ;)
# makes many symlinks

set -e
set -o xtrace

cd "$HOME"/dotfiles/py3status/ || exit 1
make

cd "$HOME" || exit 1

# symlink in home
if ! test -d "$HOME/.asy"; then ln -s "$HOME"/dotfiles/asy "$HOME"/.asy; fi
if ! test -d "$HOME/.texmf"; then ln -s "$HOME"/dotfiles/texmf "$HOME"/.texmf; fi
if ! test -d "$HOME/.vit"; then ln -s "$HOME"/dotfiles/vit "$HOME"/.vit; fi

if ! test -f "$HOME/.agignore"; then ln -s "$HOME"/dotfiles/agignore "$HOME"/.agignore; fi
if ! test -f "$HOME/.bashrc"; then ln -s "$HOME"/dotfiles/bashrc "$HOME"/.bashrc; fi
if ! test -f "$HOME/.chktexrc"; then ln -s "$HOME"/dotfiles/chktexrc "$HOME"/.chktexrc; fi
if ! test -f "$HOME/.eslintrc.yaml"; then ln -s "$HOME"/dotfiles/eslintrc.yaml "$HOME"/.eslintrc.yaml; fi
if ! test -f "$HOME/.gitconfig"; then ln -s "$HOME"/dotfiles/gitconfig "$HOME"/.gitconfig; fi
if ! test -f "$HOME/.gvimrc"; then ln -s "$HOME"/dotfiles/gvimrc "$HOME"/.gvimrc; fi
if ! test -f "$HOME/.latexmkrc"; then ln -s "$HOME"/dotfiles/latexmkrc "$HOME"/.latexmkrc; fi
if ! test -f "$HOME/.mbsyncrc"; then ln -s "$HOME"/dotfiles/mutt/mbsyncrc "$HOME"/.mbsyncrc; fi
if ! test -f "$HOME/.pdbrc.py"; then ln -s "$HOME"/dotfiles/pdbrc.py "$HOME"/.pdbrc.py; fi
if ! test -f "$HOME/.screenrc"; then ln -s "$HOME"/dotfiles/screenrc "$HOME"/.screenrc; fi
if ! test -f "$HOME/.shellcheckrc"; then ln -s "$HOME"/dotfiles/shellcheckrc "$HOME"/.shellcheckrc; fi
if ! test -f "$HOME/.taskrc"; then ln -s "$HOME"/dotfiles/taskrc "$HOME"/.taskrc; fi
if ! test -f "$HOME/.tidyrc"; then ln -s "$HOME"/dotfiles/tidyrc "$HOME"/.tidyrc; fi
if ! test -f "$HOME/.xprofile"; then ln -s "$HOME"/dotfiles/xprofile "$HOME"/.xprofile; fi

if ! test -f "$HOME/.xinitrc"; then
  echo "[ -f $HOME/.xprofile ] && . $HOME/.xprofile" >"$HOME"/.xinitrc
  echo "exec i3" >"$HOME"/.xinitrc
fi

# file/dir in .config
mkdir -p .config
if ! test -d "$HOME/.config/bat"; then ln -s "$HOME"/dotfiles/bat "$HOME"/.config/bat; fi
if ! test -d "$HOME/.config/bugwarrior"; then ln -s "$HOME"/dotfiles/bugwarrior "$HOME"/.config/bugwarrior; fi
if ! test -d "$HOME/.config/dijo"; then ln -s "$HOME"/dotfiles/dijo "$HOME"/.config/dijo; fi
if ! test -d "$HOME/.config/dunst"; then ln -s "$HOME"/dotfiles/dunst "$HOME"/.config/dunst; fi
if ! test -d "$HOME/.config/feh"; then ln -s "$HOME"/dotfiles/feh "$HOME"/.config/feh; fi
if ! test -d "$HOME/.config/fish"; then ln -s "$HOME"/dotfiles/fish "$HOME"/.config/fish; fi
if ! test -d "$HOME/.config/i3"; then ln -s "$HOME"/dotfiles/i3 "$HOME"/.config/i3; fi
if ! test -d "$HOME/.config/ncdu"; then ln -s "$HOME"/dotfiles/ncdu "$HOME"/.config/ncdu; fi
if ! test -d "$HOME/.config/mirage_linemode"; then ln -s "$HOME"/dotfiles/mirage_linemode "$HOME"/.config/mirage_linemode; fi
if ! test -d "$HOME/.config/mutt"; then ln -s "$HOME"/dotfiles/mutt "$HOME"/.config/mutt; fi
if ! test -d "$HOME/.config/nvim"; then ln -s "$HOME"/dotfiles/nvim "$HOME"/.config/nvim; fi
if ! test -d "$HOME/.config/qutebrowser"; then ln -s "$HOME"/dotfiles/qutebrowser "$HOME"/.config/qutebrowser; fi
if ! test -d "$HOME/.config/ranger"; then ln -s "$HOME"/dotfiles/ranger "$HOME"/.config/ranger; fi
if ! test -d "$HOME/.config/rofi"; then ln -s "$HOME"/dotfiles/rofi "$HOME"/.config/rofi; fi
if ! test -d "$HOME/.config/von"; then ln -s "$HOME"/dotfiles/von "$HOME"/.config/von; fi
if ! test -d "$HOME/.config/zathura"; then ln -s "$HOME"/dotfiles/zathura "$HOME"/.config/zathura; fi

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
if ! test -d "$HOME/.vim/after/ftplugin"; then
  ln -s "$HOME"/dotfiles/vim/after/ftplugin "$HOME"/.vim/after/ftplugin
fi
if ! test -d "$HOME/.vim/after/syntax"; then
  ln -s "$HOME"/dotfiles/vim/after/syntax "$HOME"/.vim/after/syntax
fi
if ! test -d "$HOME/.vim/colors"; then
  ln -s "$HOME"/dotfiles/vim/colors "$HOME"/.vim/colors
fi
if ! test -d "$HOME/.vim/doc"; then
  ln -s "$HOME"/dotfiles/vim/doc "$HOME"/.vim/doc
fi
if ! test -d "$HOME/.vim/snips"; then
  ln -s "$HOME"/dotfiles/vim/snips "$HOME"/.vim/snips
fi
# stopgap
if ! test -d "$HOME/.vim/spell"; then
  if test -d "$HOME"/dotfiles/vim/spell; then
    ln -s "$HOME"/dotfiles/vim/spell "$HOME"/.vim/spell
  fi
fi
if ! test -f "$HOME/.vim/coc-settings.json"; then
  ln -s "$HOME"/dotfiles/vim/coc-settings.json "$HOME"/.vim/coc-settings.json
fi
if ! test -f "$HOME/.vim/vimrc"; then
  ln -s "$HOME"/dotfiles/vim/vimrc "$HOME"/.vim/vimrc
fi
if ! test -f "$HOME/.vimrc"; then
  ln -s "$HOME"/dotfiles/vim/vimrc "$HOME"/.vimrc
fi

# systemd
mkdir -p "$HOME"/.config/systemd/user
for i in "$HOME"/dotfiles/custom-systemd-units/*; do
  if ! test -f "$HOME/.config/systemd/user/$(basename "$i")"; then
    ln -s "$i" "$HOME"/.config/systemd/user/
  fi
done

if [ "$USER" = "evan" ]; then
  xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop
  xdg-settings set default-url-scheme-handler https org.qutebrowser.qutebrowser.desktop
fi
