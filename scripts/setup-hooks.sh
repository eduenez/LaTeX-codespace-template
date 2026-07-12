#!/usr/bin/env bash
# setup-hooks.sh — Install git hooks for the LaTeX project.
#
# Run once after cloning, or let the devcontainer postCreateCommand handle it.
# This script is idempotent.

set -euo pipefail

REPO_ROOT="$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/.." && pwd)")"
HOOKS_DIR="$REPO_ROOT/.git/hooks"

# Ensure we are in a git repository
if [ ! -d "$REPO_ROOT/.git" ]; then
  echo "setup-hooks: not a git repository — skipping hook installation"
  exit 0
fi

mkdir -p "$HOOKS_DIR"

# ── pre-commit hook ──────────────────────────────────────────────────────────
cat > "$HOOKS_DIR/pre-commit" << 'HOOK'
#!/usr/bin/env bash
# pre-commit hook — checks staged .tex files for formatting issues.
#
# 1. Line width check: no prose line > 100 columns (via texwrap.py --check)
# 2. Trailing whitespace check
# 3. No $$ ... $$ (double-dollar display math)
# 4. No \eqnarray

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"

# Collect staged .tex files
STAGED_TEX=$(git diff --cached --name-only --diff-filter=ACM | grep '\.tex$' || true)

if [ -z "$STAGED_TEX" ]; then
  exit 0
fi

ERRORS=0

# ── Check 1: Line width via texwrap.py ───────────────────────────────────────
if [ -f "$REPO_ROOT/scripts/texwrap.py" ]; then
  # shellcheck disable=SC2086
  if ! python3 "$REPO_ROOT/scripts/texwrap.py" --check --cols 100 $STAGED_TEX; then
    echo ""
    echo "pre-commit: Some .tex files have lines exceeding 100 columns."
    echo "            Run 'make wrap PROJECT=<dir>' to fix."
    ERRORS=1
  fi
fi

# ── Check 2: Trailing whitespace ────────────────────────────────────────────
for f in $STAGED_TEX; do
  if grep -Pn '\s+$' "$f" > /dev/null 2>&1; then
    echo "pre-commit: trailing whitespace in $f"
    grep -Pn '\s+$' "$f" | head -5
    ERRORS=1
  fi
done

# ── Check 3: No $$ ... $$ display math ──────────────────────────────────────
for f in $STAGED_TEX; do
  if grep -n '\$\$' "$f" > /dev/null 2>&1; then
    echo "pre-commit: double-dollar display math (\$\$) found in $f"
    echo "            Use equation*/\\[...\\] instead."
    grep -n '\$\$' "$f" | head -5
    ERRORS=1
  fi
done

# ── Check 4: No \eqnarray ───────────────────────────────────────────────────
for f in $STAGED_TEX; do
  if grep -n '\\begin{eqnarray' "$f" > /dev/null 2>&1; then
    echo "pre-commit: \\eqnarray found in $f"
    echo "            Use align/align* instead."
    ERRORS=1
  fi
done

if [ "$ERRORS" -ne 0 ]; then
  echo ""
  echo "pre-commit: commit aborted due to formatting issues."
  echo "            Fix the issues above and try again."
  exit 1
fi

exit 0
HOOK

chmod +x "$HOOKS_DIR/pre-commit"
echo "setup-hooks: installed pre-commit hook"
