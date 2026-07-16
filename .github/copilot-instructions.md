# Copilot Instructions for LaTeX Codespace Template

You are assisting with collaborative mathematical writing in LaTeX.

## Project Context

This repository provides two LaTeX starting points at the repo root (a child
project keeps one and deletes the other):
- **monograph-template.tex** — a book/monograph using the `memoir` document class
- **article-template.tex** — a research paper using the `amsart` document class

Each master `.tex` carries only `\documentclass`, one `\usepackage{<master>}`,
and semantic metadata. All `\usepackage`, macros, and `\newtheorem` live in the
project style file `<master>.sty` (`article-template.sty` /
`monograph-template.sty`), which loads the shared `di-*` packages **vendored** in
`packages/` — pristine copies pinned in `packages/vendor.lock`. Never edit files
in `packages/` (see `packages/_DO_NOT_EDIT_FILES_IN_THIS_DIRECTORY.md`); change
shared code upstream in `LaTeX-shared-files` and re-vendor.

Engine: **pdfLaTeX + STIX Two** fonts. Bibliography: **BibTeX** (a single root
`references.bib`, style `alpha`), vendored-but-editable (add citations directly).
See `STYLE.md` for the full conventions.

## LaTeX Conventions

### Math Delimiters
- **Inline**: `$ ... $` or `\( ... \)`.
- **Display (unnumbered)**: `equation*` or `\[ ... \]`. **Never** use `$$ ... $$`.
- **Display (numbered)**: `equation`
- **Multi-line**: `align` or `align*`. **Never** use `eqnarray`.

### Cross-Referencing
- Use `\label{prefix:descriptive-name}` (no spaces in labels).
- Use `\cref{...}` or `\Cref{...}` (cleveref) for references — never `Theorem \ref{...}`.
- Prefixes: `thm:`, `lem:`, `prop:`, `cor:`, `def:`, `exa:`, `rem:`, `notn:`, `eq:`, `sec:`, `cha:`, `fig:`, `conj:`.

### Formatting
- **One sentence per line** (semantic wrapping) — start a new line after each
  sentence and each semicolon/colon clause. Run `make wrap` to normalize.
- **2-space indentation** inside environments.
- No tabs, no trailing whitespace.
- Use semantic commands (`\RR`, `\norm{x}`) instead of raw LaTeX (`\mathbb{R}`, `\|x\|`).

### Environments
Use the theorem-like environments defined in the project `.sty` (which loads the
vendored shared packages): `theorem`, `lemma`, `proposition`, `corollary`,
`conjecture`, `definition`, `example`, `exercise`, `remark`, `notation`.

### Collaboration
- Use `\todo{...}` for notes and reminders (todonotes package).
- Use `\cite{key}` for citations (BibTeX); prefer a non-breaking space before it
  (`Doe~\cite{Doe:2020}`). The bibliography is `\bibliographystyle{alpha}` +
  `\bibliography{references}` at the end of the main file.
- Define macros for repeated notation in the project `.sty` (which loads the
  vendored shared packages), never in the master `.tex`.

## Build
- Compile with `latexmk` (configured for pdfLaTeX via `.latexmkrc`).
- The finished PDF lands at the repo root; intermediates go to `build/` — never
  edit or reference the `build/` files.
- Use `make build` from the repository root (builds every main document).
