#!/usr/bin/env bash
set -euo pipefail

python ~/dotfiles/py-scripts/export-ggb-clean-asy.py --speedy
~/dotfiles/sh-scripts/getclip.sh
