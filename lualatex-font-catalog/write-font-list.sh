#!/bin/bash

# with thanks to https://github.com/jgm/pandoc/wiki/Trials-and-Tribulations:-How-to-find-correct-font-names-for-Pandoc's-use-with-LuaLaTeX%3F
# -----------------------------------------

# Get the directory of this script
# https://stackoverflow.com/q/59895/4826845
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# you might have to change this idk
CACHE_DIR="$HOME"/.texlive/texmf-var/luatex-cache/generic/names

# unzip the thingymajiggy
GZIP_TARGET="$CACHE_DIR"/luaotfload-names.luc.gz
TARGET=$CACHE_DIR/luatfload-names.luc
if test -f "$GZIP_TARGET"; then
  gunzip -c >"$TARGET"
fi

./list-luatex-fonts | sort | uniq >"$DIR"/fontlist
