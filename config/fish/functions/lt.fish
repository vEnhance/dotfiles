# language tool wrapper
function lt -w j-langtool
    j-langtool $argv | cut -c 1-80 | bat -l verilog --wrap=never --paging=never
end
