#!/bin/bash

set -e # crash on any errors

readarray -t SPELL_FILES < <(git ls-files)
readarray -t PYTHON_FILES < <(git ls-files "**.py" | grep -v "qutebrowser/" | grep -v "ranger/")
readarray -t SHELL_FILES < <(git ls-files "**.sh")

# Spellcheck
echo "Running spellcheck on ${#SPELL_FILES[@]} files..."
codespell "${SPELL_FILES[@]}"

# Python
echo "Running pyflakes on ${#PYTHON_FILES[@]} files..."
pyflakes "${PYTHON_FILES[@]}"
echo "Running yapf on ${#PYTHON_FILES[@]} files..."
yapf -d "${PYTHON_FILES[@]}"

# Shell
echo "Running shfmt on ${#SHELL_FILES[@]} files..."
shfmt -d "${SHELL_FILES[@]}"
echo "Running shellcheck on ${#SHELL_FILES[@]} files..."
shellcheck --format=tty "${SHELL_FILES[@]}"
