#!/usr/bin/env bash
set -euo pipefail

BOLD_GREEN='\033[1;32m'
BOLD_RED='\033[1;31m'
RESET='\033[0m'

get_emails() {
  gpg --list-secret-keys --with-colons |
    awk -F: '$1 == "uid" {print $10}' |
    grep -oP '(?<=<)[^>]+(?=>)' |
    sort -u
}

get_grip_for_cap() {
  local email=$1 cap=$2
  gpg --list-secret-keys --with-colons --with-keygrip "$email" | awk -F: -v cap="$cap" '
        ($1 == "sec" || $1 == "ssb") { capline = $12; next }
        $1 == "grp" && index(capline, cap) { print $10; exit }
    '
}

get_fingerprint_for_cap() {
  local email=$1 cap=$2
  gpg --list-secret-keys --with-colons "$email" | awk -F: -v cap="$cap" '
        ($1 == "sec" || $1 == "ssb") { capline = $12; next }
        $1 == "fpr" && index(capline, cap) { print $10; exit }' # codespell:ignore fpr
}

get_keygrip() {
  local grip
  grip=$(get_grip_for_cap "$1" s)
  [[ -n $grip ]] && {
    echo "$grip"
    return
  }
  get_grip_for_cap "$1" e
}

is_cached() {
  # field 7 of a KEYINFO line is the cache flag ("1" cached, "-" not)
  gpg-connect-agent 'keyinfo --list' /bye | awk -v grip="$1" '$3 == grip {print $7}'
}

warm_key() {
  local email=$1 fingerprint

  fingerprint=$(get_fingerprint_for_cap "$email" s)
  if [[ -n $fingerprint ]]; then
    keychain --quiet add "gpgs:$fingerprint"
    return
  fi

  fingerprint=$(get_fingerprint_for_cap "$email" e)
  if [[ -n $fingerprint ]]; then
    keychain --quiet add "gpge:$fingerprint"
    return
  fi

  echo "$email: no signing or encryption subkey found" >&2
  return 1
}

resolve_email() {
  local sel=$1
  if [[ $sel =~ ^[0-9]+$ ]]; then
    echo "${emails[$((sel - 1))]}"
  else
    echo "$sel"
  fi
}

mapfile -t emails < <(get_emails)

if [[ "${1:-}" ]]; then
  warm_key "$(resolve_email "$1")"
  exit 0
fi

i=1
for email in "${emails[@]}"; do
  grip=$(get_keygrip "$email")
  if [[ -z $grip ]]; then
    echo "[$i] $email: no key found"
    ((i++))
    continue
  fi

  cached=$(is_cached "$grip")
  if [[ $cached == "1" ]]; then
    echo -e "[$i] $email: ${BOLD_GREEN}unlocked${RESET} (cached)"
  else
    echo -e "[$i] $email: ${BOLD_RED}locked${RESET}"
  fi
  ((i++))
done
