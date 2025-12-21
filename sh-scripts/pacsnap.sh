#!/usr/bin/env bash
set -euxo pipefail

pacman -Qqtten >~/Sync/pacman/"$(hostname)".pacman.paclist
pacman -Qqttem >~/Sync/pacman/"$(hostname)".aur.paclist
paclist chaotic-aur | cut -d " " -f 1 | sort | comm -23 - ~/Sync/pacman/excluded.txt >~/Sync/pacman/"$(hostname)".vote.paclist
pacman -Qqem | sort | comm -23 - ~/Sync/pacman/excluded.txt >>~/Sync/pacman/"$(hostname)".vote.paclist
if [ "$(hostname)" = "$(cat ~/dotfiles/host-config/pacman)" ] && [ "$(whoami)" = "evan" ]; then
  cd ~/Sync/pacman/ || exit 1
  if ! git diff --exit-code; then
    git commit -a -m "$(date), snapshot taken on $(hostname)"
  fi
fi
