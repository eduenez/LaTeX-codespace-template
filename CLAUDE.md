# CLAUDE.md — instructions for agents

This repository hosts **many LaTeX papers**, one per subdirectory, sharing vendored
style files, one bibliography, and one toolchain. Humans: see `README.md`.
Conventions: `STYLE.md`.

## Layout (expected directory structure)

- `<paper>/` — one directory per manuscript (name: letters, digits, hyphens; never
  starting with `_` or `.`). Contains `<paper>.tex` (main: `\documentclass`,
  `\usepackage{<paper>}`, metadata only), `<paper>.sty` (ALL packages/macros/theorems for
  that paper), chapter files `<paper>-N-<topic>.tex` (monographs), a two-line
  `latexmkrc`, and the paper's figures/data/scripts.
- `references.bib` — the ONE shared bibliography at the repo root.
- `_packages/` — vendored shared `di-*.sty` files. **Never edit.** `vendor.lock` pins them.
- `_templates/{article,monograph}/` — skeletons (placeholder name `PAPER`).
- `_scripts/` — `new-paper.sh`, `export-paper.sh`, `texwrap.py`, `texfashion.py`, `texsep.py`, `setup-hooks.sh`.
- `latexmkrc` (root, non-hidden) — shared latexmk config. `Makefile` — all entry points.
- Directories starting with `_` are infrastructure, not papers. There are **no symlinks and no submodules**; do not add any (Windows users clone this).

## Commands (run from the repo root)

- `make new P=<name> TYPE=article|monograph` — create a paper.
- `make <paper>` — build one paper; `make build` — build all. Equivalent: `cd <paper> && latexmk`.
- Manual build also works: `cd <paper> && pdflatex <paper> && bibtex <paper> && pdflatex <paper> && pdflatex <paper>`.
- `make export P=<paper>` — self-contained copy in `_export/<paper>/` (gitignored).
- `make format|wrap|check|lint [P=<paper>]` — formatting/lint, all papers or one.
- Never run `latexmk` at the repo root; PDFs and `_build/` belong inside each paper directory (gitignored — do not commit them).

## Rules

1. **Work inside the paper directory you were asked about.** Do not touch other papers.
2. **Shared files are reached by relative path**: the main `.tex` sets
   `\makeatletter\def\input@path{{../_packages/}{_packages/}}\makeatother` before `\usepackage{<paper>}` and uses
   `\bibliography{../references}`. Keep these lines intact (the export script rewrites them).
3. **Bibliography**: add new entries only to the root `references.bib`; never create a per-paper `.bib`
   and never inline `thebibliography` lists. Keys: `Author-Author:YYYY`. Reuse an existing entry
   if the work is already present. Keep bare at-signs out of header comments.
4. **Preamble discipline**: no `\usepackage`/`\newcommand`/`\newtheorem` in the main `.tex`; they go in
   `<paper>.sty` ("Project-specific additions"). Shared notation belongs upstream in
   `LaTeX-shared-files`, not in `_packages/`.
5. **Style**: one sentence/clause per source line (`make wrap`), 2-space indent, `\cref`, no `$$`, no `eqnarray`
   (see `STYLE.md`). Soft-wrap in the editor is configured in `.vscode/settings.json`; do not hard-wrap prose to a column.
6. Do not put personal editor preferences (theme, font size, keybindings) in `.vscode/`.
7. Changes to shared infrastructure (`latexmkrc`, `Makefile`, `_scripts/`, `.vscode/`, CI, templates) affect every
   paper — keep them backward compatible and verify by building every paper (`make build`).
8. After editing a paper, build it and fix undefined references/citations before finishing.
