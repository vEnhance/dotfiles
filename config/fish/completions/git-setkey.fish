# Completions for git-setkey (functions/git-setkey.fish).
complete -c git-setkey -f
complete -c git-setkey -a "(__git_setkey_keys)"
complete -c git-setkey -l unset -d "Remove core.sshCommand from this repo"
complete -c git-setkey -s h -l help -d "Show help"
