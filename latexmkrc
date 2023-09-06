# This version is better than the one given by official asy doc
# because it will work with latexmk -cd as well.
# Unfortunately, I doubt it works on windows,
# because dirname is a linux command.
sub run_asy {
    return system("asy -o \$(dirname '$_[0]') '$_[0]'");
}
add_cus_dep("asy", "eps", 0, "run_asy");
add_cus_dep("asy", "pdf", 0, "run_asy");
add_cus_dep("asy", "tex", 0, "run_asy");

# von.sty uses pythontex now, so this routine auto-runs pythontex
sub pythontex {
    system("pythontex --runall true \"$_[0]\"");
    system("touch \$(basename \"$_[0]\").pytxmcr");
    return;
}
add_cus_dep("pytxcode", "pytxmcr", 0, "pythontex");

# We always prefer lualatex to pdflatex by default.
$pdf_mode = 4;

# latexmk should change directory to the source file of the TeX
# so relative paths get resolved correctly
$do_cd = 1;

# We always want to generate PDF files, not the old DVI/PS formats.
$dvi_mode = 0;
$postscript_mode = 0;

# SyncTeX gives certain editors and PDF viewers a way to jump like in Overleaf.
# So we just always enable this option by default.
push @extra_pdflatex_options, '-synctex=1' ;
push @extra_lualatex_options, '-synctex=1' ;

# By default, latex is really noisy and produces a lot of output
# that scrolls so fast that you can't read it even if you wanted to.
# It's stored in the *.log file anyway, so we just silence it.
$silent = 1;

# However, if latex crashes, we probably DO care about the error
# The following failure command searches the log file for lines beginning
# with exclamation marks, which are likely candidates for errors.
# It prints those lines and five lines following it.
$failure_cmd = 'echo -e "\\033[1;31m---- BEGIN ERROR LOG %T ----\\033[1;37m"; '
    . 'grep -A 5 "^! " %R.log; '
    . 'echo -e "\\033[1;31m---- ENDOF ERROR LOG %T ----\\033[0m"; ';

# Certain deep system dependencies seem to get picked up by latexmk, like fonts
# We don't want to re-run LaTeX just because these have changed,
# because this usually doesn't change the output.
# So, we ignore the hashes for files with these extensions
$hash_calc_ignore_pattern{'map'} = '^';
$hash_calc_ignore_pattern{'fmt'} = '^';
$hash_calc_ignore_pattern{'luc'}='^';
$hash_calc_ignore_pattern{'luc.gz'}='^';
$hash_calc_ignore_pattern{'gz'}='^';
$hash_calc_ignore_pattern{'ttf:1:nil'}='^';

# Misc personal preferences
$max_repeat = 7;
$pdf_previewer = "zathura %O %S &> /dev/null &";
$pvc_timeout = 1;
$cleanup_includes_generated = 0;
$cleanup_includes_cusdep_generated = 1;
@generated_exts = ( 'aux', 'bbl', 'bcf', 'fls', 'idx', 'ind', 'lof',
                    'lot', 'out', 'pre', 'toc', 'nav', 'snm',
                    'synctex.gz', 'pytxpyg', 'pytxmcr', 'pytxcode',);

# vim: ft=perl
