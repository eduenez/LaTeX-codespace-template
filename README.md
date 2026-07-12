# LaTeX Codespace Template

A batteries-included template repository for collaborative LaTeX writing, designed to be used as a [GitHub template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository).
It provides two project templates — a **monograph** (memoir class) and a **research article** (amsart class) — along with a fully configured Codespace for cloud-based editing with VS Code.

Both projects are built with **pdflatex** and share a common preamble system: `di-base` (theorem
environments, math fonts, hyperref/cleveref setup) and an optional shared bibliography, both
included as git submodules — see [Shared Preamble](#shared-preamble) and
[Bibliography](#bibliography) below.

## Quick Start

This repository uses two git submodules (`sty/` and `bib/`), so clone **with**
`--recurse-submodules`:

```bash
git clone --recurse-submodules <your-new-repo-url>
cd <your-new-repo>
git submodule update --init --recursive   # if you forgot --recurse-submodules
```

1. Click **"Use this template"** on GitHub to create a new repository.
2. Open the new repository in a **GitHub Codespace** (or clone locally, with submodules).
3. Choose a project template:
   - `monograph/` — for a book, thesis, or lecture notes
   - `article/` — for a journal paper or preprint
4. Start writing!
   Build with `make monograph` or `make article`.

## Shared Preamble

Both templates load [`di-base`](https://github.com/eduenez/LaTeX-shared-files), mounted at
[`sty/`](sty/) as a git submodule, via `\usepackage{di-base}`.
It provides the standard theorem-environment taxonomy (`theorem`, `proposition`, `lemma`,
`corollary`, `definition`, `example`, `remark`, `notation`, …, all sharing one counter), engine-
agnostic math fonts, and the core math/cross-referencing package set (`mathtools`, `amsthm`,
`tikz-cd`, `hyperref`, `cleveref`).
Project-specific additions layer on top:

- `monograph/monograph.sty` re-parents theorem and equation numbering from `[section]` to
  `[chapter]` (since the monograph is chapter-structured) and adds a couple of extra environments
  and macros.
- `article/article-template.tex` adds its extra environment/macros directly inline, since it's a
  single-file paper.

See [`sty/README.md`](sty/README.md) for the full package documentation.

## Bibliography

Each project has its own local `references.bib`, active by default.
The shared [`math-bibliography`](https://github.com/eduenez/math-bibliography) database is also
available as a submodule at [`bib/`](bib/), but is **not** wired in by default — some coauthors may
prefer to keep a project's references self-contained, or may be unfamiliar with git submodules.
To opt in, uncomment the `\addbibresource{bib/references.bib}` line near the top of
`monograph-template.tex` / `article-template.tex`.

### Working with the submodules

```bash
# After a fresh clone (or after pulling a commit that adds/moves a submodule):
git submodule update --init --recursive

# Pull the latest bibliography entries from upstream (only if bib/ is in use):
git submodule update --remote bib
git add bib && git commit -m "Bump bibliography submodule"
```

`git pull` updates the *pointer* to a submodule's commit but does not change the files inside it —
run `git submodule update --init --recursive` after pulling to sync them.

If drawing on the shared database, new entries follow the `Author-Author:YYYY` citation-key
convention — see [`bib/README.md`](bib/README.md).

## Repository Structure

```
.
├── .chktexrc                 # chktex linter configuration
├── .devcontainer/            # Codespace / Dev Container configuration
│   ├── devcontainer.json     #   VS Code extensions and settings
│   ├── docker-compose.yml    #   Container orchestration
│   └── Dockerfile            #   TeX Live + tools image
├── .github/
│   ├── copilot-instructions.md  # AI assistant instructions
│   └── workflows/
│       └── lint-and-build.yml   # CI: lint, check, build PDFs
├── .gitignore
├── .gitmodules                # bib/ and sty/ submodule declarations
├── latexmkrc                  # Root latexmk fallback config (see comment in the file)
├── .vscode/
│   └── settings.json         # VS Code settings (fallback for non-Codespace use)
├── article/                  # Research paper template (amsart)
│   ├── latexmkrc
│   ├── article-template.tex
│   ├── references.bib
│   └── build/                # (gitignored) build artifacts
├── bib/                       # Shared bibliography (git submodule → math-bibliography)
├── sty/                       # Shared preamble (git submodule → LaTeX-shared-files)
├── latexindent.yaml          # latexindent configuration
├── Makefile                  # Build, format, lint, clean targets
├── monograph/                # Monograph template (memoir)
│   ├── latexmkrc
│   ├── monograph-template.tex
│   ├── monograph.sty          # Monograph-specific preamble (layered on di-base)
│   ├── ch-introduction.tex
│   ├── ch-background.tex
│   ├── ch-main-results.tex
│   ├── ch-conclusion.tex
│   ├── references.bib
│   └── build/                # (gitignored) build artifacts
├── scripts/
│   ├── setup-hooks.sh        # Installs git pre-commit hook
│   └── texwrap.py            # Semantic line-wrapper
└── README.md
```

## Building

The projects use **pdflatex** via `latexmk`.
All build artifacts (`.aux`, `.log`, `.pdf`, …) are written to a `build/` subdirectory, keeping the source tree clean.

```bash
make monograph      # Build the monograph PDF
make article        # Build the article PDF
```

Or build directly:
```bash
cd monograph && latexmk monograph-template
cd article   && latexmk article-template
```

In VS Code / Codespace, saving a `.tex` file triggers an automatic build via LaTeX Workshop.

## Formatting Rules

These rules are enforced by the **pre-commit hook** and **CI pipeline**.

### One Sentence Per Line

Always start a new line after each sentence.
This is the single most important rule for collaborative LaTeX writing with Git.

```latex
% ✓ GOOD — each sentence on its own line
Widget theory was initiated by Doe~\cite{Doe2020}.
The main theorem characterizes compact widgets.

% ✗ BAD — paragraph on a single line
Widget theory was initiated by Doe~\cite{Doe2020}. The main theorem characterizes compact widgets.
```

**Why?** Git tracks changes line by line.
If you edit one word in a paragraph-long line, Git marks the entire paragraph as changed, making code review and conflict resolution extremely difficult.

### Line Width: 100 Columns

Prose lines must not exceed **100 columns**.
The `texwrap.py` script automatically wraps at semantic boundaries (sentence end, semicolon, colon, comma).

```bash
make check PROJECT=monograph   # Dry-run: report lines > 100 columns
make wrap  PROJECT=monograph   # Auto-wrap lines
```

### Indentation: 2 Spaces

- Use **2 spaces** per nesting level inside `\begin{…}…\end{…}` blocks.
- **No tabs.**
- Display-math environments (`equation`, `align`, etc.) receive **no** additional indentation — their bodies are `&`-aligned tables.

```bash
make indent PROJECT=monograph  # Auto-indent via latexindent
make format PROJECT=monograph  # Full pass: wrap + indent
```

### Banned Patterns

| Pattern | Use Instead |
|---------|-------------|
| `$$ ... $$` | `\begin{equation*}...\end{equation*}` or `\[...\]` |
| `\begin{eqnarray}` | `\begin{align}` or `\begin{align*}` |
| `\\` for paragraph breaks | A blank line |
| `\ref{...}` (bare) | `\cref{...}` (from cleveref) |

### Math Environments

| Purpose | Environment |
|---------|-------------|
| Inline math | `$ ... $` or `\( ... \)` |
| Display (unnumbered) | `equation*` or `\[ ... \]` |
| Display (numbered) | `equation` |
| Multi-line (numbered) | `align` |
| Multi-line (unnumbered) | `align*` |

### Label Conventions

Use semantic label prefixes:

| Prefix | For |
|--------|-----|
| `cha:` | `\chapter` |
| `sec:` | `\section`, `\subsection` |
| `thm:` | `theorem` |
| `lem:` | `lemma` |
| `prop:` | `proposition` |
| `cor:` | `corollary` |
| `def:` | `definition` |
| `exa:` | `example` |
| `rem:` | `remark` |
| `notn:` | `notation` |
| `eq:` | equations, align, etc. |
| `fig:` | `figure` |
| `conj:` | `conjecture` |

Example: `\label{thm:main-result}`, then reference with `\cref{thm:main-result}`.

### Semantic Commands

Define macros for repeated notation in the preamble rather than repeating raw LaTeX:

```latex
\newcommand{\RR}{\mathbb{R}}    % then use \RR in text
\DeclarePairedDelimiter{\norm}{\lVert}{\rVert}
```

### Cross-Referencing

- Use `\cref{...}` (cleveref) — it auto-generates "Theorem 2.1", "Section 3", etc.
- Use `\Cref{...}` at the start of a sentence.
- Never hardcode "Theorem \ref{...}".

### Collaboration Tools

The templates include the `todonotes` package:
```latex
\todo{Fix this argument}
\todo[inline]{This section needs rewriting}
```

## Git Workflow

### The Mantra: Pull → Commit → Push

1. **Pull first**: `git pull` before you start writing (then `git submodule update --init --recursive`).
2. **Commit often**: Make small, focused commits with descriptive messages.
3. **Push last**: `git push` when done so others can see your work.

### Commit Messages

Write clear, specific messages:
```
✓  Add proof of Lemma 3.2
✓  Fix typo in Definition 2.1
✗  fixed stuff
✗  updates
```

### What NOT to Commit

The `.gitignore` excludes all build artifacts.
**Never commit** `.aux`, `.log`, `.pdf`, `.bbl`, `.synctex.gz`, or any file in `build/`.

### Pre-commit Hook

A git pre-commit hook is installed automatically (by the Codespace `postCreateCommand` or by running `make install-hooks`).
It checks staged `.tex` files for:

1. Lines exceeding 100 columns
2. Trailing whitespace
3. `$$` display math
4. `\eqnarray` usage

If any check fails, the commit is aborted with an explanation of what to fix.

## Codespace Configuration

The `.devcontainer/` directory configures a GitHub Codespace with:

- **Full TeX Live** distribution (pdfLaTeX, BibTeX, Biber, latexmk, chktex, latexindent, texcount)
- **VS Code extensions**: LaTeX Workshop, GitLens, Copilot, trailing-spaces, rewrap, spell checker
- **Auto-build on save** via LaTeX Workshop
- **PDF preview** in a VS Code tab
- **Linting** via chktex (runs on every keystroke)

> **Note:** the Codespace clones submodules automatically; for a manual clone run
> `git submodule update --init --recursive` once.

## CI Pipeline

Every push and pull request to `main` triggers a GitHub Actions workflow that:

1. **Lints** all `.tex` files with chktex
2. **Checks** line width (100 columns) with texwrap.py
3. **Checks** for banned patterns (`$$`, `\eqnarray`)
4. **Builds** both PDFs (monograph and article)
5. **Uploads** compiled PDFs as workflow artifacts

Both jobs check out the `sty/` and `bib/` submodules via `with: submodules: recursive`.

## Adding Chapters (Monograph)

1. Create a new file in `monograph/`, e.g., `ch-new-topic.tex`
2. Add `\include{ch-new-topic}` to `monograph-template.tex`
3. To compile only specific chapters, edit the `\includeonly{...}` line

## License

This project is licensed under the [Creative Commons Attribution 4.0 International Public License (CC BY 4.0)](LICENSE).
