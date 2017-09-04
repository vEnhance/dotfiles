sub run_asy { return system("asy '$_[0]'"); }
add_cus_dep("asy", "eps", 0, "run_asy");
add_cus_dep("asy", "pdf", 0, "run_asy");
add_cus_dep("asy", "tex", 0, "run_asy");

sub von_run { return system("bash -i '$_[0].von'"); }
add_cus_dep("von", "out", 0, "von_run");

$pdf_mode = 1;
$pdf_previewer = "zathura %O %S &";

$cleanup_includes_generated = 1;
$cleanup_includes_cusdep_generated = 1;

@generated_exts = ( 'aux', 'bbl', 'bcf', 'fls', 'idx', 'ind', 'lof',
                    'lot', 'out', 'pre', 'toc', 'asy', 'nav', 'snm', 'von');

# don't hash calc for deep system dependencies
$hash_calc_ignore_pattern{'map'} = '^';
$hash_calc_ignore_pattern{'fmt'} = '^';

# vim: ft=perl
