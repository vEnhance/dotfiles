#!/bin/bash
set -euo pipefail

src=.
while getopts C:n opt; do
  case $opt in
  C) src=$OPTARG ;;
  n) src= ;;
  *) exit 2 ;;
  esac
done
shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
  echo "usage: ${0##*/} [-C dir | -n] command [args...]" >&2
  exit 2
fi

if [ -n "$src" ]; then
  src=$(realpath "$src")
  case "$HOME/" in
  "${src%/}"/*)
    echo "refusing to box $src: it contains \$HOME" >&2
    exit 1
    ;;
  esac
  project=(
    --bind "$src" "$src"
    --ro-bind-try "$src/.git/hooks" "$src/.git/hooks"
    --ro-bind-try "$src/.git/config" "$src/.git/config"
    --chdir "$src"
  )
else
  project=(--chdir "$HOME")
fi

box=$HOME/box
mkdir -p "$box"

exec bwrap \
  --ro-bind /usr /usr \
  --symlink usr/bin /bin \
  --symlink usr/sbin /sbin \
  --symlink usr/lib /lib \
  --symlink usr/lib64 /lib64 \
  --ro-bind /etc /etc \
  --ro-bind /opt /opt \
  --ro-bind-try /run/systemd/resolve /run/systemd/resolve \
  --proc /proc \
  --dev /dev \
  --tmpfs /tmp \
  --bind "$box" "$HOME" \
  "${project[@]}" \
  --ro-bind-try "$HOME/dotfiles/misc/claude-settings.json" "$HOME/.claude/settings.json" \
  --ro-bind-try "$HOME/.virtualenvs" "$HOME/.virtualenvs" \
  --ro-bind-try "$HOME/.local/share/uv/python/" "$HOME/.local/share/uv/python/" \
  --unshare-all --share-net \
  --die-with-parent \
  --clearenv \
  --setenv HOME "$HOME" \
  --setenv PATH "$HOME/.local/bin:/usr/bin" \
  --setenv TERM "${TERM:-xterm-256color}" \
  --setenv LANG "${LANG:-C.UTF-8}" \
  --setenv COLORTERM "${COLORTERM:-}" \
  --setenv VIRTUAL_ENV "${VIRTUAL_ENV:-}" \
  --setenv UV_PROJECT_ENVIRONMENT "${UV_PROJECT_ENVIRONMENT:-}" \
  "$@"
