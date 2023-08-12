#!/bin/bash

echo "+=========================================+"
if [ "$1" = "cards" ]; then
  echo -e "| Welcome to the \033[1;32mBITWARDEN Cards grabber\033[m! |"
else
  echo -e "| Welcome to the \033[1;36mBITWARDEN Vault grabber\033[m! |"
fi
echo -e "| (yet another hack written by \033[1;33mEvan Chen\033[m) |"
echo "+=========================================+"

if test -z "$BW_SESSION"; then
  while true; do
    echo -e "\033[1;35mEnter the PIN to continue.\033[m"
    read -r -s -p "[echo hidden]: " USER_PIN
    echo -e "\n-------------------------------------------"
    if test -z "$USER_PIN"; then
      notify-send -u critical -t 3000 -i 'status/security-high-symbolic' 'No PIN' \
        'No PIN was entered to get the BitWarden master password.'
      exit 1
    else
      echo ""
      echo "Received PIN from the command line."
    fi

    if ! MASTER_PASSWORD=$(secret-tool lookup type bitwarden user local |
      openssl aes-256-cbc -a -d -pbkdf2 -pass "pass:$USER_PIN"); then
      echo -e "\033[41mAuthentication failed\033[0m"
      echo "-------------------------------------------"
    else
      echo -e "\033[42mAuthentication successful!\033[0m"
      echo -e "Retrieving data from vault..."
      break
    fi
  done
  BW_SESSION=$(bw unlock "$MASTER_PASSWORD" --raw)
fi

readarray -t BW_LIST < <(bw list items --pretty --session "$BW_SESSION")

if [ "${#BW_LIST[@]}" -eq 0 ]; then
  notify-send -i 'status/security-high-symbolic' -u critical -t 3000 \
    'Vault retrieval failed' \
    'We could not access the BitWarden vault.'
  exit 1
fi

if [ "$1" = "cards" ]; then
  FILTER_COMMAND='.[]|select(.card)|{name, brand:.card.brand, favorite, notes, revisionDate, id, card}'
else
  FILTER_COMMAND='.[]|{name, user:.login.username, favorite, notes, password_updated:.login.passwordRevisionDate, last_updated:.login.revisionDate, id, card}'
fi

TARGET_ROW="$(echo "${BW_LIST[@]}" |
  jq -C "$FILTER_COMMAND" -r --compact-output |
  fzf --height 12 -d ',' --nth 1,2,3,4 --with-nth 1,2 --tac --ansi --preview 'echo {} | jq -C')"
if test -n "$TARGET_ROW"; then
  TARGET_ID="$(echo "$TARGET_ROW" | jq -r ".id")"
  TARGET_USER="$(echo "$TARGET_ROW" | jq -r ".user")"
  TARGET_PASSWORD="$(echo "${BW_LIST[@]}" | jq ".[]|select(.id == \"$TARGET_ID\")|.login.password" -r)"
  TARGET_CARD_BRAND="$(echo "$TARGET_ROW" | jq -r ".card.brand")"
  TARGET_CARD_NUMBER="$(echo "$TARGET_ROW" | jq -r ".card.number")"
  TARGET_CARD_EXP_MONTH="$(echo "$TARGET_ROW" | jq -r ".card.expMonth")"
  TARGET_CARD_EXP_YEAR="$(echo "$TARGET_ROW" | jq -r ".card.expYear")"
  TARGET_CARD_CODE="$(echo "$TARGET_ROW" | jq -r ".card.code")"
else
  exit 1
fi

if [ "$1" = "cards" ]; then
  echo -n "$TARGET_CARD_NUMBER" | xsel --primary
  echo -n "$TARGET_CARD_CODE" | xsel --secondary
  notify-send -i 'status/security-high-symbolic' -u normal -t 30000 \
    "$TARGET_CARD_BRAND copied" \
    "Exp. $TARGET_CARD_EXP_MONTH/$TARGET_CARD_EXP_YEAR"
  exit 0
elif test -n "$TARGET_PASSWORD"; then
  if test -n "$TARGET_USER"; then
    echo -n "$TARGET_USER" | xsel --primary
  fi
  echo -n "$TARGET_PASSWORD" | xsel --secondary
  notify-send -i 'status/security-high-symbolic' -u low -t 5000 \
    "User/password copied to primary/secondary clipboard" \
    "$(echo "$TARGET_ROW" | jq -C '.user + " at " + .name' -r), valid for 60 seconds"
  exit 0
else
  notify-send -i 'status/security-high-symbolic' -u critical -t 3000 \
    'Password grab failed' \
    'We could not get a password.'
  exit 0
fi
