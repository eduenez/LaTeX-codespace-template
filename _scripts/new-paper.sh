#!/usr/bin/env bash
# new-paper.sh — create a new paper directory from a template.
#
# Usage:  bash _scripts/new-paper.sh <name> [article|monograph]
#   (or:  make new P=<name> TYPE=article|monograph)
#
# Copies _templates/<type>/ to ./<name>/, renaming PAPER -> <name>, and adds a
# two-line latexmkrc so that plain `latexmk` works inside the new directory.
# No symlinks are created: the paper reaches the shared _packages/ and
# references.bib by relative path (../).
set -euo pipefail

name="${1:-}"
type="${2:-article}"

if [ -z "$name" ]; then
  echo "usage: bash _scripts/new-paper.sh <name> [article|monograph]" >&2
  exit 2
fi
if ! [[ "$name" =~ ^[A-Za-z0-9][A-Za-z0-9-]*$ ]]; then
  echo "error: name must use only letters, digits and hyphens (and not start with a hyphen)" >&2
  exit 2
fi
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src="$repo/_templates/$type"
dest="$repo/$name"
if [ ! -d "$src" ]; then
  echo "error: unknown type '$type' (expected article or monograph)" >&2
  exit 2
fi
if [ -e "$dest" ]; then
  echo "error: $name/ already exists" >&2
  exit 1
fi

mkdir "$dest"
for f in "$src"/*; do
  base="$(basename "$f")"
  sed "s/PAPER/$name/g" "$f" > "$dest/${base//PAPER/$name}"
done
# @default_files: build only the main file (not the \include'd chapter files).
printf "@default_files = ('%s.tex');\ndo '../latexmkrc';\n" "$name" > "$dest/latexmkrc"

echo "Created $name/ ($type). Next:"
echo "  edit $name/$name.tex and $name/$name.sty"
echo "  build:  make $name      (or: cd $name && latexmk)"
