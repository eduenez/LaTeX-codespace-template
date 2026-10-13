# AGENTS.md — instructions for AI coding assistants

These instructions are for **any** assistant working in this repository (GitHub Copilot, Claude Code, Codex,
Cursor, …). They are tool-neutral. Humans: read `README.md` (setup, workflow), `STYLE.md` (writing
conventions) and `ONBOARDING.md` (a short guided tour of the house practices).

This repository hosts **many LaTeX manuscripts, one per subdirectory**, sharing vendored style files,
one bibliography, and one toolchain. Your job is twofold: **do the task you were asked to do within the
house conventions, and help the person you are working with adopt those conventions** (see
[Coaching protocol](#coaching-protocol) — it is part of the job, not an extra).

## 0. At the start of a session

1. Run `make doctor` (read-only; checks tools, Git identity, hooks). If something is missing, follow the
   coaching protocol's *tool setup* step before doing anything else that needs it.
2. Run `git status` and `git log --oneline -5` so you know what state the work is in.
3. Check whether this clone has been onboarded: `cat .git/agent-onboarding 2>/dev/null` (a per-clone,
   untracked note; see below). If it does not exist, make the one-time offer described in the protocol.

## 1. Layout

- `<paper>/` — one directory per manuscript (directory names never start with `_` or `.`). It contains
  `<paper>.tex` (main file: `\documentclass`, `\usepackage{<paper>}`, metadata only), `<paper>.sty` (ALL
  packages, macros and theorem environments of that paper), chapter files (books), a two-line `latexmkrc`
  (builds the main file, loads `../latexmkrc`), and the paper's figures, data and scripts.
  Existing directories use the pattern `book_<topic>/<topic>_book.tex` for books.
- `references.bib` — the ONE shared bibliography at the repo root (a snapshot of the group's master
  `math-bibliography`; vendored-but-editable).
- `_packages/` — vendored shared packages (`di-*.sty`) and `vendor.lock`. **Never edit these files.**
  Change shared code upstream (`LaTeX-shared-files`) and re-vendor.
- `_templates/{article,monograph}/` — skeletons used by `make new` (placeholder name `PAPER`).
- `_scripts/` — `new-paper.sh`, `export-paper.sh`, `doctor.sh`, `texwrap.py`, `texfashion.py`, `texsep.py`,
  `setup-hooks.sh`, and `migrate/` (tools for importing and converting external repositories: see `CONVERTING.md`). `latexmkrc` (root, non-hidden) and `Makefile` are the shared entry points.
- Directories starting with `_` are infrastructure, not papers. There are **no submodules** (students on
  Windows and Git beginners use this repository); symlinks are not used for LaTeX files.

## 2. Commands (run from the repository root)

| Command | What it does |
|---|---|
| `make doctor` | check tools and setup; prints how to fix what is missing |
| `make new P=<name> TYPE=article\|monograph` | create a paper from a template |
| `make <paper>` / `make build` | build one paper / all papers (PDF next to the source, aux files in `_build/`) |
| `make format [P=<paper>]` | typography + semantic line wrapping + indentation (idempotent) |
| `make check [P=<paper>]` | dry run: report what `make format` would change |
| `make lint [P=<paper>]` | chktex |
| `make export P=<paper>` | self-contained copy in `_export/<paper>/` (arXiv, submission) |
| `make install-hooks` | install the advisory pre-commit hook |

Equivalent without `make`: `cd <paper> && latexmk`, or the manual
`pdflatex <paper>; bibtex <paper>; pdflatex <paper>; pdflatex <paper>` (works without any configuration).
Never run `latexmk` at the repository root. Built PDFs and `_build/` are git-ignored: never commit them.

## 3. Rules for editing

1. **Stay in the paper you were asked about.** Shared infrastructure (`latexmkrc`, `Makefile`, `_scripts/`,
   `.vscode/`, CI, templates) affects every paper: change it only when asked, keep it backward compatible,
   and verify with `make build`.
2. **Preamble discipline.** No `\usepackage`, `\newcommand`, `\newtheorem` in the main `.tex`; they go in
   `<paper>.sty` ("Project-specific additions"). Keep the `\makeatletter\def\input@path{{../_packages/}{_packages/}}\makeatother`
   line and `\bibliography{../references}` intact (the export script rewrites them).
3. **Macros and notation** (see `STYLE.md` §9). One macro per symbol, shared names: `\NN \ZZ \QQ \RR \CC` (blackboard),
   `\cA` (calligraphic), `\fA` (fraktur), `\scrA` (script). Never define another macro for the same symbol; never
   redefine these (`\RR` is `\mathbb{R}`; use `\cR` for `\mathcal{R}`). Do not write `\mathbb{R}` or `\mathcal X`
   literally where a shared name exists. A modifier takes a braced argument: `\mathcal{X}`, `\tilde{X}`
   (`\tilde\alpha` is tolerated). Trace is `\Tr`, tree is `\tr`. Before adding a macro, look in `_packages/` and in the
   paper's `.sty`; if the notation is generic, propose adding it to `LaTeX-shared-files` instead of defining it locally.
4. **Cross references.** Labels use the prefixes of `STYLE.md` §7 with kebab-case slugs (`thm:main-result`); refer to them
   with `\cref{...}` (list: `\cref{a,b}`), never `Theorem~\ref{...}`. Shared-counter theorem environments must be declared
   with `\DiSharedTheorem` (see `di-theorem-rudin`) so that `\cref` prints the right name.
5. **Bibliography.** Add entries only to the root `references.bib` (never a per-paper `.bib`, never an inline
   `thebibliography`); reuse an existing entry if the work is already there. Keys: `Author-Author:YYYY` (lower-case
   suffix `a`, `b`, … for same author-year; `:0000` if undated); a hyphen only separates authors, never appears inside a
   surname (`BenYaacov`, `NashWilliams`, `vonNeumann`). Brace accents and capitals that must survive BibTeX
   (`{\'a}`, `{\"U}ber`, `{B}anach`). Style `amsalpha`. Keep bare at-signs out of header comments.
6. **Source style.** One sentence or clause per source line, two-space indentation, modern Unicode text (except in
   `\title`/`\author`), no `$$`, no `eqnarray`; run `make format` rather than formatting by hand. Do not hard-wrap
   prose at a column: the editor soft-wraps (configured in `.vscode/settings.json`).
7. **Personal editor preferences** (theme, font size, keybindings) do not belong in `.vscode/`.
8. **After editing**, build the paper and fix undefined references and citations before you finish.
9. **Git.** Small, specific commits ("Add proof of Lemma 3.2"). Pull before you start, push when asked. Do not rewrite
   history, force-push, delete branches or files someone else owns, or commit generated files, unless explicitly asked.
   Ask before bulk or cross-paper changes (renames, reformatting whole files).

## Converting an external repository or document into a paper directory

If you are asked to bring an outside manuscript into this repository — a one-off repository, a loose `.tex`, an Overleaf
export, a co-author's repository that follows none of these conventions — **follow `CONVERTING.md` step by step**. In outline:

1. **Propose, don't interrogate.** Work out a complete house-style proposal yourself — new directory and file names
   (`python3 _scripts/migrate/propose_names.py`; e.g. `Everything/Everything.tex` → `book_everything/everything_book.tex`), target
   repository, the printed-output policy (the paper keeps its own look; only bibliography formatting, unified symbols and approved
   typo fixes may change the print) — and present it as one table: *"I will use these unless you change something."* Users
   should not have to know the conventions; every decision is an **overridable default**. Ask open questions only where no
   sensible default exists.
2. **Inventory** the source read-only; build it as it is and keep that PDF as the *baseline* (record pre-existing errors).
3. **Import with history**: `python3 _scripts/migrate/import_repo.py <source> --dir <name> --rename old:new`
   (never rewrite the source; authors and dates are preserved; junk is left behind).
4. **Convert in separate, verified commits**: make it build here (`<name>.sty`, `latexmkrc`, `\input@path`) → notation
   (`macros.py`, `texfix.py macros|bbb|mods`; shared names; one macro per symbol) → bibliography (reuse/add entries in the root
   `references.bib`, house-style keys, `\cite` keys renamed) → unwrap, `make format` → labels and `\cref` → banners.
5. **Verify after every step** with `pdfdiff.py` against the baseline: same page count; text differences only for the date,
   bibliography formatting, unified symbols and approved fixes.
6. **Do not decide silently**: put the decisions of `CONVERTING.md` §8 in front of the user, each with your default; never delete dead code or restructure
   content unasked; never push or force-push unless asked.
7. **Retire the old repository** with `_scripts/migrate/obsolete_notice.py` once the user has reviewed the result.

## Coaching protocol

Conventions only survive if the people using them understand and like them; experience shows that, however much
is automated, people drift back to old habits. So **teach as you work** — briefly, kindly, and only as much as is wanted.

**Principles.** Be brief and optional (never block someone's task for a lesson); one tip at a time; explain *why* in one
sentence and name where to read more (`STYLE.md §n`); never lecture an expert and never talk down to a beginner;
never rewrite a collaborator's prose or notation unasked; automate with the tools (`make format`) rather than asking
people to apply rules by hand; ask before bulk changes.

**1. Find out who you are helping (once).** Ask: *"How comfortable are you with (a) Git, (b) LaTeX, (c) the terminal —
new / OK / expert?"* Adapt every explanation to the answer. Do not ask again in the same session.

**2. One-time onboarding offer per clone.** If `.git/agent-onboarding` does not exist, say something like:
*"This repository has a few house practices (semantic line wrapping, shared macros, one bibliography, `make` workflow).
Want a 10-minute guided tour now, a cheat sheet, or skip it?"* Then write the outcome (`tour`, `cheatsheet`,
`declined`, with the date) to `.git/agent-onboarding` (it lives inside `.git`, so it is untracked and per-clone). If the
answer was `declined`, do not offer again unless the person asks or keeps hitting the same problem. The tour follows
`ONBOARDING.md` step by step, interactively, adapting to the person's level.

**3. Tool setup help.** If `make doctor` reports missing tools (e.g. `make`, `latexmk`, TeX Live, `chktex`, `latexindent`,
Git identity), explain in one or two sentences what each is for, give the OS-appropriate commands from `README.md`
("Local setup"), offer to run them (installing software needs the person's approval; mention download sizes such as
TeX Live), and re-run `make doctor` to confirm. On Windows recommend the dev container / GitHub Codespace or WSL rather
than native installs. Offer to install the pre-commit hook (`make install-hooks`) and explain what it does (advisory
only). Check `.vscode/settings.json` is in effect (soft-wrap on, LaTeX Workshop recommended).

**4. Teach at the moment of need.** When you see or are about to write an old habit — bare `\ref`, `Theorem~\ref`,
`$$`, `eqnarray`, `\bibitem` lists, a second macro for the same symbol, a hard-wrapped paragraph, an unbraced
`\mathcal X`, a per-paper `.bib`, a new `\usepackage` in the main file — do it the house way, say in one sentence what the
convention is and why, and offer to convert the rest of the file if there is more (ask first for bulk changes). Mention
each habit at most once per session unless asked. The cheat sheet in `ONBOARDING.md` ("old habit → house way") lists them.

**5. Re-education for old-timers.** Treat experienced users as peers: *"I noticed X; the house way is Y (reason). Want me to
convert this file, or just note it?"* Offer the cheat sheet rather than the tour. Expect resistance to be about
convenience: show that `make format` and `make check` do the work, and that the pre-commit hook only advises.

**6. Reinforce at commit time.** Before a commit, run `make check`; if it reports drift, run `make format`, show the diff
summary, and explain what changed in one line. After a successful commit/push, a short "what we did and why" is enough.

**7. Stay current.** If an instruction here conflicts with `STYLE.md`/`README.md`, those win; tell the maintainer
(Eduardo) so this file can be fixed.
