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

is_cached() {
  # field 7 of a KEYINFO line is the cache flag ("1" cached, "-" not)
  gpg-connect-agent 'keyinfo --list' /bye | awk -v grip="$1" '$3 == grip {print $7}'
}

cap_label() {
  [[ $1 == s ]] && echo signing || echo encrypt
}

warm_entry() {
  local email=$1 cap=$2 fingerprint prefix
  fingerprint=$(get_fingerprint_for_cap "$email" "$cap")
  prefix=$([[ $cap == s ]] && echo gpgs || echo gpge)
  keychain --quiet add "$prefix:$fingerprint"
}

mapfile -t emails < <(get_emails)

entries=()
for email in "${emails[@]}"; do
  for cap in s e; do
    grip=$(get_grip_for_cap "$email" "$cap")
    [[ -n $grip ]] && entries+=("$email:$cap")
  done
done

if [[ "${1:-}" ]]; then
  entry="${entries[$(($1 - 1))]}"
  warm_entry "${entry%%:*}" "${entry##*:}"
  exit 0
fi

i=1
for entry in "${entries[@]}"; do
  email="${entry%%:*}"
  cap="${entry##*:}"
  grip=$(get_grip_for_cap "$email" "$cap")

  cached=$(is_cached "$grip")
  label="$email ($(cap_label "$cap"))"
  if [[ $cached == "1" ]]; then
    echo -e "[$i] $label: ${BOLD_GREEN}unlocked${RESET} (cached)"
  else
    echo -e "[$i] $label: ${BOLD_RED}locked${RESET}"
  fi
  ((i++))
done
