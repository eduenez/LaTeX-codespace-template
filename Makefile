# Makefile — Build, format, and lint targets for a multi-paper LaTeX repository
#
# Layout: every paper lives in its own subdirectory (<paper>/<paper>.tex).
# Directories whose names start with "_" or "." are infrastructure
# (_packages, _scripts, _templates, _build, …), never papers. A "main" document
# is a .tex containing \documentclass; \include'd chapter files are not built
# directly. latexmk (via ./latexmkrc) puts intermediates in <paper>/_build/ and
# the finished PDF in <paper>/.
#
# Targets (P=<paper> restricts the format/lint/clean targets to one paper):
#   make                 – show help
#   make new P=name TYPE=article|monograph   – create a new paper from a template
#   make build           – build every paper (auto-discovered)
#   make <paper>         – build one paper
#   make export P=name   – self-contained copy in _export/<name>/ (for arXiv etc.)
#   make format          – do it all: fashion + reflow (idempotent)
#   make reflow | fashion | wrap | indent | sep | check | lint
#   make clean           – remove build artifacts
#   make install-hooks   – install the advisory git pre-commit hook
#   make help            – show this help

COLS := 256
# Main documents: <dir>/<file>.tex containing \documentclass, dir not starting with _ or .
ALL_TEX  := $(wildcard [!_.]*/*.tex)
MAIN_SRC := $(shell grep -l '\\documentclass' $(ALL_TEX) 2>/dev/null)
PAPERS   := $(sort $(patsubst %/,%,$(dir $(MAIN_SRC))))
# Files the formatters/linters act on: one paper (P=) or all papers.
ifdef P
TEX_SRC := $(filter-out %/icons.tex %/ramsey_graphs.tex,$(shell find $(P) -name '*.tex' -not -path '*/_*' 2>/dev/null))
else
TEX_SRC := $(filter-out %/icons.tex %/ramsey_graphs.tex,$(foreach d,$(PAPERS),$(shell find $(d) -name '*.tex' -not -path '*/_*' 2>/dev/null)))
endif
TYPE ?= article

doctor:
	@bash _scripts/doctor.sh

.PHONY: doctor all help new export build article pdf PDF compile format reflow fashion wrap indent sep check lint clean install-hooks $(PAPERS)

all: help

## help: Show available targets
help:
	@echo "LaTeX Papers — Makefile Targets"
	@echo ""
	@echo "  Setup:"
	@echo "    make doctor          Check tools and setup; says how to fix what is missing"
	@echo ""
	@echo "  Papers:"
	@echo "    make new P=name TYPE=article|monograph   Create a new paper from a template"
	@echo "    make build           Build every paper (pdfLaTeX via latexmk)"
	@echo "                         synonyms: article, pdf, PDF, compile"
	@echo "    make <paper>         Build one paper, e.g. make $(firstword $(PAPERS))"
	@echo "    make export P=name   Self-contained copy in _export/<name>/"
	@echo ""
	@echo "  Formatting (add P=<paper> to restrict to one paper):"
	@echo "    make format          Do it all: fashion + reflow"
	@echo "    make reflow          Re-flow: wrap + indent (idempotent)"
	@echo "    make fashion         Modernize typography (accents, quotes, tabs)"
	@echo "    make wrap            Semantic line-wrap only (break positions)"
	@echo "    make indent          Whitespace/indentation normalization (latexindent)"
	@echo "    make sep             Normalize sectioning banners (advisory)"
	@echo "    make check           Dry-run: report .tex needing fashion/wrapping"
	@echo ""
	@echo "  Linting & cleaning:"
	@echo "    make lint            Run chktex on all paper .tex"
	@echo "    make clean           Remove build artifacts (add P=<paper> for one)"
	@echo "    make install-hooks   Install the advisory git pre-commit hook"
	@echo ""
	@echo "  Papers detected: $(PAPERS)"

## new: Create a paper:  make new P=my-paper TYPE=article|monograph
new:
	@test -n "$(P)" || { echo "usage: make new P=<name> TYPE=article|monograph"; exit 2; }
	@bash _scripts/new-paper.sh "$(P)" "$(TYPE)"

## export: Self-contained copy of one paper in _export/<P>/
export:
	@test -n "$(P)" || { echo "usage: make export P=<paper>"; exit 2; }
	@bash _scripts/export-paper.sh "$(P)"

## build: Build every paper.  Synonyms (same effect): article, pdf, PDF, compile
build article pdf PDF compile:
	@if [ -z "$(PAPERS)" ]; then echo "No papers found (see README: make new P=<name>)."; exit 1; fi
	@fail=""; for d in $(PAPERS); do \
	  echo "── Building $$d ──"; \
	  ( cd "$$d" && latexmk -r ../latexmkrc ) || fail="$$fail $$d"; \
	done; \
	if [ -n "$$fail" ]; then echo "BUILD FAILED for:$$fail"; exit 1; fi

# Build one paper by directory name: `make my-paper`.
$(PAPERS):
	@cd "$@" && latexmk -r ../latexmkrc

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
	python3 _scripts/texfashion.py $(TEX_SRC)

## wrap: Semantic line-wrapping (break positions only; whitespace-preserving)
wrap:
	python3 _scripts/texwrap.py --cols $(COLS) $(TEX_SRC)

## indent: Whitespace normalization (latexindent). -m enables blank-line
## condensing; with this config it makes no other line-break changes.
indent:
	@for f in $(TEX_SRC); do \
	  latexindent -m -w -s -l latexindent.yaml "$$f" \
	    && echo "latexindent: formatted  $$f"; \
	done

## sep: Normalize sectioning banners (STYLE.md; advisory, comment-only)
sep:
	python3 _scripts/texsep.py $(TEX_SRC)

## check: Report .tex needing fashion/wrapping (no changes; latexindent has no dry-run)
check:
	@rc=0; \
	python3 _scripts/texfashion.py --check $(TEX_SRC) || rc=1; \
	python3 _scripts/texwrap.py --check --cols $(COLS) $(TEX_SRC) || rc=1; \
	exit $$rc

## lint: Run chktex on all .tex
lint:
	@for f in $(TEX_SRC); do \
	  echo "chktex: $$f"; \
	  chktex -q -l .chktexrc "$$f"; \
	done

## clean: Remove build artifacts (all papers, or one with P=<paper>)
CLEAN_DIRS := $(if $(P),$(P),$(PAPERS))
clean:
	@for d in $(CLEAN_DIRS) _export; do \
	  rm -rf "$$d/_build"; \
	  rm -f "$$d"/*.bak[0-9] "$$d"/*.bak[0-9][0-9] "$$d"/indent.log; \
	  rm -f "$$d"/*.aux "$$d"/*.log "$$d"/*.out "$$d"/*.toc "$$d"/*.fls "$$d"/*.fdb_latexmk "$$d"/*.bbl "$$d"/*.blg "$$d"/*.synctex.gz; \
	done
	@rm -rf _export

## install-hooks: Install the advisory git pre-commit hook
install-hooks:
	bash _scripts/setup-hooks.sh
