#!/bin/sh

git ls-files

mkdir -p .git/gutentags/

if [ -n $VIRTUAL_ENV ]; then
	ln -sf $VIRTUAL_ENV .git/gutentags/virtual
	find .git/gutentags/virtual/ -name \*.py
	ln -sf /usr/lib/python3.9/ .git/gutentags/system
	ls .git/gutentags/system/*.py
fi
