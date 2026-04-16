# Makefile — Build, format, and lint targets for LaTeX projects
#
# This Makefile is designed to work with both the monograph/ and article/
# subdirectories.  Set PROJECT to the subdirectory you want to build.
#
# Targets:
#   make                     – show help
#   make monograph           – build monograph PDF
#   make article             – build article PDF
#   make format PROJECT=...  – full format pass (wrap + indent)
#   make wrap PROJECT=...    – semantic line-wrap only
#   make indent PROJECT=...  – indentation normalization only
#   make check PROJECT=...   – dry-run: report files needing formatting
#   make lint PROJECT=...    – run chktex linter
#   make clean PROJECT=...   – remove build directory
#   make clean-all           – remove all build directories
#   make help                – show this help

COLS    := 100

.PHONY: all help monograph article format wrap indent check lint clean clean-all install-hooks

all: help

## help: Show available targets
help:
	@echo "LaTeX Codespace Template — Makefile Targets"
	@echo ""
	@echo "  Building:"
	@echo "    make monograph          Build monograph PDF (XeLaTeX via latexmk)"
	@echo "    make article            Build article PDF (XeLaTeX via latexmk)"
	@echo ""
	@echo "  Formatting (set PROJECT=monograph or PROJECT=article):"
	@echo "    make format             Full format pass (wrap + indent)"
	@echo "    make wrap               Semantic line-wrap only"
	@echo "    make indent             Indentation normalization only (latexindent)"
	@echo "    make check              Dry-run: report files needing formatting"
	@echo ""
	@echo "  Linting:"
	@echo "    make lint               Run chktex on .tex files"
	@echo ""
	@echo "  Cleaning:"
	@echo "    make clean              Remove build/ in PROJECT"
	@echo "    make clean-all          Remove all build/ directories"
	@echo ""
	@echo "  Setup:"
	@echo "    make install-hooks      Install git pre-commit hook"

# ── Discover .tex files in a project ─────────────────────────────────────────
ifdef PROJECT
TEX_SRC := $(wildcard $(PROJECT)/*.tex)
endif

## monograph: Build monograph PDF
monograph:
	@mkdir -p monograph/build
	cd monograph && latexmk monograph-template

## article: Build article PDF
article:
	@mkdir -p article/build
	cd article && latexmk article-template

## format: Full formatting pass (semantic wrap then indent)
format: wrap indent

## wrap: Semantic line-wrapping
wrap:
ifndef PROJECT
	$(error Set PROJECT=monograph or PROJECT=article)
endif
	python3 scripts/texwrap.py --cols $(COLS) $(TEX_SRC)

## indent: Indentation normalization (latexindent)
indent:
ifndef PROJECT
	$(error Set PROJECT=monograph or PROJECT=article)
endif
	@for f in $(TEX_SRC); do \
	  latexindent -w -s -l latexindent.yaml "$$f" \
	    && echo "latexindent: formatted  $$f"; \
	done

## check: Report files needing wrapping (no changes)
check:
ifndef PROJECT
	$(error Set PROJECT=monograph or PROJECT=article)
endif
	python3 scripts/texwrap.py --check --cols $(COLS) $(TEX_SRC)

## lint: Run chktex linter on .tex files
lint:
ifndef PROJECT
	$(error Set PROJECT=monograph or PROJECT=article)
endif
	@for f in $(TEX_SRC); do \
	  echo "chktex: $$f"; \
	  chktex -q -l .chktexrc "$$f"; \
	done

## clean: Remove build artifacts for a project
clean:
ifndef PROJECT
	$(error Set PROJECT=monograph or PROJECT=article)
endif
	rm -rf $(PROJECT)/build
	rm -f $(PROJECT)/*.bak[0-9] $(PROJECT)/*.bak[0-9][0-9]
	rm -f $(PROJECT)/indent.log

## clean-all: Remove all build artifacts
clean-all:
	rm -rf monograph/build article/build
	find . -name '*.bak[0-9]' -o -name '*.bak[0-9][0-9]' | xargs rm -f
	find . -name 'indent.log' -delete

## install-hooks: Install the git pre-commit hook
install-hooks:
	bash scripts/setup-hooks.sh
