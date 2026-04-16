# Copilot Instructions for LaTeX Codespace Template

You are assisting with collaborative mathematical writing in LaTeX.

## Project Context

This repository contains two LaTeX project templates:
- **monograph/** — a book/monograph using the `memoir` document class (XeLaTeX)
- **article/** — a research paper using the `amsart` document class (XeLaTeX)

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
- **One sentence per line** — start a new line after each period.
- **90 column limit** for prose lines.
- **2-space indentation** inside environments.
- No tabs, no trailing whitespace.
- Use semantic commands (`\RR`, `\norm{x}`) instead of raw LaTeX (`\mathbb{R}`, `\|x\|`).

### Environments
Use the theorem-like environments defined in each template's preamble:
`theorem`, `lemma`, `proposition`, `corollary`, `conjecture`, `definition`, `example`, `exercise`, `remark`, `notation`.

### Collaboration
- Use `\todo{...}` for notes and reminders (todonotes package).
- Use `\autocite{key}` for citations (biblatex).
- Define macros in the preamble for repeated notation.

## Build
- Compile with `latexmk` (configured for XeLaTeX via `.latexmkrc`).
- Build artifacts go to `build/` — never edit or reference these.
- Use `make monograph` or `make article` from the repository root.
