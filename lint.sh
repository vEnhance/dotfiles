#!/bin/bash

set -e # crash on any errors

echo "Running pyflakes..."
pyflakes $(git ls-files "*.py" | grep -v "qutebrowser/" | grep -v "ranger/")
echo "Running yapf..."
yapf -d $(git ls-files "*.py" | grep -v "qutebrowser/" | grep -v "ranger/")
echo "Running spellcheck..."
codespell $(git ls-files)
