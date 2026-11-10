#!/bin/bash
# Report Arch packages from installers/packages.txt that aren't installed,
# or that are installed only as a dependency (so -Rns of orphans could eat them).
# Never installs anything; it prints the commands for you to run.
# Packages whose comment says (AUR) or (chaotic-aur) are reported as such;
# everything else is expected to be in the official repos.

set -euo pipefail
# shellcheck source=installers/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

LIST="$DOTFILES/installers/packages.txt"

if ! command -v pacman >/dev/null; then
  warn "pacman not found, not checking packages"
  exit 0
fi

required=()
optional=()
declare -A source # package -> official, aur or chaotic-aur
while read -r line; do
  pkg=${line%%#*}
  pkg=${pkg//[[:space:]]/}
  [ -n "$pkg" ] || continue
  case "$line" in
  *"(AUR)"*) src=aur ;;
  *"(chaotic-aur)"*) src="chaotic-aur" ;;
  *) src=official ;;
  esac
  case "$pkg" in
  *\?) pkg=${pkg%\?} optional+=("$pkg") ;;
  *) required+=("$pkg") ;;
  esac
  source[$pkg]=$src
done <"$LIST"

# pacman -T prints whichever names aren't satisfied by an installed package
# (provides count, e.g. shellcheck-bin satisfies shellcheck).
unsatisfied() {
  [ $# -eq 0 ] || pacman -T "$@" || true
}

mapfile -t missing < <(unsatisfied "${required[@]}")
mapfile -t missing_opt < <(unsatisfied "${optional[@]}")
mapfile -t deps_only < <(
  comm -12 <(printf '%s\n' "${required[@]}" | sort -u) <(pacman -Qqd | sort -u)
)

official=()
chaotic=()
aur=()
unknown=()
for pkg in "${missing[@]}"; do
  case "${source[$pkg]}" in
  aur) aur+=("$pkg") ;;
  chaotic-aur) chaotic+=("$pkg") ;;
  *)
    # pacman -Sp also resolves provides, e.g. pandoc -> pandoc-cli
    if pacman -Si "$pkg" &>/dev/null || pacman -Sp "$pkg" &>/dev/null; then
      official+=("$pkg")
    else
      unknown+=("$pkg")
    fi
    ;;
  esac
done

if [ ${#missing[@]} -eq 0 ]; then
  echo -e "${BOLD_GRN}OK:${RESET} all ${#required[@]} required packages are installed"
else
  echo -e "${BOLD_RED}MISSING:${RESET} ${#missing[@]} of ${#required[@]} required packages"
  if [ ${#official[@]} -gt 0 ]; then
    echo "  sudo pacman -S --needed ${official[*]}"
  fi
  if [ ${#chaotic[@]} -gt 0 ]; then
    if pacman-conf --repo-list | grep -qxF chaotic-aur; then
      echo "  sudo pacman -S --needed ${chaotic[*]}  # chaotic-aur"
    else
      echo "  (chaotic-aur, which isn't set up here; or build from the AUR) ${chaotic[*]}"
    fi
  fi
  if [ ${#aur[@]} -gt 0 ]; then
    echo "  (AUR) ${aur[*]}"
  fi
  if [ ${#unknown[@]} -gt 0 ]; then
    echo "  (not in any sync repo; mark them (AUR) in packages.txt?) ${unknown[*]}"
  fi
fi

if [ ${#deps_only[@]} -gt 0 ]; then
  echo -e "${BOLD_YLW}DEPENDENCY ONLY:${RESET} installed, but not explicitly"
  echo "  sudo pacman -D --asexplicit ${deps_only[*]}"
fi

if [ ${#missing_opt[@]} -gt 0 ]; then
  echo ""
  echo -e "OPTIONAL: not installed: ${missing_opt[*]}"
fi
