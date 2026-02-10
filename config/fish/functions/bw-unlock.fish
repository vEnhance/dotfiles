function bw-unlock
    set_color brpurple
    echo "Enter PIN to continue (or leave blank if none):"
    set_color normal
    read -s -P "[echo hidden]: " USER_PIN
    set MASTER_PASSWORD ""
    if test -n "$USER_PIN"
        set MASTER_PASSWORD (secret-tool lookup type bitwarden user local |
            openssl aes-256-cbc -a -d -pbkdf2 -pass "pass:$USER_PIN")
    end
    if test -z "$MASTER_PASSWORD"
        export BW_SESSION=(bw unlock --raw)
    else
        export BW_SESSION=(bw unlock "$MASTER_PASSWORD" --raw)
    end
    bw status | jq
end
