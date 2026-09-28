#!/bin/bash
set -euo pipefail

src=
while getopts C: opt; do
  case $opt in
  C) src=$OPTARG ;;
  *)
    echo "usage: ${0##*/} [-C dir] [command [args...]]" >&2
    exit 2
    ;;
  esac
done
shift $((OPTIND - 1))
if [ $# -eq 0 ]; then
  set -- "${SHELL:-/bin/bash}"
fi

# $HOME/box is where this infrastructure lives
box=$HOME/box
dotfiles=$(realpath "$(dirname "$(realpath "$0")")/..")
mkdir -p "$box"
echo -e "📦 Entering \033[1;34m$box\033[;m via bubble-wrap!"

if [ -n "$src" ]; then
  src=$(realpath "$src")
  case "$HOME/" in
  "${src%/}"/*)
    echo -e "☠️ Refusing to box \033[1;34m$src\033[m: it contains \$HOME" >&2
    exit 1
    ;;
  esac
  project=(
    --bind "$src" "$src"
    --ro-bind-try "$src/.git/hooks" "$src/.git/hooks"
    --ro-bind-try "$src/.git/config" "$src/.git/config"
    --chdir "$src"
  )
  echo -e "🍻 Binding the project \033[1;34m$src\033[m into the box."
else
  project=(--chdir "$HOME")
fi
echo -e "💨 Executing \033[1;34m$*\033[;m...\n"

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
  --ro-bind "$dotfiles/misc/claude-settings.json" "$HOME/.claude/settings.json" \
  --ro-bind "$dotfiles/sh-scripts/claude-statusline.sh" "$HOME/.claude/statusline.sh" \
  --ro-bind-try "$HOME/.virtualenvs/" "$HOME/.virtualenvs/" \
  --ro-bind-try "$HOME/.local/share/uv/python/" "$HOME/.local/share/uv/python/" \
  --ro-bind-try "$HOME/.config/git/" "$HOME/.config/git/" \
  --unshare-all --share-net \
  --die-with-parent \
  --clearenv \
  --setenv HOME "$HOME" \
  --setenv BOX_ACTIVE 1 \
  --setenv PATH "$HOME/.local/bin:/usr/bin" \
  --setenv TERM "${TERM:-xterm-256color}" \
  --setenv LANG "${LANG:-C.UTF-8}" \
  --setenv COLORTERM "${COLORTERM:-}" \
  --setenv VIRTUAL_ENV "${VIRTUAL_ENV:-}" \
  --setenv UV_PROJECT_ENVIRONMENT "${UV_PROJECT_ENVIRONMENT:-}" \
  "$@"
