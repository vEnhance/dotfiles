#!/usr/bin/env bash

find ~/Mail/*/All/ -type f |
  grep -E "[0-9]+\.R?[0-9]+_?[0-9]+\.Arch[a-zA-Z]+,U=[0-9]+:[0-9]+,R?S?T?" |
  xargs rm
