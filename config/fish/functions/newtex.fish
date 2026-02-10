# Create a new TeX file
function newtex
    if string match '*.tex' $argv
        echo "That's probably not what you meant to do"
        return 1
    end
    mkdir "$argv"
    cd "$argv"
    echo '\documentclass[11pt]{scrartcl}' >"$argv.tex"
    echo '\usepackage{evan}' >>"$argv.tex"
    echo '\begin{document}' >>"$argv.tex"
    echo '\title{}' >>"$argv.tex"
    echo '' >>"$argv.tex"
    echo '\end{document}' >>"$argv.tex"
    nvim "$argv.tex"
end
