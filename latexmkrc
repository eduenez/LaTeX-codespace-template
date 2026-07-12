# latexmkrc — root fallback config.
#
# Not used by `make monograph` / `make article` (each project directory has
# its own latexmkrc, since latexmk reads the one in the current directory).
# This one is here for building a one-off .tex file placed directly at the
# repository root; it resolves the shared sty/ and bib/ submodules the same
# way the per-project files do.

use Cwd 'abs_path';
use File::Basename 'dirname';
my $here = dirname(abs_path(__FILE__));

ensure_path('TEXINPUTS', "$here/sty//:");
ensure_path('BIBINPUTS', "$here/bib//:");

$pdf_mode = 1;
$pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 %O %S';

$biber = 'biber %O %S';
$out_dir = 'build';
