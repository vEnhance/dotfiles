#!/usr/bin/env bash

set -euo pipefail

readarray -t SPELL_FILES < <(git ls-files)
readarray -t PYTHON_FILES < <(git ls-files "**.py" | grep -v "qutebrowser/" | grep -v "ranger/")
readarray -t VIM_FILES < <(git ls-files "**.vim" vim/vimrc | grep -v "plug.vim")
readarray -t SHELL_FILES < <(git ls-files "**.sh")

# Spellcheck
echo "Running spellcheck on ${#SPELL_FILES[@]} files..."
codespell "${SPELL_FILES[@]}"

# Python
echo "Running ruff on ${#PYTHON_FILES[@]} files..."
ruff check "${PYTHON_FILES[@]}"
ruff format --diff "${PYTHON_FILES[@]}"

# Vim
echo "Running vint on ${#VIM_FILES[@]} files..."
vint -t "${VIM_FILES[@]}"

# Shell
echo "Running shfmt on ${#SHELL_FILES[@]} files..."
shfmt -i 2 -ci -d "${SHELL_FILES[@]}"
echo "Running shellcheck on ${#SHELL_FILES[@]} files..."
shellcheck --format=tty "${SHELL_FILES[@]}"
