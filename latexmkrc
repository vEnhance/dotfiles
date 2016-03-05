sub run_asy {return system("asy '$_[0]'");}
add_cus_dep("asy", "eps", 0, "run_asy");
add_cus_dep("asy", "pdf", 0, "run_asy");
add_cus_dep("asy", "tex", 0, "run_asy");

$pdf_mode = 1;
$pdf_previewer = "zathura %O %S &";

$cleanup_includes_generated = 1;
$cleanup_includes_cusdep_generated = 1;

@generated_exts = ( 'aux', 'bbl', 'bcf', 'fls', 'idx', 'ind', 'lof',
                    'lot', 'out', 'pre', 'toc', 'asy', 'nav', 'snm' );
