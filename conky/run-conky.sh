#!/usr/bin/env bash

# Conky setup for laptop computers
if [ "$(hostname)" = ArchScythe ]; then
  conky -c ~/dotfiles/conky/summary-bar-1920x1080-onescreen.conf &
  conky -c ~/dotfiles/conky/cal2.conf &
fi
if [ "$(hostname)" = ArchSapphire ]; then
  conky -c ~/dotfiles/conky/summary-bar-1920x1080-onescreen.conf &
  conky -c ~/dotfiles/conky/cal2.conf &
fi

# Conky setup for ArchDiamond
if [ "$(hostname)" = ArchDiamond ]; then
  if [ "$(whoami)" = "evan" ]; then
    conky -c ~/dotfiles/conky/summary-bar-abridged-majestic.conf &
    conky -c ~/dotfiles/conky/stats-power-widget.conf &
    conky -c ~/dotfiles/conky/cal5.conf &
  fi
fi

# Conky setup for main work desktops
if [ "$(hostname)" = ArchMajestic ]; then
  if [ "$(whoami)" = "evan" ]; then
    conky -c ~/dotfiles/conky/summary-bar-abridged-majestic.conf &
    conky -c ~/dotfiles/conky/stats-power-widget.conf &
    conky -c ~/dotfiles/conky/cal3.conf &
  fi
  if [ "$(whoami)" = "star" ]; then
    conky -c ~/dotfiles/conky/star-bar-majestic.conf &
  fi
fi
if [ "$(hostname)" = ArchBootes ]; then
  if [ "$(whoami)" = "evan" ]; then
    conky -c ~/dotfiles/conky/summary-bar-1920x1080-bootes.conf &
    conky -c ~/dotfiles/conky/cal2.conf &
  fi
  if [ "$(whoami)" = "star" ]; then
    conky -c ~/dotfiles/conky/star-bar-bootes.conf &
  fi
fi
