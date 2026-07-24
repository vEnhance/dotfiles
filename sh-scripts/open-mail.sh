#!/usr/bin/env bash

if [[ -n ${VIRTUAL_ENV:-} ]]; then
  echo "Refusing to run inside a Python virtual environment" >&2
  echo "(VIRTUAL_ENV=$VIRTUAL_ENV)" >&2
  exit 1
fi

set -euxo pipefail

mbsync -q personal-inbox work-inbox records-inbox &
neomutt "$@"
mbsync -a &
