function bw-new
    if test -z "$BW_SESSION"
        echo "First, unlocking the BitWarden vault..."
        bw-unlock
    end

    set password0 (python ~/dotfiles/py-scripts/gen-password.py)
    set password1 (python ~/dotfiles/py-scripts/gen-password.py)
    set password2 (python ~/dotfiles/py-scripts/gen-password.py)
    set password3 (python ~/dotfiles/py-scripts/gen-password.py)
    set password4 (python ~/dotfiles/py-scripts/gen-password.py)
    echo "0. $password0"
    echo "1. $password1"
    echo "2. $password2"
    echo "3. $password3"
    echo "4. $password4"
    echo ------------------------
    read -P "Selected password (empty to take first): " response
    if test -z "$response"
        set new_password $password0
    else if test $response = 0
        set new_password $password0
    else if test $response = 1
        set new_password $password1
    else if test $response = 2
        set new_password $password2
    else if test $response = 3
        set new_password $password3
    else if test $response = 4
        set new_password $password4
    else
        set new_password $response
    end
    set_color brwhite
    echo "Chosen password: $new_password"
    set_color normal
    echo $new_password | xsel --primary
    echo "(copied to primary clipboard)"

    echo ------------------------
    read -P "Username: " new_user
    if test -z "$new_user"
        echo "Error: No user provided"
        return 1
    end
    read -P "Website: " new_uri
    if test -z "$new_uri"
        echo "Error: No URI provided"
        return 1
    end
    set new_name (echo $new_uri |
        sed "s/^https\?\:\/\///" |
        sed "s/\/.*//")
    set revision_date (date -Iseconds --utc)
    set item_login_uri (bw get template item.login.uri |
        jq ".uri=\"$new_uri\"")
    set item_login (bw get template item.login |
        jq ".username=\"$new_user\" |
        .password=\"$new_password\" |
        .passwordRevisionDate=null |
        .uris=[$item_login_uri]"
    )
    set item (bw get template item |
        jq ".name=\"$new_name\" |
        .revisionDate=\"$revision_date\" |
        .notes=null |
        .collectionIds = [] |
        .login = $item_login")
    echo $item | bw encode | bw create item | jq
    bw sync
end
