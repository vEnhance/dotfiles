#!/bin/bash

set -euxo pipefail

# systemd
mkdir -p "$HOME"/.config/systemd/user
for i in "$HOME"/dotfiles/custom-systemd-units/*; do
  if ! test -f "$HOME/.config/systemd/user/$(basename "$i")"; then
    ln -s "$i" "$HOME"/.config/systemd/user/
  fi
done
