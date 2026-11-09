# Private keys in ~/.ssh that have a matching .pub file, with the
# public key's comment as the description. Used by completions.
function __git_setkey_keys
    for pub in ~/.ssh/*.pub
        set -l priv (string replace -r '\.pub$' '' -- $pub)
        test -f $priv; or continue
        set -l comment (string split -m2 ' ' -- (head -n1 $pub))[3]
        printf '%s\t%s\n' (path basename -- $priv) "$comment"
    end
end
