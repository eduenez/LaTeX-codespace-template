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
#   make wrap            – semantic line-wrap all .tex
#   make indent          – latexindent all .tex
#   make format          – wrap + indent
#   make check           – dry-run: report .tex needing wrapping
#   make lint            – run chktex on all .tex
#   make clean           – remove build/ and stray auxiliaries
#   make install-hooks   – install the advisory git pre-commit hook
#   make help            – show this help

COLS    := 256
TEX_SRC := $(wildcard *.tex)
# Main documents = files that contain \documentclass.
MAIN_SRC := $(shell grep -l '\\documentclass' $(TEX_SRC) 2>/dev/null)

.PHONY: all help build wrap indent format check lint clean install-hooks

all: help

## help: Show available targets
help:
	@echo "LaTeX Project — Makefile Targets"
	@echo ""
	@echo "  make build           Build every main document (pdfLaTeX via latexmk)"
	@echo "  make wrap            Semantic line-wrap all .tex"
	@echo "  make indent          Indentation normalization (latexindent)"
	@echo "  make format          wrap + indent"
	@echo "  make check           Dry-run: report .tex needing wrapping"
	@echo "  make lint            Run chktex on all .tex"
	@echo "  make clean           Remove build/ and stray auxiliaries"
	@echo "  make install-hooks   Install the advisory git pre-commit hook"
	@echo ""
	@echo "  Main documents detected: $(MAIN_SRC)"

## build: Build every main document
build:
	@if [ -z "$(MAIN_SRC)" ]; then echo "No main .tex (with \\documentclass) found."; exit 1; fi
	@for f in $(MAIN_SRC); do \
	  echo "── Building $$f ──"; \
	  latexmk "$${f%.tex}"; \
	done

## wrap: Semantic line-wrapping
wrap:
	python3 scripts/texwrap.py --cols $(COLS) $(TEX_SRC)

## indent: Indentation normalization (latexindent)
indent:
	@for f in $(TEX_SRC); do \
	  latexindent -w -s -l latexindent.yaml "$$f" \
	    && echo "latexindent: formatted  $$f"; \
	done

## format: Full formatting pass (wrap then indent)
format: wrap indent

## check: Report .tex needing wrapping (no changes)
check:
	python3 scripts/texwrap.py --check --cols $(COLS) $(TEX_SRC)

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
