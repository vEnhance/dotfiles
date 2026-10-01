#!/usr/bin/env bash
set -euo pipefail

LANG=ko_KR.UTF-8
TODAY=$(date +%e)
cal | sed '1d' | sed 's/^/ /g' | sed 's/$/ /g' | sed "/ $TODAY /s/ $TODAY /\${font4}\${color ffffff} $TODAY \${font3}\${color bbbbbb}/"
