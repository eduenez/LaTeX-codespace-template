# LaTeX Codespace Template

A batteries-included template for collaborative LaTeX writing, designed to be
used as a [GitHub template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository).
It ships **two starting points at the repo root** — a **monograph**
(`memoir` class, with chapters) and a **research article** (`amsart` class) —
plus a fully configured Codespace for cloud editing in VS Code.

- **Engine:** pdfLaTeX + [STIX Two](https://ctan.org/pkg/stix2) fonts (text + math), via `latexmk`.
- **Bibliography:** BibTeX (a single `references.bib`), style `alpha`.
- **Checks:** advisory — they guide, they don't block (see below).

## Quick start

1. Click **"Use this template"** on GitHub to create your repository.
2. Open it in a **GitHub Codespace** (or clone locally).
3. Pick one starting point and delete the other:
   - keeping the **article**: delete `monograph-template.tex` and `ch-*.tex`;
   - keeping the **monograph**: delete `article-template.tex`.
4. Rename the one you kept (e.g. `git mv article-template.tex myproject.tex`)
   and start writing. Build with `make build`.

Both main files coexist at the root until you delete one — nothing is buried in
a subdirectory.

## Repository structure

```
.
├── .chktexrc                 # chktex linter configuration
├── .devcontainer/            # Codespace / Dev Container (TeX Live + VS Code)
├── .github/workflows/
│   └── lint-and-build.yml    # CI: advisory lint + build PDFs
├── .gitignore
├── .latexmkrc                # pdfLaTeX; aux → build/, PDF → repo root
├── .vscode/settings.json
├── article-template.tex      # research-article starting point (amsart)
├── monograph-template.tex    # monograph starting point (memoir)
├── ch-introduction.tex       # monograph chapters (\include'd)
├── ch-background.tex
├── ch-main-results.tex
├── ch-conclusion.tex
├── references.bib            # the single bibliography (BibTeX)
├── latexindent.yaml
├── Makefile
├── scripts/
│   ├── setup-hooks.sh        # installs the advisory pre-commit hook
│   └── texwrap.py            # semantic line-wrapper
├── STYLE.md                  # writing conventions
└── README.md
```

## Building

pdfLaTeX via `latexmk`. Intermediates (`.aux`, `.log`, `.bbl`, …) go to `build/`;
the finished **PDF lands at the repo root** next to the source. Both are
gitignored.

```bash
make build                 # build every "main" .tex (one with \documentclass)
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

## Checks are advisory (they won't block you)

This template deliberately does **not** block collaborators on formatting:

- **Pre-commit hook** — prints reminders (wrapping, trailing whitespace,
  `$$`/`\eqnarray`) then **always lets the commit through**. It's installed to
  your clone's `.git/hooks/` by the Codespace `postCreateCommand`, or manually:
  ```bash
  make install-hooks     # (= bash scripts/setup-hooks.sh)
  ```
  The hook lives in `.git/hooks/` and is **not** updated by `git pull` — re-run
  the command above to refresh it.
- **CI** ([lint-and-build.yml](.github/workflows/lint-and-build.yml)) — on push/PR
  to `main`: line-width and `chktex` checks are advisory (`continue-on-error`);
  only `$$`/`\eqnarray` are hard-gated. The build job compiles every main
  document (auto-discovered) and uploads the PDFs as artifacts.

## Adding chapters (monograph)

1. Create `ch-new-topic.tex` at the root.
2. Add `\include{ch-new-topic}` to your main `.tex`.
3. Optionally restrict compilation with `\includeonly{...}`.

## License

Licensed under [CC BY 4.0](LICENSE).
