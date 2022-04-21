#!/bin/bash

mbsync -q personal-inbox work-inbox records-inbox &
neomutt $*
mbsync -q personal-inbox work-inbox records-inbox &
