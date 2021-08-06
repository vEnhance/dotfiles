#!/bin/sh

# virtualenv
if [ -n "$VIRTUAL_ENV" ]; then
	git ls-files
	mkdir -p .git/gutentags/
	ln -sf $VIRTUAL_ENV .git/gutentags/virtual
	find .git/gutentags/virtual/ -name \*.py
	ln -sf /usr/lib/python3.9/ .git/gutentags/system
	ls .git/gutentags/system/*.py
fi
