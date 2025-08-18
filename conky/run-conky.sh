#!/usr/bin/env bash

# Conky setup for laptop computers
if [ "$(hostname)" = ArchScythe ]; then
  conky -d -c ~/dotfiles/conky/summary-bar.conf
  conky -d -c ~/dotfiles/conky/cal.conf
fi
if [ "$(hostname)" = ArchSapphire ]; then
  conky -d -c ~/dotfiles/conky/summary-bar.conf
  conky -d -c ~/dotfiles/conky/cal.conf
fi

# Conky setup for ArchDiamond
if [ "$(hostname)" = ArchDiamond ]; then
  if [ "$(whoami)" = "evan" ]; then
    conky -d -c ~/dotfiles/conky/summary-bar.conf --xinerama-head=0
    conky -d -c ~/dotfiles/conky/stats-power-widget.conf --xinerama-head=3
    conky -d -c ~/dotfiles/conky/cal.conf
  fi
fi

# Conky setup for main work desktops
if [ "$(hostname)" = ArchMajestic ]; then
  if [ "$(whoami)" = "evan" ]; then
    conky -d -c ~/dotfiles/conky/summary-bar.conf --xinerama-head=3
    conky -d -c ~/dotfiles/conky/stats-power-widget.conf --xinerama-head=0
    conky -d -c ~/dotfiles/conky/cal.conf
  fi
  if [ "$(whoami)" = "star" ]; then
    conky -d -c ~/dotfiles/conky/star-bar.conf --xinerama-head=3
  fi
fi
if [ "$(hostname)" = ArchBootes ]; then
  if [ "$(whoami)" = "evan" ]; then
    conky -d -c ~/dotfiles/conky/summary-bar.conf --xinerama-head=3
    conky -d -c ~/dotfiles/conky/stats-power-widget.conf --xinerama-head=0
    conky -d -c ~/dotfiles/conky/cal.conf
  fi
  if [ "$(whoami)" = "star" ]; then
    conky -d -c ~/dotfiles/conky/star-bar.conf --xinerama-head=0
  fi
fi
