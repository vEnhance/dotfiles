#!/bin/bash

echo "+=========================================+"
echo -e "| Welcome to the \033[1;36mBITWARDEN Vault grabber\033[m! |"
echo -e "| (yet another hack written by \033[1;33mEvan Chen\033[m) |"
echo "+=========================================+"

if test -z "$BW_SESSION"; then
  echo -e "\033[1;35mEnter the PIN to continue.\033[m"
  read -r -s -p "[echo hidden]: " USER_PIN
  echo -e "\n-------------------------------------------"
  if test -z "$USER_PIN"; then
    notify-send -u critical -t 3000 -i 'status/security-high-symbolic' 'No PIN' \
      'No PIN was entered to get the BitWarden master password.'
    exit 1
    exit 1
  else
    echo ""
    echo "Received PIN from the command line."
  fi

  if ! MASTER_PASSWORD=$(secret-tool lookup type bitwarden user local |
    openssl aes-256-cbc -a -d -pbkdf2 -pass "pass:$USER_PIN"); then
    notify-send -u critical -t 5000 -i 'status/security-high-symbolic' 'Wrong PIN' \
      'Either that or master password retrieval failed'
    exit 1
  else
    echo -e "\033[42mAuthentication successful!\033[0m"
    echo -e "Retrieving data from vault..."
  fi
  BW_SESSION=$(bw unlock "$MASTER_PASSWORD" --raw)
fi

readarray -t BW_LIST < <(bw list items --pretty --session "$BW_SESSION")
if [ "${#BW_LIST[@]}" -eq 0 ]; then
  notify-send -i 'status/security-high-symbolic' -u critical -t 3000 \
    'Vault retrieval failed' \
    'We could not access the BitWarden vault.'
  exit 1
fi

TARGET_ROW="$(echo "${BW_LIST[@]}" |
  jq -C '.[]|{name, user:.login.username, favorite, notes, password_updated:.login.passwordRevisionDate, last_updated:.login.revisionDate, id}' -r --compact-output |
  fzf --height 12 -d ',' --nth 1,2,3,4 --with-nth 1,2 --tac --ansi --preview 'echo {} | jq -C')"
if test -n "$TARGET_ROW"; then
  TARGET_ID="$(echo "$TARGET_ROW" | jq -r ".id")"
  TARGET_PASSWORD="$(echo "${BW_LIST[@]}" | jq ".[]|select(.id == \"$TARGET_ID\")|.login.password" -r)"
else
  exit 1
fi

if test -n "$TARGET_PASSWORD"; then
  echo -n "$TARGET_PASSWORD" | xsel --secondary
  notify-send -i 'status/security-high-symbolic' -u low -t 5000 \
    "Password copied to secondary clipboard" \
    "$(echo "$TARGET_ROW" | jq -C '.user + " at " + .name' -r), valid for 30 seconds"
  sleep 30 && xsel --secondary --clear &
  # sleep 0.2 && xdotool type "$TARGET_PASSWORD" && bw lock &
  exit 0
else
  notify-send -i 'status/security-high-symbolic' -u critical -t 3000 \
    'Password grab failed' \
    'We could not get a password.'
  exit 0
fi
