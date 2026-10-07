#!/usr/bin/env bash
# Launch Anki with a per-host QT_SCALE_FACTOR.
set -euo pipefail

export LANG="ko_KR.UTF-8"
export LC_ALL="ko_KR.UTF-8"
case "$(hostname)" in
ArchDiamond | ArchBootes | ArchMajestic) export QT_SCALE_FACTOR=3 ;;
ArchScythe | ArchUmi) export QT_SCALE_FACTOR=2 ;;
esac

exec anki "$@"
