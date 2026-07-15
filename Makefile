# Makefile — Build, format, and lint targets for LaTeX projects
#
# Flat layout: all .tex files live at the repo root. "Main" documents are the
# ones containing \documentclass; chapter files \include'd by a monograph are
# not built directly. latexmk (via .latexmkrc) puts intermediates in build/
# and the finished PDF at the repo root.
#
# Targets:
#   make                 – show help
#   make build           – build every main document (auto-discovered)
#   make format          – do it all: fashion + reflow (idempotent)
#   make reflow          – wrap + indent (idempotent re-flow)
#   make fashion         – modernize typography (accents, quotes, tabs)
#   make wrap            – semantic line-wrap all .tex (break positions only)
#   make indent          – whitespace/indentation normalization (latexindent)
#   make sep             – normalize sectioning banners (advisory)
#   make check           – dry-run: report .tex needing fashion/wrapping
#   make lint            – run chktex on all .tex
#   make clean           – remove build/ and stray auxiliaries
#   make install-hooks   – install the advisory git pre-commit hook
#   make help            – show this help

COLS    := 256
TEX_SRC := $(wildcard *.tex)
# Main documents = files that contain \documentclass.
MAIN_SRC := $(shell grep -l '\\documentclass' $(TEX_SRC) 2>/dev/null)

.PHONY: all help build article pdf PDF compile format reflow fashion wrap indent sep check lint clean install-hooks $(MAIN_SRC) $(MAIN_SRC:.tex=)

all: help

## help: Show available targets
help:
	@echo "LaTeX Project — Makefile Targets"
	@echo ""
	@echo "  Building:"
	@echo "    make build           Build every main document (pdfLaTeX via latexmk)"
	@echo "                         synonyms: article, pdf, PDF, compile"
	@echo "    make <name>          Build one document by name, e.g. make $(firstword $(MAIN_SRC:.tex=))"
	@echo ""
	@echo "  Formatting:"
	@echo "    make format          Do it all: fashion + reflow"
	@echo "    make reflow          Re-flow: wrap + indent (idempotent)"
	@echo "    make fashion         Modernize typography (accents, quotes, tabs)"
	@echo "    make wrap            Semantic line-wrap only (break positions)"
	@echo "    make indent          Whitespace/indentation normalization (latexindent)"
	@echo "    make sep             Normalize sectioning banners (advisory)"
	@echo "    make check           Dry-run: report .tex needing fashion/wrapping"
	@echo ""
	@echo "  Linting & cleaning:"
	@echo "    make lint            Run chktex on all .tex"
	@echo "    make clean           Remove build/ and stray auxiliaries"
	@echo "    make install-hooks   Install the advisory git pre-commit hook"
	@echo ""
	@echo "  Main documents detected: $(MAIN_SRC)"

## build: Build every main document.  Synonyms (same effect): article, pdf,
## PDF, compile — so authors can type whichever reads naturally.
build article pdf PDF compile:
	@if [ -z "$(MAIN_SRC)" ]; then echo "No main .tex (with \\documentclass) found."; exit 1; fi
	@for f in $(MAIN_SRC); do \
	  echo "── Building $$f ──"; \
	  latexmk "$${f%.tex}"; \
	done

# Build a single named document: `make NFL` or `make NFL.tex` (one target per
# main file, generated from MAIN_SRC), for repos with several documents.
$(MAIN_SRC) $(MAIN_SRC:.tex=):
	@latexmk "$(basename $@)"

## format: Do it all — modernize typography, then reflow
format:
	@$(MAKE) --no-print-directory fashion
	@$(MAKE) --no-print-directory reflow

## reflow: Re-flow prose — semantic wrap, then normalize whitespace/indentation.
## Idempotent: texwrap measures de-indented width and preserves whitespace;
## latexindent owns all indentation and blank lines, so the two cannot fight.
reflow:
	@$(MAKE) --no-print-directory wrap
	@$(MAKE) --no-print-directory indent

## fashion: Modernize typography (accents -> Unicode, curly quotes, tabs -> spaces)
fashion:
	python3 scripts/texfashion.py $(TEX_SRC)

## wrap: Semantic line-wrapping (break positions only; whitespace-preserving)
wrap:
	python3 scripts/texwrap.py --cols $(COLS) $(TEX_SRC)

## indent: Whitespace normalization (latexindent). -m enables blank-line
## condensing; with this config it makes no other line-break changes.
indent:
	@for f in $(TEX_SRC); do \
	  latexindent -m -w -s -l latexindent.yaml "$$f" \
	    && echo "latexindent: formatted  $$f"; \
	done

## sep: Normalize sectioning banners (STYLE.md; advisory, comment-only)
sep:
	python3 scripts/texsep.py $(TEX_SRC)

## check: Report .tex needing fashion/wrapping (no changes; latexindent has no dry-run)
check:
	@rc=0; \
	python3 scripts/texfashion.py --check $(TEX_SRC) || rc=1; \
	python3 scripts/texwrap.py --check --cols $(COLS) $(TEX_SRC) || rc=1; \
	exit $$rc

## lint: Run chktex on all .tex
lint:
	@for f in $(TEX_SRC); do \
	  echo "chktex: $$f"; \
	  chktex -q -l .chktexrc "$$f"; \
	done

## clean: Remove build artifacts
clean:
	rm -rf build
	rm -f *.bak[0-9] *.bak[0-9][0-9] indent.log
	rm -f *.aux *.log *.out *.toc *.fls *.fdb_latexmk *.bbl *.blg *.synctex.gz

## install-hooks: Install the advisory git pre-commit hook
install-hooks:
	bash scripts/setup-hooks.sh
