#!/bin/bash

if [ "$(hostname)" = ArchScythe ]; then
  conky -c ~/dotfiles/conky/thin-bar-1920x1080.conf &
  conky -c ~/dotfiles/conky/cal2.conf &
fi
if [ "$(hostname)" = ArchSapphire ]; then
  conky -c ~/dotfiles/conky/thin-bar-1920x1080.conf &
  conky -c ~/dotfiles/conky/cal2.conf &
fi
if [ "$(hostname)" = ArchDiamond ]; then
  if [ "$(whoami)" = "evan" ]; then
    if [ "$(date +'%Z')" = "EDT" ] || [ "$(date +'%Z')" = "EST" ]; then
      conky -c ~/dotfiles/conky/thin-bar-3840x2160.conf &
      conky -c ~/dotfiles/conky/cal5.conf &
    else
      conky -c ~/dotfiles/conky/thin-bar-1920x1080.conf &
      conky -c ~/dotfiles/conky/cal3.conf &
    fi
  fi
fi
if [ "$(hostname)" = ArchMajestic ]; then
  if [ "$(whoami)" = "evan" ]; then
    conky -c ~/dotfiles/conky/shifted-bar.conf &
    conky -c ~/dotfiles/conky/cal3.conf &
  fi
  if [ "$(whoami)" = "star" ]; then
    conky -c ~/dotfiles/conky/star-bar.conf &
  fi
fi
if [ "$(hostname)" = dagobah ]; then
  conky -c ~/dotfiles/conky/thin-bar-1920x1080.conf &
  conky -c ~/dotfiles/conky/cal3.conf &
fi
