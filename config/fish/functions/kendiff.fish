# latexdiff, but treating theorem-like environments as items,
# and with the preamble's blue recolored to red
function kendiff -w latexdiff
    if test (count $argv) -ne 2
        echo "Usage: kendiff OLD.tex NEW.tex" >&2
        return 1
    end
    latexdiff --config 'ITEMCMD=(?:item|begin\{(?:theorem|lemma|proposition|corollary|definition|remark|example|case|proof)\})' $argv[1] $argv[2] \
        | sed '/%DIF PREAMBLE/ s/\\\\color{blue}/\\\\color{red}/g'
end
