function pdfenc --argument-names infile outfile password
    qpdf --encrypt "$password" "$password" 256 --print=none --modify=none -- $infile $outfile
end
