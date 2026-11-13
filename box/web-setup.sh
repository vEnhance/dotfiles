#!/bin/bash
# Run on the host, not in the box. Installs headless-browser assets into the
# box's home so boxed Claude can render pages without extra network access:
#   - Playwright's chromium-headless-shell (matching the system python-playwright)
#   - npm packages (default: bootstrap) into a local mirror served by boxweb.py
# Usage: web-setup.sh [npm-package[@version] ...]
# Rerun after pacman upgrades python-playwright.
set -euo pipefail

if [ -n "${BOX_ACTIVE:-}" ]; then
  echo "☠️ Run this outside the box." >&2
  exit 1
fi
if ! python3 -c 'import playwright' 2>/dev/null; then
  echo "☠️ Install python-playwright first: sudo pacman -S python-playwright" >&2
  exit 1
fi

box=$HOME/box
mirror=$box/.local/share/web-assets/npm
mkdir -p "$mirror"

echo "🎭 Installing chromium-headless-shell into the box..."
PLAYWRIGHT_BROWSERS_PATH=$box/.cache/ms-playwright \
  python3 -m playwright install chromium-headless-shell

if [ $# -eq 0 ]; then
  set -- bootstrap
fi
for spec in "$@"; do
  # Split "name@version"; a leading @ belongs to a scoped name
  name=${spec%@*}
  version=${spec##*@}
  if [ -z "$name" ] || [ "$spec" = "$version" ]; then
    name=$spec
    version=latest
  fi
  version=$(curl -fsSL "https://registry.npmjs.org/$name/$version" | jq -r .version)
  dest=$mirror/$name@$version
  if [ -d "$dest" ]; then
    echo -e "📦 \033[1;34m$name@$version\033[m already mirrored."
    continue
  fi
  echo -e "📦 Mirroring \033[1;34m$name@$version\033[m..."
  tmp=$(mktemp -d)
  curl -fsSL "https://registry.npmjs.org/$name/-/${name##*/}-$version.tgz" |
    tar -xz -C "$tmp"
  mkdir -p "$(dirname "$dest")"
  mv "$tmp/package" "$dest"
  rmdir "$tmp"
done
