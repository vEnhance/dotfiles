#!/bin/bash

set -euxo pipefail
cd ~/dotfiles/skynetsys/
source ~/.virtualenvs/skynet/bin/activate

export FLASK_APP=sentinel
flask run &

lt --port 5000 -s $(cat subdomains/sentinel)
