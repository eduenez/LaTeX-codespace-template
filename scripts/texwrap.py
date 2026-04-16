#!/usr/bin/env python3
"""
texwrap.py — Semantic line wrapper for LaTeX source files.

Wraps prose lines longer than --cols (default 100) at the best available
semantic boundary, searching right-to-left from column --cols:

  priority 1 – sentence end   ". "  "? "  "! "
  priority 2 – semicolon      "; "
  priority 3 – colon          ": "  (but not ":=" or "::")
  priority 4 – comma          ", "

Content inside display-math regions (\\[ … \\], equation, align, …),
verbatim-style environments, and pure comment lines is never modified.
Indentation is never changed.

Usage:
    python3 texwrap.py [--check] [--cols N] file1.tex [file2.tex …]

    --check   Dry run: report files that would change, exit 1 if any.
    --cols N  Target column width (default: 90).
"""

import argparse
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration constants
# ---------------------------------------------------------------------------

DEFAULT_COLS: int = 100
MIN_BREAK_COL: int = 50  # never break before this column

# Bodies of these environments are never touched (treated as verbatim)
VERBATIM_ENVS: frozenset = frozenset(
    {
        "verbatim",
        "Verbatim",
        "lstlisting",
        "minted",
        "filecontents",
        "comment",
        "BVerbatim",
        "SaveVerbatim",
    }
)

# Display-math environments: content is not prose, skip line-break insertion
MATH_ENVS: frozenset = frozenset(
    {
        "equation",
        "equation*",
        "align",
        "align*",
        "gather",
        "gather*",
        "multline",
        "multline*",
        "eqnarray",
        "eqnarray*",
        "split",
        "aligned",
        "alignedat",
        "gathered",
        "array",
        "matrix",
        "pmatrix",
        "bmatrix",
        "vmatrix",
        "Vmatrix",
        "Bmatrix",
        "cases",
        "subequations",
        "tikzpicture",
        "tabular",
        "tabular*",
        "tabularx",
        "longtable",
    }
)

PROTECTED_ENVS: frozenset = VERBATIM_ENVS | MATH_ENVS

# ---------------------------------------------------------------------------
# Sentence-end detection
# ---------------------------------------------------------------------------

_ABBREV_RE = re.compile(
    r"(?:"
    r"[A-Z]"
    r"|[Ss]ect|[Ff]ig|[Tt]hm|[Pp]rop"
    r"|[Dd]ef|[Cc]or|[Ll]em|[Ee]q"
    r"|[Cc]f|vs|[Ee]d|[Tt]rans"
    r"|[Vv]ol|[Nn]o|[Pp]p|[Pp]"
    r"|i\.e|e\.g|viz|etc|et\sal|[Aa]pprox"
    r")\.$"
)


def _is_sentence_end(text: str, i: int) -> bool:
    """Return True if text[i] is sentence-ending punctuation before a space."""
    if text[i] not in ".?!":
        return False
    if i + 1 >= len(text) or text[i + 1] != " ":
        return False
    if text[i] == ".":
        start = i - 1
        while start >= 0 and (text[start].isalnum() or text[start] == "."):
            start -= 1
        word = text[start + 1 : i + 1]
        if _ABBREV_RE.match(word):
            return False
        if word.replace(".", "").isdigit():
            return False
    return True


# ---------------------------------------------------------------------------
# Break-point search
# ---------------------------------------------------------------------------


def _find_break(line: str, lo: int, hi: int) -> int | None:
    """
    Search backwards in line[lo:hi] for the best semantic break point.
    Returns the index of the first character of the continuation, or None.
    """
    hi = min(hi, len(line) - 1)

    # Priority 1: sentence end (. ? !)
    for i in range(hi - 1, lo - 1, -1):
        if _is_sentence_end(line, i):
            return i + 2

    # Priority 2: semicolon
    for i in range(hi - 1, lo - 1, -1):
        if line[i] == ";" and i + 1 < len(line) and line[i + 1] == " ":
            return i + 2

    # Priority 3: colon (but not := or ::)
    for i in range(hi - 1, lo - 1, -1):
        if line[i] == ":" and i + 1 < len(line) and line[i + 1] == " ":
            nxt = line[i + 2] if i + 2 < len(line) else ""
            if nxt not in ("=", ":"):
                return i + 2

    # Priority 4: comma
    for i in range(hi - 1, lo - 1, -1):
        if line[i] == "," and i + 1 < len(line) and line[i + 1] == " ":
            return i + 2

    return None


# ---------------------------------------------------------------------------
# Single-line wrapper
# ---------------------------------------------------------------------------


def _wrap_line(line: str, max_cols: int) -> list[str]:
    """Wrap one long prose line into multiple shorter lines."""
    if len(line) <= max_cols:
        return [line]

    indent = line[: len(line) - len(line.lstrip())]
    pieces: list[str] = []
    cur = line

    while len(cur) > max_cols:
        bp = _find_break(cur, MIN_BREAK_COL, max_cols)
        if bp is None:
            break
        pieces.append(cur[:bp].rstrip())
        cur = indent + cur[bp:]

    pieces.append(cur)
    return pieces


# ---------------------------------------------------------------------------
# Environment / display-math state tracking
# ---------------------------------------------------------------------------

_BEGIN_RE = re.compile(r"\\begin\{([^}]+)\}")
_END_RE = re.compile(r"\\end\{([^}]+)\}")
_DISPLAY_OPEN = re.compile(r"^\s*\\\[")
_DISPLAY_CLOSE = re.compile(r"^\s*\\\]")
_COMMENT_LINE = re.compile(r"^\s*%")


# ---------------------------------------------------------------------------
# File processor
# ---------------------------------------------------------------------------


def process(text: str, max_cols: int) -> str:
    """Return reformatted content for one .tex file."""
    env_stack: list[str] = []
    in_display_math = False
    out: list[str] = []

    for raw in text.splitlines():
        line = raw.rstrip()

        if _DISPLAY_OPEN.match(line):
            in_display_math = True
            out.append(line)
            continue

        if in_display_math:
            out.append(line)
            if _DISPLAY_CLOSE.match(line):
                in_display_math = False
            continue

        for m in _BEGIN_RE.finditer(line):
            env_stack.append(m.group(1))

        in_protected = any(e in PROTECTED_ENVS for e in env_stack)

        for m in _END_RE.finditer(line):
            env = m.group(1)
            for i in range(len(env_stack) - 1, -1, -1):
                if env_stack[i] == env:
                    del env_stack[i]
                    break

        if in_protected or _COMMENT_LINE.match(line) or len(line) <= max_cols:
            out.append(line)
        else:
            out.extend(_wrap_line(line, max_cols))

    return "\n".join(out) + ("\n" if text.endswith("\n") else "")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def main() -> int:
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("files", nargs="+", metavar="FILE")
    ap.add_argument(
        "--check",
        action="store_true",
        help="Dry run: report files that need changes, exit 1 if any.",
    )
    ap.add_argument(
        "--cols",
        type=int,
        default=DEFAULT_COLS,
        metavar="N",
        help=f"Target column width (default: {DEFAULT_COLS}).",
    )
    args = ap.parse_args()

    changed: list[str] = []
    for path_str in args.files:
        path = Path(path_str)
        if not path.exists():
            print(f"texwrap: {path}: file not found", file=sys.stderr)
            continue
        original = path.read_text(encoding="utf-8")
        result = process(original, args.cols)
        if result != original:
            changed.append(str(path))
            if not args.check:
                path.write_text(result, encoding="utf-8")
                print(f"texwrap: formatted  {path}")
        else:
            if not args.check:
                print(f"texwrap: unchanged   {path}")

    if args.check:
        if changed:
            print("texwrap: the following files need formatting:")
            for f in changed:
                print(f"  {f}")
            return 1
        print("texwrap: all files are properly formatted")

    return 0


if __name__ == "__main__":
    sys.exit(main())
