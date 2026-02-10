# Shortcut for editors and the like
function pdf -w zathura
    string match '*.pdf' "$argv" >/dev/null
    if test \( -f "$argv" \) -a \( $status -eq 0 \)
        dn zathura $argv &>/dev/null
    else if test -f (echo $argv | cut -f 1 -d '.').pdf
        dn zathura (echo $argv | cut -f 1 -d '.').pdf &>/dev/null
    else if test -f "$argv""pdf"
        dn zathura "$argv""pdf" &>/dev/null
    else if test -f "$argv.pdf"
        dn zathura "$argv.pdf" &>/dev/null
    else
        echo "Cannot found a suitable file."
    end
end
