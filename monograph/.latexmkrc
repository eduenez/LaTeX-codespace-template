# .latexmkrc — latexmk configuration for the monograph
# Inherits root settings; override here if needed.

$pdf_mode = 5;          # xelatex
$out_dir  = 'build';

ensure_path('TEXINPUTS', './');
$emulate_aux = 1;

$xelatex = 'xelatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';

# Use biber for biblatex
$biber = 'biber --output-directory=%O %S';
