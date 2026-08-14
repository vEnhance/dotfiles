#!/usr/bin/env bash
set -euo pipefail

/usr/bin/python3 ~/dotfiles/py-scripts/export-ggb-clean-asy.py --speedy
~/dotfiles/sh-scripts/getclip.sh
