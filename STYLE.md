# Style & Conventions

These are the writing conventions for this project. They keep collaborative
LaTeX diffs small and the source consistent.

**How they're enforced:** gently. The git pre-commit hook and the CI pipeline
are **advisory** — they print reminders but do **not** block your commit or fail
the build (see [README.md](README.md)). The *only* hard gates are the banned
patterns below (`$$`, `\eqnarray`), which CI rejects because they degrade the
output. Everything else is a norm, not a wall.

## 1. Semantic line wrapping (one unit per line)

Start a new source line after **each sentence** and after each semicolon/colon
clause. This is the single most important rule for collaborating over Git.

```latex
% ✓ GOOD — each sentence on its own line
Widget theory was initiated by Doe~\cite{Doe:2020}.
The main theorem characterizes compact widgets.

% ✗ BAD — a whole paragraph on one line
Widget theory was initiated by Doe~\cite{Doe:2020}. The main theorem characterizes compact widgets.
```

**Why?** Git diffs line by line. Editing one word in a paragraph-long line marks
the *entire* paragraph as changed, wrecking review and conflict resolution.

Normalize automatically:

```bash
make wrap     # rewrap all .tex at semantic boundaries
make check    # dry-run: report files that aren't wrapped
```

`scripts/texwrap.py` breaks at sentence ends and `;`/`:` clauses regardless of
length. The width knob (`--cols`, default 256) only governs the *last-resort*
hard-break of a single over-long sentence — it is **not** a hard column limit.

## 2. Indentation: 2 spaces, no tabs

- 2 spaces per nesting level inside `\begin{…}…\end{…}`.
- Display-math bodies (`equation`, `align`, …) get no extra indent — they're
  `&`-aligned tables.

```bash
make indent   # latexindent pass
make format   # wrap + indent
```

## 3. Banned patterns (the only hard gate)

| Pattern | Use instead |
|---|---|
| `$$ ... $$` | `\[ ... \]` or `equation*` |
| `\begin{eqnarray}` | `align` / `align*` |
| `\\` for paragraph breaks | a blank line |
| bare `\ref{...}` | `\cref{...}` (cleveref) |

The first two are rejected by CI; the last two are advisory nudges.

## 4. Math environments

| Purpose | Environment |
|---|---|
| Inline | `$ ... $` or `\( ... \)` |
| Display, unnumbered | `\[ ... \]` or `equation*` |
| Display, numbered | `equation` |
| Multi-line, numbered | `align` |
| Multi-line, unnumbered | `align*` |

## 5. Label conventions

Use semantic prefixes, then reference with `\cref`/`\Cref`:

| Prefix | For | | Prefix | For |
|---|---|---|---|---|
| `cha:` | `\chapter` | | `def:` | definition |
| `sec:` | section/subsection | | `exa:` | example |
| `thm:` | theorem | | `rem:` | remark |
| `lem:` | lemma | | `notn:` | notation |
| `prop:` | proposition | | `eq:` | equation |
| `cor:` | corollary | | `fig:` | figure |
| `conj:` | conjecture | | | |

Example: `\label{thm:main-result}` → `\cref{thm:main-result}`.

## 6. Bibliography (BibTeX)

- One bibliography file: `references.bib` at the repo root.
- Entry keys follow `AuthorLastName:YYYY` or `AuthorOne-AuthorTwo:YYYY`.
- Cite with `\cite{key}` (use a non-breaking space before it: `Doe~\cite{Doe:2020}`).
- The bibliography is typeset by `\bibliographystyle{alpha}` + `\bibliography{references}`
  at the end of the main `.tex`.
- BibTeX has no comment syntax and treats the at-sign as an entry start — keep
  bare at-signs out of `references.bib` header comments.

## 7. Cross-referencing & macros

- `\cref{...}` auto-generates "Theorem 2.1", "Section 3", …; `\Cref{...}` at the
  start of a sentence. Never hardcode "Theorem \ref{...}".
- Define macros for repeated notation in the preamble:

```latex
\newcommand{\RR}{\mathbb{R}}
\DeclarePairedDelimiter{\norm}{\lVert}{\rVert}
```

## 8. Collaboration

- `todonotes` is loaded: `\todo{...}` / `\todo[inline]{...}`.
- Git mantra: **pull → commit often → push**. Small, specific commit messages
  ("Add proof of Lemma 3.2", not "updates").
