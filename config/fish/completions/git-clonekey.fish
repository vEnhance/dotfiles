# Completions for git-clonekey (functions/git-clonekey.fish).
# First argument is a key; after that, files (for the target directory).
function __git_clonekey_needs_key
    test (count (commandline -opc)) -eq 1
end
complete -c git-clonekey -n __git_clonekey_needs_key -f -a "(__git_setkey_keys)"
complete -c git-clonekey -n __git_clonekey_needs_key -s h -l help -d "Show help"
