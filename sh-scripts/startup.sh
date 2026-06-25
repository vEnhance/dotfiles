#!/usr/bin/env bash

# Supports desktop files, so handled by systemd or dex:
# * nm applet
# * flameshot
#
# dropbox does not have a desktop file anymore iirc

xss-lock -n ~/dotfiles/sh-scripts/lock-warning.sh -- ~/dotfiles/sh-scripts/fuzzy-lock.sh &

# Always run
if command -v conky; then ~/dotfiles/conky/run-conky.sh; fi

if [ "$(whoami)" = "evan" ]; then
  systemctl --user start evansync.timer # idfk why systemctl enable doesn't work w/e
  if command -v dropbox-cli; then dropbox-cli start; fi
  if command -v ibus-daemon; then ibus-daemon -d -r & fi
  if command -v redshift-gtk; then ~/dotfiles/sh-scripts/redshift.sh; fi
  if command -v signal-desktop; then signal-desktop --start-in-tray --use-tray-icon & fi
  if command -v syncthing-gtk; then syncthing-gtk -m & fi
fi

if [ "$(hostname)" = ArchBootes ]; then
  xinput --set-prop 13 'libinput Accel Speed' -0.5
fi
