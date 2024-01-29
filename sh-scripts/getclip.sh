#!/bin/bash

set -euxo pipefail
contents="$(xsel --clipboard)"

if [[ $contents == "qute://pdfjs/web/viewer.html?filename="* ]]; then
  contents=$(echo "$contents" |
    grep -Eo "source=.*" |
    cut -d "=" -f 2- |
    python -c "import urllib.parse, sys; print(urllib.parse.unquote(sys.stdin.readline()))")
fi
echo "$contents" | xsel --clipboard

notify-send -u low -i "edit-paste-symbolic" "xsel --clipboard" "${contents:0:160}"
