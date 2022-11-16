#!/bin/fish

# for bash use read -sp instead of read -s -P
read -s -P "BitWarden Password: " BITWARDEN_MASTER_PASSWORD
read -s -P "User PIN: " USER_PIN

echo "$BITWARDEN_MASTER_PASSWORD" \
    | openssl aes-256-cbc -a -salt -pbkdf2 -pass "pass:$USER_PIN" \
    | secret-tool store --label="BitWarden Vault" type bitwarden user local
