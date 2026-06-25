#!/usr/bin/env bash

# Supports desktop files, so handled by systemd or dex:
# * nm applet
# * flameshot
#
# dropbox does not have a desktop file anymore iirc

xss-lock -n ~/dotfiles/sh-scripts/lock-warning.sh -- ~/dotfiles/sh-scripts/fuzzy-lock.sh &
command -v conky && ~/dotfiles/conky/run-conky.sh

if [ "$(whoami)" = "evan" ]; then
  systemctl --user start evansync.timer # idfk why systemctl enable doesn't work w/e
  command -v dropbox-cli && dropbox-cli start
  command -v ibus-daemon && ibus-daemon -d -r &
  command -v redshift-gtk && ~/dotfiles/sh-scripts/redshift.sh
  command -v signal-desktop && signal-desktop --start-in-tray --use-tray-icon &
  command -v syncthing-gtk && syncthing-gtk -m &
fi

if [ "$(hostname)" = ArchBootes ]; then
  xinput --set-prop 13 'libinput Accel Speed' -0.5
fi
