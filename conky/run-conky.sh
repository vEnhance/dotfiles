#!/bin/bash

# Conky setup for laptop computers
if [ "$(hostname)" = ArchScythe ]; then
  conky -c ~/dotfiles/conky/thin-bar-1920x1080.conf &
  conky -c ~/dotfiles/conky/cal2.conf &
fi
if [ "$(hostname)" = ArchSapphire ]; then
  conky -c ~/dotfiles/conky/thin-bar-1920x1080.conf &
  conky -c ~/dotfiles/conky/cal2.conf &
fi

# Conky setup for TV screen
if [ "$(hostname)" = ArchDiamond ]; then
  if [ "$(whoami)" = "evan" ]; then
    conky -c ~/dotfiles/conky/thin-bar-3840x2160.conf &
    conky -c ~/dotfiles/conky/cal5.conf &
  fi
fi

# Conky setup for main work desktops
if [ "$(hostname)" = ArchMajestic ]; then
  if [ "$(whoami)" = "evan" ]; then
    conky -c ~/dotfiles/conky/shifted-bar.conf &
    conky -c ~/dotfiles/conky/cal3.conf &
  fi
  if [ "$(whoami)" = "star" ]; then
    conky -c ~/dotfiles/conky/star-bar.conf &
  fi
fi
if [ "$(hostname)" = ArchBootes ]; then
  if [ "$(whoami)" = "evan" ]; then
    conky -c ~/dotfiles/conky/bootes-bar.conf &
    conky -c ~/dotfiles/conky/cal3.conf &
  fi
  if [ "$(whoami)" = "star" ]; then
    conky -c ~/dotfiles/conky/star-bar.conf &
  fi
fi
