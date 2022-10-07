#!/bin/bash

set -e # crash on any errors

read -ra SPELL_FILES < <(git ls-files)
read -ra PYTHON_FILES < <(git ls-files "*.py" | grep -v "qutebrowser/" | grep -v "ranger/")
read -ra SHELL_FILES < <(git ls-files "*.sh")

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
