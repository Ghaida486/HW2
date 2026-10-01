#!/bin/bash
# Match exact, comma-separated catalog genres; output candidates as TSV.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
interests=${1:-$(cat "$ROOT/data/interests.txt")}
awk -F '\t' -v interests="$interests" 'BEGIN {
  n=split(tolower(interests), terms, ",")
  for(i=1;i<=n;i++){gsub(/^[[:space:]]+|[[:space:]]+$/, "", terms[i]); wanted[terms[i]]=1}
}
NR>1 && (tolower($3) in wanted) {print $0 "\tMatches your interests: " $3 "\t3"}
' "$ROOT/books/catalog.tsv"
