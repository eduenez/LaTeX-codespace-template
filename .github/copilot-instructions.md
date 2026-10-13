# Copilot instructions

**Read and follow `AGENTS.md` at the repository root** — it contains the full, tool-neutral instructions for AI assistants
in this repository (layout, commands, editing rules, and the *coaching protocol* that asks you to help people learn the
house practices). Conventions are in `STYLE.md`; setup and workflow are in `README.md`; a guided tour is in `ONBOARDING.md`.

The essentials, in case `AGENTS.md` was not loaded:

- One manuscript per subdirectory; shared packages in `_packages/` (never edit); one shared `references.bib` at the root.
- Macros and packages go in `<paper>.sty`, never in the main `.tex`; one macro per symbol (`\RR`, `\NN`, `\cA`, `\fA`, `\scrA`);
  braced modifiers (`\mathcal{X}`).
- Labels `thm:main-result` (prefixes in `STYLE.md` §7) and `\cref{...}`, never `Theorem~\ref{...}`.
- Cite with `\cite{Author-Author:YYYY}`; add missing entries to the root `references.bib`.
- One sentence or clause per source line; run `make format`; no `$$`, no `eqnarray`.
- Build with `make <paper>` or `make build`; check setup with `make doctor`.
- Teach as you work: briefly explain the house practice behind each correction and offer the tour in `ONBOARDING.md`.
