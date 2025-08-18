#!/usr/bin/env bash
set -euo pipefail

TODAY=$(date +%e)
cal | sed '1d' | sed 's/^/ /g' | sed 's/$/ /g' | sed "/ $TODAY /s/ $TODAY /\${font3}\${color ffffff} $TODAY \${font2}\${color bbbbbb}/"
