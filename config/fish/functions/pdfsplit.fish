function pdfsplit
    qpdf --split-pages=1 $argv[1] page%d-$argv[1]
end
