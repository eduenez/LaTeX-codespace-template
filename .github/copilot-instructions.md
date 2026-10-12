# Copilot Instructions for LaTeX Codespace Template

You are assisting with collaborative mathematical writing in LaTeX.

## Project Context

This repository hosts **many papers, one per subdirectory** (`<paper>/<paper>.tex`),
sharing vendored style files and one bibliography. See `CLAUDE.md` / `README.md`
for the layout. Skeletons are in `_templates/{article,monograph}`; create a paper
with `make new P=<name> TYPE=article|monograph`.

Each main `.tex` carries only `\documentclass`, one `\usepackage{<paper>}`, and
semantic metadata. All `\usepackage`, macros, and `\newtheorem` live in the paper's
`<paper>.sty`, which loads the shared `di-*` packages **vendored** in the root
`_packages/` — pristine copies pinned in `_packages/vendor.lock`. Never edit files
in `_packages/`; change shared code upstream in `LaTeX-shared-files` and re-vendor.
Work only inside the paper directory in question; use `\bibliography{../references}`.

Engine: **pdfLaTeX + STIX Two** fonts. Bibliography: **BibTeX** (a single root
`references.bib` shared by all papers, style `alpha`), vendored-but-editable (add citations directly).
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
- Compile with `latexmk` (configured for pdfLaTeX via the root `latexmkrc`).
- The finished PDF lands beside the paper's `.tex`; intermediates go to `_build/` — never
  edit or reference the `_build/` files.
- Use `make <paper>` or `make build` from the repository root (builds one/every paper).
