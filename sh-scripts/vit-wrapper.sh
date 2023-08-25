#!/bin/bash

set -euxo pipefail

#task sync
vit
#task sync
killall -s USR1 py3status
