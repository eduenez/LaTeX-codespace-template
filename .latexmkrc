# .latexmkrc — latexmk configuration
#
# Engine: pdfLaTeX (uniform across the group's repositories; STIX Two fonts).
#
# Output layout: the PDF (the product) lands next to the source at the repo
# root; all intermediate files (.aux, .log, .fls, .fdb_latexmk, .bbl, .out, …)
# are tucked into build/ (the "working directory"). This is the
# $aux_dir/$out_dir split — latexmk moves the final PDF from the aux dir back
# to $out_dir. build/ and the root *.pdf are both gitignored.
#
# NOTE: this governs latexmk only. A manual `pdflatex; bibtex; pdflatex`
# sequence ignores this file and writes everything to the current directory —
# that still works; it just leaves the intermediates at the root.

$aux_dir = 'build';
$out_dir = '.';

$pdf_mode = 1;   # pdflatex → PDF
$pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 %O %S';

# Monographs \include chapter files; $emulate_aux lets latexmk manage their
# per-file .aux inside $aux_dir without "cannot find .aux" complaints.
$emulate_aux = 1;
