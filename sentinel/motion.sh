#!/bin/bash

set -euxo pipefail
cd ~/dotfiles/sentinel/
motion -c motion.conf &
lt --port 8081 -s $(cat subdomains/camera)
