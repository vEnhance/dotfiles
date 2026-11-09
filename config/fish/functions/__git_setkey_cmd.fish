# Print the core.sshCommand string for a key name (~/.ssh/NAME) or a key
# path (anything containing a /). Shared by git-setkey and git-clonekey.
function __git_setkey_cmd
    set -l key $argv[1]
    if string match -q '*/*' -- $key
        # Explicit path: make it absolute, since git may run ssh elsewhere.
        set -l file (path resolve -- $key)
        if not test -f $file
            echo "no such key file: $file" >&2
            return 1
        end
        set keyarg "'$file'"
    else
        if not test -f ~/.ssh/$key
            echo "no such key: ~/.ssh/$key" >&2
            return 1
        end
        # Keep ~ literal; git runs sshCommand via sh, which expands it.
        set keyarg "~/.ssh/$key"
    end
    # IdentitiesOnly stops ssh from offering agent/default keys first,
    # which GitHub might accept as a different (wrong) deploy key.
    echo "/usr/bin/ssh -i $keyarg -o IdentitiesOnly=yes"
end
