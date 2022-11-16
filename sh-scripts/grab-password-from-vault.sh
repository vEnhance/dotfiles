#!/bin/bash

if test -z "$BW_SESSION"; then
  USER_PIN=$(rofi -dmenu -p "Enter the PIN" -password -lines 0 --location 2)
  if test -z "$USER_PIN"; then
    echo "No PIN was entered"
    exit 1
  fi

  if ! MASTER_PASSWORD=$(secret-tool lookup type bitwarden user local |
    openssl aes-256-cbc -a -d -pbkdf2 -pass "pass:$USER_PIN"); then
    notify-send -u critical -t 5000 -i "status/dialog-password" "Wrong PIN" \
      "Either that or master password retrieval failed"
    exit 1
  fi
  BW_SESSION=$(bw unlock "$MASTER_PASSWORD" --raw)
fi

TARGET_DATA="$(bw list items --pretty --session "$BW_SESSION" |
  jq -C '.[]|{name, user:.login.username, favorite, notes, password_updated:.login.passwordRevisionDate, last_updated:.login.revisionDate, id}' -r --compact-output |
  fzf -d "," --nth 1,2,3,4 --with-nth 1,2 --tac --ansi --preview 'echo {} | jq -C')"

if test -n "$TARGET_DATA"; then
  COPIED_PASSWORD="$(bw get password --session "$BW_SESSION" "$(echo "$TARGET_DATA" | jq -C '.id' -r)")"
else
  exit 1
fi

if test -n "$COPIED_PASSWORD"; then
  echo "$COPIED_PASSWORD" | xsel --primary
  notify-send -i 'status/dialog-password' -u low -t 5000 \
    "Password copied to primary clipboard" \
    "$(echo "$TARGET_DATA" | jq -C '.name + " for " + .user' -r), valid for 30 seconds"
  sleep 30 && xsel --primary --clear &
  bw lock
  exit 0
else
  notify-send -i 'status/dialog-password' -u error -t 3000 \
    "Password grab failed" \
    "We could not get a password"
  exit 0
fi
