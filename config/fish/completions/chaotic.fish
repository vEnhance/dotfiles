# Completions for the `chaotic` alias (py-scripts/chaotic.py).
#
# chaotic-aur is registered with `Usage = Sync Search`, so pacman's own
# completions never offer its packages to -S. These fill that gap.

function __chaotic_no_subcommand
    not __fish_seen_subcommand_from update install diff
end

# Installed chaotic packages, with their currently-offered version as the
# description. -Sl output is `chaotic-aur name version [installed...]`.
function __chaotic_installed
    pacman -Sl chaotic-aur 2>/dev/null | string match -r '^\S+ \S+ \S+ \[installed.*' |
        string replace -r '^\S+ (\S+) (\S+) .*' '$1\t$2'
end

function __chaotic_available
    pacman -Sl chaotic-aur 2>/dev/null | string replace -r '^\S+ (\S+) (\S+).*' '$1\t$2'
end

complete -c chaotic -f

complete -c chaotic -n __chaotic_no_subcommand -a update -d "Upgrade installed chaotic packages"
complete -c chaotic -n __chaotic_no_subcommand -a install -d "Install new packages from chaotic-aur"
complete -c chaotic -n __chaotic_no_subcommand -a diff -d "Show PKGBUILD diffs, change nothing"

complete -c chaotic -n "__fish_seen_subcommand_from update diff" -a "(__chaotic_installed)"
complete -c chaotic -n "__fish_seen_subcommand_from install" -a "(__chaotic_available)"

complete -c chaotic -l no-refresh -d "Skip refreshing chaotic-aur.db"
complete -c chaotic -n "__fish_seen_subcommand_from update install" -l no-audit -d "Skip the PKGBUILD diff review"
complete -c chaotic -n "__fish_seen_subcommand_from update install" -l noconfirm -d "Do not prompt"
complete -c chaotic -s h -l help -d "Show help"
