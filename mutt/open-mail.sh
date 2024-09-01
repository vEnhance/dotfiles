#!/usr/bin/env bash

mbsync personal-inbox work-inbox records-inbox &
neomutt "$@"
mbsync personal-inbox work-inbox records-inbox &
