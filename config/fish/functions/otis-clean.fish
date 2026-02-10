function otis-clean
    cd /tmp/junk-for-otis/
    latexmk -C
    rm -f {email,otis}*.{pdf,tex,log,txt,aux,fdb_latexmk,fls,out,pre,synctex.gz,asy,md}
end
