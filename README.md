# LaTeX Codespace Template

A batteries-included template for collaborative LaTeX writing, designed to be
used as a [GitHub template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository).
**One repository hosts many papers**: every manuscript (research article,
monograph, survey, textbook, …) lives in its own subdirectory, and all papers
share one set of vendored style files, one bibliography, and one toolchain —
plus a fully configured Codespace for cloud editing in VS Code.

- **Engine:** pdfLaTeX + [STIX Two](https://ctan.org/pkg/stix2) fonts (text + math), via `latexmk`.
- **Layout:** one subdirectory per paper; shared infrastructure in directories whose names start with `_`.
- **Preamble:** each paper's main `.tex` carries only `\documentclass`, one
  `\usepackage{<paper>}`, and semantic metadata; every `\usepackage`, macro, and
  `\newtheorem` lives in the paper's style file `<paper>.sty`, which loads the
  shared packages **vendored** in `_packages/`.
- **Bibliography:** BibTeX, style `alpha`, from **one shared** root `references.bib`.
- **No submodules, no symlinks needed:** everything builds from a plain clone (including
  on Windows); the only symlink, `CLAUDE.md` → `AGENTS.md`, is optional. Shared files are reached by relative path (`../`).
- **Checks:** advisory — they guide, they don't block (see below).

## Repository layout

```
.
├── references.bib            # THE shared bibliography (vendored-but-editable)
├── latexmkrc                 # shared latexmk configuration (non-hidden)
├── Makefile                  # build / format / lint for all papers
├── AGENTS.md                 # instructions for AI assistants (CLAUDE.md is a symlink to it)
├── ONBOARDING.md             # guided tour + cheat sheet of the house practices
├── STYLE.md                  # writing conventions
├── _packages/                # vendored shared style files — NEVER edit (see below)
├── _scripts/                 # new-paper.sh, export-paper.sh, texwrap.py, hooks, …
├── _templates/               # skeletons copied by `make new`
│   ├── article/              #   amsart research article
│   └── monograph/            #   memoir book with chapters
├── example-article/          # a paper (one directory per manuscript)
│   ├── example-article.tex   #   main file: \documentclass + \usepackage{example-article} + metadata
│   ├── example-article.sty   #   ALL packages/macros for this paper; loads ../_packages/di-*.sty
│   ├── latexmkrc             #   two lines: build this file; load ../latexmkrc
│   └── figures/, data/, …    #   anything else belonging to this paper
├── another-paper/            # another paper, same shape
├── .vscode/  .devcontainer/  .github/workflows/
└── latexindent.yaml  .chktexrc  …
```

Rules of the road:

- **A paper is a subdirectory** (name without a leading `_` or `.`) containing a
  main `.tex` with `\documentclass`. Name the main file after the directory
  (`my-paper/my-paper.tex`). Monograph chapters are `my-paper/my-paper-N-topic.tex`.
- **Directories starting with `_` are shared infrastructure**, never papers.
- **Each paper owns its `.sty`** for its own macros. **Shared code** lives in `_packages/`
  and is **never edited here**; **shared references** live in the root `references.bib`
  and are **never copied or forked** per paper.

## Quick start

1. Click **"Use this template"** on GitHub to create your repository.
2. Open it in a **GitHub Codespace** (recommended, especially on Windows) or
   clone locally — see [Local setup](#local-setup-macos-and-ubuntu).
3. Create a paper (in the Codespace terminal, macOS/Linux, or Git Bash):
   ```bash
   make new P=my-paper TYPE=article        # or TYPE=monograph
   ```
   *Without `make`/bash (e.g. plain Windows):* copy the folder `_templates/article/`
   to a new folder `my-paper/` at the repo root, then rename every file
   `PAPER*.tex`/`PAPER.sty` to `my-paper*`, and replace the word `PAPER` by `my-paper`
   inside them (find-and-replace in VS Code). Also create `my-paper/latexmkrc`
   containing the two lines
   `@default_files = ('my-paper.tex');` and `do '../latexmkrc';`, and `my-paper/Makefile`
   containing the one line `include ../_scripts/paper.mk` (optional: only for `make`).
4. Edit `my-paper/my-paper.tex` and `my-paper/my-paper.sty`. Saving a `.tex` in VS Code builds it.

## Building a paper

Four equivalent ways; the PDF appears next to the source and intermediate files
go to `my-paper/_build/` (both gitignored).

```bash
cd my-paper && make        # the usual way: work inside the paper's directory (make help lists the targets)
cd my-paper && latexmk     # the same without make
make my-paper              # from the repo root, if you prefer
make build-all FORCE=1     # every paper (slow, rarely needed, deliberately guarded)
# VS Code: just save the .tex file (LaTeX Workshop builds on save)
```

The **traditional manual workflow also works** — each paper's main file tells
LaTeX where the shared files are (`../_packages/` and `../references`), so no
configuration, environment variables, or symlinks are needed:

```bash
cd my-paper
pdflatex my-paper && bibtex my-paper && pdflatex my-paper && pdflatex my-paper
```

(Here the auxiliary files land beside the source instead of in `_build/`; they are gitignored.)

### Sending a paper out (arXiv, journal, standalone repo)

```bash
make export P=my-paper     # writes _export/my-paper/
```

produces a **self-contained folder**: the paper's sources, only the `di-*.sty` files it
uses, and `references.bib`, with the `../` paths rewritten. Build it with plain
`pdflatex`/`bibtex` anywhere.

## Shared resources

### Vendored style files: `_packages/`

The `di-*` files are **shared** style files, *vendored* into `_packages/`:
pristine, byte-for-byte copies of the originals in the
[`LaTeX-shared-files`](https://github.com/eduenez/LaTeX-shared-files) repo, each
pinned to a commit hash in [`_packages/vendor.lock`](_packages/vendor.lock) and
mirrored in a `%%% Vendored: repo/file @hash` comment above its `\usepackage`.
This is a **"poor man's submodule"**: clone and build immediately, with no
`git submodule` steps. **Never edit the files in `_packages/`** (see
[`_packages/_DO_NOT_EDIT_FILES_IN_THIS_DIRECTORY.md`](_packages/_DO_NOT_EDIT_FILES_IN_THIS_DIRECTORY.md));
change shared code upstream in `LaTeX-shared-files` and re-vendor. A paper's `.sty` loads
what it needs with a plain `\usepackage{di-base-article}` (the main `.tex` sets
`\input@path` to `../_packages/`; latexmk also adds it to `TEXINPUTS`).
Paper-specific macros go in the paper's own `.sty`, never in `_packages/`.

The shared base is split into `di-base-core` (class-agnostic: fonts, package loads,
hyperref/cleveref, theorems), `di-base-article` (amsart) and `di-base-monograph`
(memoir); both bases `\RequirePackage{di-base-core}`. `di-structures`, `di-ramsey`,
`di-random`, `di-exercises` are optional topical packages (commented out in the templates).

### Shared bibliography: `references.bib`

One file at the repo root serves every paper (`\bibliography{../references}`).
See [Bibliography workflow](#bibliography-workflow).

### Moving an existing one-off repository into this one

1. `make new P=<name> TYPE=article` (or `monograph`), then paste the old paper's
   body into the new `.tex`; move figures/scripts into `<name>/`.
2. Put the paper's own macros in `<name>/<name>.sty`; drop any `\usepackage` lines
   already provided by `di-base-*`.
3. **Merge its `.bib` entries into the root `references.bib`** (reuse an existing
   entry when the work is already there; keys are `Author-Author:YYYY`).
   If the references were typed inline in a `thebibliography`, convert each
   `\bibitem` into a BibTeX entry and replace the block with
   `\bibliographystyle{alpha}\bibliography{../references}`.
4. Build, fix undefined citations, then retire the old repository.

## Setup check and onboarding

```bash
make doctor        # read-only check of tools, Git identity, hooks; says how to fix what is missing
```

New to the repository (or to Git/LaTeX)? [`ONBOARDING.md`](ONBOARDING.md) is a 10-minute guided tour and a
cheat sheet "old habit → house way". It is meant to be walked through interactively with an AI assistant.

## Keeping the shared files in sync

`_packages/` and `references.bib` are vendored copies of upstream repositories (`LaTeX-shared-files`, `math-bibliography`).
Three commands keep them honest: `make vendor-check` (are the packages pristine? checksums are pinned in `_packages/vendor.lock`),
`make bib-diff` (which entries did we add or *edit* relative to the upstream master? additions are welcome, edits of existing
entries belong upstream) and `make update-shared` (what changed upstream; `python3 _scripts/update_shared.py --apply` refreshes the
files, keeps your local-only bibliography entries, and re-stamps the checksums). `make doctor` runs the vendor check too.

## Bringing in an existing repository or document

[`CONVERTING.md`](CONVERTING.md) is the playbook for importing an outside manuscript — with its commit history — as a paper
directory and converting it to the house conventions (tools in `_scripts/migrate/`), and for retiring the old repository.

## Working with AI assistants (Copilot, Claude Code, …)

[`AGENTS.md`](AGENTS.md) holds the instructions every assistant follows (`CLAUDE.md` is a symlink to it for tools that
look for that name; `.github/copilot-instructions.md` points Copilot to it). Besides doing the task, assistants are asked to
**coach**: explain the house practice behind each correction in a sentence, offer the onboarding tour once per clone,
and help install or configure tools (`make`, TeX Live, hooks). If you would rather not be coached, tell the assistant.

## Local setup (macOS and Ubuntu)

The Codespace / Dev Container ([.devcontainer/Dockerfile](.devcontainer/Dockerfile))
already has all of this installed. If you're cloning locally instead, you need:

- A **TeX Live** distribution providing `pdflatex`, `latexmk`, `bibtex`,
  `chktex`, and `latexindent`, plus the **STIX Two** fonts (`stix2` package).
- **Perl modules** for `latexindent`: `Log::Log4perl`, `Log::Dispatch::File`,
  `YAML::Tiny`, `File::HomeDir`, `Unicode::GCString`.
- **Python 3** (stdlib only — no packages to install) for the `make
  wrap`/`fashion`/`sep`/`check` scripts in [`_scripts/`](_scripts/).
- **`make`** and **`git`**.

### macOS (Homebrew)

```bash
# Full TeX Live (a few GB; includes latexmk, chktex, latexindent, STIX Two).
# mactex-no-gui skips the GUI front-ends (TeXShop, etc.) — add --cask mactex
# instead if you want those too.
brew install --cask mactex-no-gui

# make and python3 usually already exist via the Xcode Command Line Tools
# (xcode-select --install); this covers a bare Homebrew setup too.
brew install make python3 cpanminus

# Perl modules latexindent needs.
cpanm --notest Log::Log4perl Log::Dispatch::File YAML::Tiny File::HomeDir Unicode::GCString
```

MacTeX installs its binaries to `/Library/TeX/texbin` and adds that to your
`PATH` via `/etc/paths.d` — open a **new terminal tab** afterwards so it takes
effect.

### Ubuntu / Debian

```bash
sudo apt-get update
# texlive-full guarantees chktex, latexindent, and the STIX Two fonts are all
# present; if you'd rather avoid the ~5 GB download, texlive-latex-extra +
# texlive-fonts-extra + texlive-bibtex-extra + chktex + latexmk covers this
# template, but texlive-full is the safest default.
sudo apt-get install -y texlive-full git fontconfig make python3 python3-pip cpanminus

sudo cpanm --notest Log::Log4perl Log::Dispatch::File YAML::Tiny File::HomeDir Unicode::GCString
sudo fc-cache -fv
```

### Verify

```bash
latexmk -v && chktex --version && latexindent --version && python3 --version && make --version
```

Then, from the repo root:

```bash
make install-hooks   # advisory pre-commit hook (see below)
make build-all FORCE=1   # compile every paper end to end (optional; slow)
```

## Editor setup (VS Code)

Opening the repo folder in VS Code (Codespace **or** a local clone) prompts you
to install the recommended extensions from
[`.vscode/extensions.json`](.vscode/extensions.json) — accept the prompt, or
install them yourself:

```bash
code --install-extension james-yu.latex-workshop
code --install-extension tecosaur.latex-utilities
code --install-extension eamodio.gitlens
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat
code --install-extension GitHub.vscode-pull-request-github
code --install-extension shardulm94.trailing-spaces
code --install-extension stkb.rewrap
code --install-extension streetsidesoftware.code-spell-checker
code --install-extension yzhang.markdown-all-in-one
code --install-extension redhat.vscode-yaml
```

[`.vscode/settings.json`](.vscode/settings.json) then wires up
[LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop)
to this template's toolchain — no per-user configuration needed:

- **Soft-wrap of long lines** is **always on** for `.tex`, `.bib`, and Markdown —
  you never need to scroll sideways. (Only personal preferences — theme,
  font size, keybindings — are left to you; they are not part of this repo.)
- **Build on save**, via `latexmk` and the shared `latexmkrc` (works for any
  paper, including chapter files; PDF beside the source, intermediates in `_build/`).
- **PDF preview** opens in an editor tab with SyncTeX (click in the PDF to
  jump to source, and back).
- **`chktex` linting** as you type, and **`latexindent`** (via
  `latexindent.yaml`) as the `[latex]` format-on-save formatter.
- **Word count** (`texcount`, from the `latex-utilities` extension) and a
  **spell checker** scoped to `latex`/`bibtex` files.

Only `latexmk`, `chktex`, `latexindent`, and `texcount` need to be on your
`PATH` for these to work — see [Local setup](#local-setup-macos-and-ubuntu)
above.

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
`_packages/`), is shared by **all** papers (never copy it into a paper directory,
so entries cannot diverge between papers), and is **vendored-but-editable**: it is a synced snapshot of the
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
2. **Add entries directly** to the root `references.bib` when you cite something not yet present. Keys follow
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
  only `$$`/`\eqnarray` are hard-gated. The build job runs `make build-all FORCE=1`, compiling every
  paper (auto-discovered) and uploads the PDFs as artifacts.

## Adding chapters (monograph)

Chapter files are named `<paper>-N-<topic>.tex` and live beside the main file inside
the paper's directory (the monograph template ships four).

1. Create `my-book/my-book-5-new-topic.tex`.
2. Add `\include{my-book-5-new-topic}` to `my-book/my-book.tex`.
3. Optionally restrict compilation with `\includeonly{...}`.

## License

Licensed under [CC BY 4.0](LICENSE).
