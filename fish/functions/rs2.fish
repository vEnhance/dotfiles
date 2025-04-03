function rs2
    set regex "[abe-hjkn-uwyz]*"(
        echo $argv[1] |
        string lower |
        string split '' |
        string join '[abe-hjkn-uwyz ]*'
    )"[abe-hjkn-uwyz]*"
    ag -w $regex $argv[2..]
end
