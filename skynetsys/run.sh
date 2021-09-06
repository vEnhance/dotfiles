#!/bin/bash

set -euxo pipefail
cd ~/dotfiles/skynetsys/
source ~/.virtualenvs/skynet/bin/activate

export FLASK_APP=skynet
flask run &
# gunicorn -w 1 -b 127.0.0.1:5000 skynet:app

lt --port 5000 -s $(cat subdomains/skynet)
