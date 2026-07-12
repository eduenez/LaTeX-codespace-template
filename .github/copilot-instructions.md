# Copilot Instructions for LaTeX Codespace Template

You are assisting with collaborative mathematical writing in LaTeX.

## Project Context

This repository contains two LaTeX project templates, both built with pdfLaTeX and both loading
the shared `di-base` preamble (`sty/` submodule, from `LaTeX-shared-files`):

- **monograph/** — a book/monograph using the `memoir` document class.
  `monograph-template.tex` is a thin master file (preamble, front/back matter,
  `\includeonly` toggle) that `\include`s one file per chapter (`ch-*.tex`).
  `monograph.sty` layers monograph-specific additions on `di-base`: it re-parents theorem and
  equation numbering from `[section]` to `[chapter]`, and adds the `conjecture`/`exercise`
  environments and a few macros.
- **article/** — a single-file research paper using the `amsart` document class.
  `article-template.tex` loads `di-base` directly and adds its own theorem environment
  (`conjecture`) and macros inline, following the pattern of a real single-file paper.

Both projects use biblatex/biber, with a local `references.bib` active by default; the shared
`bib/` submodule (`math-bibliography`) is present but only wired in if its commented
`\addbibresource` line is uncommented — some coauthors may prefer self-contained references or be
unfamiliar with git submodules.

## LaTeX Conventions

### Math Delimiters
- **Inline**: `$ ... $` or `\( ... \)`.
- **Display (unnumbered)**: `equation*` or `\[ ... \]`. **Never** use `$$ ... $$`.
- **Display (numbered)**: `equation`
- **Multi-line**: `align` or `align*`. **Never** use `eqnarray`.

### Cross-Referencing
- Use `\label{prefix:descriptive-name}` (no spaces in labels).
- Use `\cref{...}` or `\Cref{...}` (cleveref) for references — never `Theorem \ref{...}`.
- Prefixes: `thm:`, `lem:`, `prop:`, `cor:`, `def:`, `exa:`, `rem:`, `notn:`, `eq:`, `sec:`, `cha:`,
  `fig:`, `conj:`.

### Formatting
- **One sentence per line** — start a new line after each period.
- **100 column limit** for prose lines.
- **2-space indentation** inside environments.
- No tabs, no trailing whitespace.
- Use semantic commands (`\RR`, `\norm{x}`) instead of raw LaTeX (`\mathbb{R}`, `\|x\|`).

### Environments
Use the theorem-like environments defined in `sty/di-base.sty` (shared) and each project's own
`.sty`/preamble (`monograph.sty` for monograph/, inline for article/):
`theorem`, `lemma`, `proposition`, `corollary`, `conjecture`, `definition`, `example`, `exercise`
(monograph only), `remark`, `notation`.

### Collaboration
- Use `\todo{...}` for notes and reminders (todonotes package).
- Use `\autocite{key}` for citations (biblatex).
- Define macros in the project's `.sty`/preamble for repeated notation, not inline in chapter/body
  content.

## Build
- Compile with `latexmk` (configured for pdfLaTeX via each project's `latexmkrc`).
- Build artifacts go to `build/` — never edit or reference these.
- Use `make monograph` or `make article` from the repository root.
