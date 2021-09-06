#!/bin/bash

set -euxo pipefail
cd ~/dotfiles/skynetsys/
motion -c motion.conf &
lt --port 8081 -s $(cat subdomains/camera)
