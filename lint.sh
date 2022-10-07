#!/bin/bash

set -e # crash on any errors

readarray -t SPELL_FILES < <(git ls-files)
readarray -t PYTHON_FILES < <(git ls-files "**.py" | grep -v "qutebrowser/" | grep -v "ranger/")
readarray -t SHELL_FILES < <(git ls-files "**.sh")

# Spellcheck
echo "Running spellcheck..."
codespell "${SPELL_FILES[@]}"

# Python
echo "Running pyflakes..."
pyflakes "${PYTHON_FILES[@]}"
echo "Running yapf..."
yapf -d "${PYTHON_FILES[@]}"

# Shell
echo "Running shfmt..."
shfmt -d "${SHELL_FILES[@]}"
echo "Running shellcheck..."
git ls-files "*.sh"
shellcheck --format=tty "${SHELL_FILES[@]}"
