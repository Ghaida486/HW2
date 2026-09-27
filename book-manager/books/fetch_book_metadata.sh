#!/bin/bash
# Exact title + optional author lookup in the bundled catalog; no invented metadata.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
[[ -n "${1:-}" ]] || { echo 'A book title is required.' >&2; exit 1; }
awk -F '\t' -v title="$1" -v author="${2:-}" '
  NR>1 && tolower($1)==tolower(title) && (author=="" || tolower($2)==tolower(author)) {print; found=1; exit}
  END {if (!found) exit 1}
' "$HERE/catalog.tsv"
