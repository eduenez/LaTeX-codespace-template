# LaTeX Codespace Template

A batteries-included template for collaborative LaTeX writing, designed to be
used as a [GitHub template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository).
It ships **two starting points at the repo root** — a **monograph**
(`memoir` class, with chapters) and a **research article** (`amsart` class) —
plus a fully configured Codespace for cloud editing in VS Code.

- **Engine:** pdfLaTeX + [STIX Two](https://ctan.org/pkg/stix2) fonts (text + math), via `latexmk`.
- **Preamble:** each master `.tex` carries only `\documentclass`, one
  `\usepackage{<master>}`, and semantic metadata (title/author/date/…); every
  `\usepackage`, macro, and `\newtheorem` lives in that project style file
  `<master>.sty`, which loads the shared packages **vendored** in `_packages/`.
- **Bibliography:** BibTeX (a single root `references.bib`), style `alpha` —
  vendored-but-editable (see below).
- **Checks:** advisory — they guide, they don't block (see below).

## The master / `.sty` split and the vendored `_packages/`

Each starting point is a **pair**: a master `.tex` and a project style file
`<master>.sty` beside it. The master `.tex` holds only `\documentclass`, a single
`\usepackage{<master>}`, and the semantic metadata; **all** packages, macros, and
theorem/environment definitions live in `<master>.sty`. The two masters each have
their own: `article-template.tex` → `article-template.sty` (loads
`di-base-article`) and `monograph-template.tex` → `monograph-template.sty`
(loads `di-base-monograph`).

Those `di-*` files are **shared** style files that are *vendored* into
`_packages/`: pristine, byte-for-byte copies of the originals in the
[`LaTeX-shared-files`](https://github.com/eduenez/LaTeX-shared-files) repo, each
pinned to a commit hash in [`_packages/vendor.lock`](_packages/vendor.lock) and
mirrored in a `%%% Vendored: repo/file @hash` comment above its `\usepackage`.
This is a **"poor man's submodule"**: clone and build immediately, with no
`git submodule` steps. The rule (spelled out in
[`_packages/_DO_NOT_EDIT_FILES_IN_THIS_DIRECTORY.md`](_packages/_DO_NOT_EDIT_FILES_IN_THIS_DIRECTORY.md))
is **never edit the files in `_packages/`** — change shared code upstream in
`LaTeX-shared-files` and re-vendor. `_packages/` is on `TEXINPUTS` (via
`.latexmkrc`), so the loads are plain `\usepackage{di-base-article}` with no path
prefix. Files vendored but unused are kept with their `\usepackage` commented out,
ready to activate.

The shared base is split into `di-base-core` (class-agnostic: engine-aware fonts,
package loads, hyperref/cleveref, the theorem-environment family), plus
`di-base-article` (amsart, section-scoped numbering) and `di-base-monograph`
(memoir, chapter-scoped numbering + `axiom`); both class bases
`\RequirePackage{di-base-core}` internally. `di-structures` carries shared
real-valued-logic notation.

## Quick start

1. Click **"Use this template"** on GitHub to create your repository.
2. Open it in a **GitHub Codespace** (or clone locally).
3. Pick one starting point and delete the other (each master comes with its own
   `.sty`):
   - keeping the **article**: delete `monograph-template.tex`,
     `monograph-template.sty`, and the `monograph-template-*.tex` chapters;
   - keeping the **monograph**: delete `article-template.tex` and
     `article-template.sty`.
4. Rename the one you kept — the master **and** its `.sty` together — and point
   the master's `\usepackage` at the new name (e.g.
   `git mv article-template.tex myproject.tex`,
   `git mv article-template.sty myproject.sty`, then change
   `\usepackage{article-template}` to `\usepackage{myproject}`). Start writing;
   build with `make article`.

Both masters (and their `.sty` files) coexist at the root until you delete one —
nothing is buried in a subdirectory. The vendored shared packages sit in
`_packages/`; leave them as they are.

## Repository structure

```
.
├── .chktexrc                 # chktex linter configuration
├── .devcontainer/            # Codespace / Dev Container (TeX Live + VS Code)
├── .github/workflows/
│   └── lint-and-build.yml    # CI: advisory lint + build PDFs
├── .gitignore
├── .latexmkrc                # pdfLaTeX; aux → _build/, PDF → repo root; _packages/ on TEXINPUTS
├── .vscode/settings.json
├── article-template.tex      # research-article master (amsart): \documentclass + metadata only
├── article-template.sty      #   its style file: loads di-base-article + project additions
├── monograph-template.tex    # monograph master (memoir): \documentclass + metadata only
├── monograph-template.sty    #   its style file: loads di-base-monograph + project additions
├── monograph-template-1-introduction.tex   # monograph chapters (\include'd)
├── monograph-template-2-background.tex
├── monograph-template-3-main-results.tex
├── monograph-template-4-conclusion.tex
├── _packages/                 # vendored shared style files ("poor man's submodule")
│   ├── _DO_NOT_EDIT_FILES_IN_THIS_DIRECTORY.md   # the never-edit rule
│   ├── vendor.lock           # provenance pins: <file> <upstream repo> <commit>
│   ├── di-base-core.sty      # class-agnostic core (fonts, packages, cleveref, theorems)
│   ├── di-base-article.sty   # amsart base (section-scoped numbering)
│   ├── di-base-monograph.sty # memoir base (chapter-scoped numbering + axiom)
│   └── di-structures.sty     # shared real-valued-logic notation (+ di-ramsey/random/exercises)
├── references.bib            # the single bibliography (BibTeX), vendored-but-editable
├── latexindent.yaml
├── Makefile
├── _scripts/
│   ├── setup-hooks.sh        # installs the advisory pre-commit hook
│   └── texwrap.py            # semantic line-wrapper
├── STYLE.md                  # writing conventions
└── README.md
```

## Building

pdfLaTeX via `latexmk`. Intermediates (`.aux`, `.log`, `.bbl`, …) go to `_build/`;
the finished **PDF lands at the repo root** next to the source. Both are
gitignored.

```bash
make article                 # build every "main" .tex (one with \documentclass)
latexmk article-template   # or build a single document directly
```

In VS Code / Codespace, saving a `.tex` triggers an automatic build.

## Conventions (see [STYLE.md](STYLE.md))

The short version: **one sentence per source line**, 2-space indentation, `\cref`
for references, BibTeX `\cite`, and no `$$`/`\eqnarray`. Full details and the
rationale are in [STYLE.md](STYLE.md). Normalize formatting with:

```bash
make wrap      # semantic line-wrapping
make format    # wrap + latexindent
make check     # dry-run: what isn't wrapped
```

## Bibliography workflow

[`references.bib`](references.bib) lives at the repo **root** (not in
`_packages/`) and is **vendored-but-editable**: it is a synced snapshot of the
group's master database,
[`math-bibliography`](https://github.com/eduenez/math-bibliography), pinned in
[`_packages/vendor.lock`](_packages/vendor.lock) to record the last sync point. The
master is the **canonical source of truth**: it is kept tidied (`bibtex-tidy`) and
**sorted case-insensitively by key**, so any copy taken from it is already clean
and sorted.

Unlike the `.sty` files in `_packages/`, this one file you **may edit** —
collaborators add citations to it directly; the maintainer periodically
reconciles those additions back into the master. The workflow:

1. **Cite** with `\cite{key}` — BibTeX emits only the works you actually cite,
   so a large `references.bib` does not bloat the compiled bibliography.
2. **Add entries directly** when you cite something not yet present. Keys follow
   `Author-Author:YYYY` (e.g. `MacLane-Moerdijk:1992`).
3. **Re-sync periodically.** The maintainer re-syncs `references.bib` from the
   master (bumping the pin in `vendor.lock`) to pick up upstream additions and
   the canonical ordering, backporting local additions along the way.

This deliberately trades the automatic propagation of a git submodule for
**zero submodule friction** — collaborators clone and build with no
`git submodule` steps, and no exposure to biblatex/biber. The cost is the manual
re-sync in step 3.

> BibTeX has no comment syntax and treats a bare `@` as the start of an entry —
> keep bare at-signs out of `references.bib` header comments.

## Checks are advisory (they won't block you)

This template deliberately does **not** block collaborators on formatting:

- **Pre-commit hook** — prints reminders (wrapping, trailing whitespace,
  `$$`/`\eqnarray`) then **always lets the commit through**. It's installed to
  your clone's `.git/hooks/` by the Codespace `postCreateCommand`, or manually:
  ```bash
  make install-hooks     # (= bash _scripts/setup-hooks.sh)
  ```
  The hook lives in `.git/hooks/` and is **not** updated by `git pull` — re-run
  the command above to refresh it.
- **CI** ([lint-and-build.yml](.github/workflows/lint-and-build.yml)) — on push/PR
  to `main`: line-width and `chktex` checks are advisory (`continue-on-error`);
  only `$$`/`\eqnarray` are hard-gated. The build job compiles every main
  document (auto-discovered) and uploads the PDFs as artifacts.

## Adding chapters (monograph)

Chapter files are named `<master>-N-<topic>.tex` and live beside the master (the
template ships `monograph-template-1-introduction.tex` through
`monograph-template-4-conclusion.tex`).

1. Create `monograph-template-5-new-topic.tex` at the root (use your master's
   name and the next number once you have renamed the master).
2. Add `\include{monograph-template-5-new-topic}` to your master `.tex`.
3. Optionally restrict compilation with `\includeonly{...}`.

## License

Licensed under [CC BY 4.0](LICENSE).
