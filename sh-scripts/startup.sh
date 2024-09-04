#!/usr/bin/env bash

# Supports desktop files, so handled by systemd or dex:
# * xfce power manager
# * nm applet
# * copyq
# * flameshot
# * syncthing-gtk? unclear
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

if [ "$(hostname)" = ArchAir ]; then
  dunst &
  synclient RightButtonAreaRight=1
  synclient VertScrollDelta=-237
  systemctl start --user evil-chin.service
  systemctl start --user mosp-2021.service
  # systemctl start --user sentinel.service
fi

if [ "$(hostname)" = ArchAngel ]; then
  picom -b --no-fading-openclose
  ~/dotfiles/sh-scripts/redshift.sh
  dropbox-cli start
fi

if [ "$(hostname)" = ArchScythe ]; then
  picom -b --no-fading-openclose
  ~/dotfiles/sh-scripts/redshift.sh
  dropbox-cli start
  systemctl --user start evansync.timer # idfk why systemctl enable doesn't work w/e
  dunst &
  syncthing-gtk -m &
  signal-desktop --start-in-tray --use-tray-icon &
  ibus-daemon -d -r &
fi

if [ "$(hostname)" = ArchSapphire ]; then
  picom -b --no-fading-openclose
  dunst &
  syncthing-gtk -m &
  signal-desktop --start-in-tray --use-tray-icon &
  ibus-daemon -d -r &
  telegram-desktop &
fi

if [ "$(hostname)" = ArchDiamond ]; then
  picom -b --no-fading-openclose
  ~/dotfiles/sh-scripts/redshift.sh
  systemctl --user start evansync.timer
  # dunst & # this has been causing problems apparently?
  syncthing-gtk -m &
  if [ "$(whoami)" = "evan" ]; then
    ibus-daemon -d -r &
  fi
fi

if [ "$(hostname)" = ArchMajestic ]; then
  picom -b --no-fading-openclose
  if [ "$(whoami)" = "evan" ]; then
    ibus-daemon -d -r &
    dropbox-cli start
    signal-desktop --start-in-tray --use-tray-icon &
    # gnome-calendar &
    syncthing-gtk &
    spotify &
    telegram-desktop &
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
    telegram-desktop &
  fi
  ~/dotfiles/sh-scripts/redshift.sh
  systemctl --user start evansync.timer
  picom -G -b --no-fading-openclose --backend xrender
  xinput --set-prop 13 'libinput Accel Speed' -0.5
  # pavucontrol &
fi

if [ "$(hostname)" = dagobah ]; then
  picom -b --no-fading-openclose
  syncthing-gtk -m &
fi
