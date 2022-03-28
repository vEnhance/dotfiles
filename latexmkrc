push @extra_pdflatex_options, '-synctex=1' ;

# This version is better than the one given by official asy doc
# because it will work with latexmk -cd as well.
# Unfortunately, I doubt it works on windows,
# because dirname is not a linux command.
sub run_asy {
    return system("asy -o \$(dirname '$_[0]') '$_[0]'");
}
add_cus_dep("asy", "eps", 0, "run_asy");
add_cus_dep("asy", "pdf", 0, "run_asy");
add_cus_dep("asy", "tex", 0, "run_asy");

sub pythontex {
    system("pythontex --runall true \"$_[0]\"");
    system("touch \$(basename \"$_[0]\").pytxmcr");
    return;
}
add_cus_dep("pytxcode", "pytxmcr", 0, "pythontex");

$do_cd = 1;
$pdf_mode = 1;
$max_repeat = 7;
$pdf_previewer = "zathura %O %S &> /dev/null &";
$pvc_timeout = 1;

$cleanup_includes_generated = 0;
$cleanup_includes_cusdep_generated = 1;

@generated_exts = ( 'aux', 'bbl', 'bcf', 'fls', 'idx', 'ind', 'lof',
                    'lot', 'out', 'pre', 'toc', 'nav', 'snm',
                    'synctex.gz', 'pytxpyg', 'pytxmcr', 'pytxcode',);

# don't hash calc for deep system dependencies
$hash_calc_ignore_pattern{'map'} = '^';
$hash_calc_ignore_pattern{'fmt'} = '^';

$silent = 1;

# vim: ft=perl
