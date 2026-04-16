# .latexmkrc — latexmk configuration
#
# Engine: XeLaTeX (change $pdf_mode to 1 for pdflatex)
# Output directory: build/  (keeps the source tree free of build artifacts)

$pdf_mode = 5;          # xelatex → xdv → xdvipdfmx → PDF
$out_dir  = 'build';    # all artifacts go here

# Ensure latexmk can find source files when building from subdirectories.
ensure_path('TEXINPUTS', './');

# Silence latexmk about missing build dirs for \include'd files.
$emulate_aux = 1;

# Enable SyncTeX for forward/inverse search in VS Code.
$xelatex = 'xelatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';
