#!/usr/bin/env bash
set -euo pipefail

LANG=ko_KR.UTF-8
TODAY=$(date +%e)
cal | sed '1d' | sed 's/^/ /g' | sed 's/$/ /g' | sed "/ $TODAY /s/ $TODAY /\${font5}\${color ffffff} $TODAY \${font4}\${color bbbbbb}/"
