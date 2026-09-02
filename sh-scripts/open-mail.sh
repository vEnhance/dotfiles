#!/usr/bin/env bash

set -euxo pipefail

pass show hello

mbsync -q personal-inbox work-inbox records-inbox &
neomutt "$@"
mbsync -a &
