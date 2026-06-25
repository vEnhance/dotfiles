#!/usr/bin/env bash

# Supports desktop files, so handled by systemd or dex:
# * nm applet
# * flameshot
#
# dropbox no longer, started manually

# WS1="1: Aleph"
# WS2="2: Bet"
# WS3="3: Gimel"
# WS4="4: Dalet"
# WS5="5: Hei"
# WS6="6: Vav"
# WS7="7: Zayin"
# WS8="8: Het"
# WS9="9: Tet"
# WS0="10: Yod"

xss-lock -n ~/dotfiles/sh-scripts/lock-warning.sh -- ~/dotfiles/sh-scripts/fuzzy-lock.sh &

~/dotfiles/conky/run-conky.sh

if [ "$(hostname)" = ArchScythe ]; then
  ~/dotfiles/sh-scripts/redshift.sh
  dropbox-cli start
  systemctl --user start evansync.timer # idfk why systemctl enable doesn't work w/e
  syncthing-gtk -m &
  signal-desktop --start-in-tray --use-tray-icon &
  ibus-daemon -d -r &
fi

if [ "$(hostname)" = ArchMillie ]; then
  systemctl --user start evansync.timer
fi

if [ "$(hostname)" = ArchUmi ]; then
  systemctl --user start evansync.timer
  syncthing-gtk -m &
fi

if [ "$(hostname)" = ArchDiamond ]; then
  ~/dotfiles/sh-scripts/redshift.sh
  systemctl --user start evansync.timer
  systemctl --user start anki-morning.timer
  # dunst & # this has been causing problems apparently?
  if [ "$(whoami)" = "evan" ]; then
    ibus-daemon -d -r &
    signal-desktop --start-in-tray --use-tray-icon &
    syncthing-gtk &
  fi
  systemctl --user start evansync.timer
fi

if [ "$(hostname)" = ArchMajestic ]; then
  if [ "$(whoami)" = "evan" ]; then
    ibus-daemon -d -r &
    dropbox-cli start
    signal-desktop --start-in-tray --use-tray-icon &
    syncthing-gtk &
    spotify &
    # telegram-desktop &
  fi
  ~/dotfiles/sh-scripts/redshift.sh
  systemctl --user start evansync.timer
fi

if [ "$(hostname)" = ArchBootes ]; then
  if [ "$(whoami)" = "evan" ]; then
    ibus-daemon -d -r &
    # dropbox-cli start
    signal-desktop --start-in-tray --use-tray-icon &
    syncthing-gtk &
    spotify &
    # telegram-desktop &
  fi
  ~/dotfiles/sh-scripts/redshift.sh
  systemctl --user start evansync.timer
  xinput --set-prop 13 'libinput Accel Speed' -0.5
fi

if [ "$(hostname)" = dagobah ]; then
  syncthing-gtk -m &
fi
