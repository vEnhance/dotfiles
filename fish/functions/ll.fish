function ll
    if test (count *) -gt 1024
        # grep is going to choke anyways, so just list stuff
        ls -l --block-size=K --color=yes $argv
        return
    end
    if test (count *.tex) -eq 0
        ls -l --block-size=K --color=yes $argv
        return
    end
    set --function regex '('(string join '|' (string sub --end=-5 (string escape --style=regex *.tex)))')'
    set --function regex $regex'\.(aux|bbl|bcf|blg|fdb_latexmk|fls|log|maf|mtc0?|nav|out|pre|ptc[0-9]+|pytxcode|pytxmcr|pytxpyg|run\.xml|snm|synctex(\.gz|\(busy\))|toc|von|vrb|xdv)|-[0-9]{1,2}\.(asy|pdf)$'
    set --function regex '('$regex')|pythontex_data\.pkl'
    set num_hidden (ls -l --block-size=K --color=yes $argv | grep -E $regex 2> /dev/null | wc --lines)
    ls -l --block-size=K --color=yes $argv | grep -Ev $regex 2>/dev/null
    if test $num_hidden -gt 0
        echo (set_color cyan)"... and" (set_color --bold brgreen)$num_hidden(set_color normal)(set_color cyan) "garbage files not shown"(set_color normal)
    end
end
