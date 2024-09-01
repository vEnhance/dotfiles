#!/usr/bin/env bash
set -euxo pipefail

mbsync -q personal-inbox work-inbox records-inbox &
neomutt "$@"
mbsync -a &
