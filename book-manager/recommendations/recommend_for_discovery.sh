#!/bin/bash
# Explore genres outside both saved books and the selected interests.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
interests=${1:-$(cat "$ROOT/data/interests.txt")}
LIBRARY=$(bash "$ROOT/data/book_database.sh" list)
export LIBRARY
awk -F '\t' -v interests="$interests" 'BEGIN {
  n=split(tolower(interests), terms, ",")
  for(i=1;i<=n;i++){gsub(/^[[:space:]]+|[[:space:]]+$/, "", terms[i]); known[terms[i]]=1}
  n=split(ENVIRON["LIBRARY"], lines, "\n")
  for(i=1;i<=n;i++){split(lines[i], b, "\t"); known[tolower(b[3])]=1}
}
NR>1 && !(tolower($3) in known) {print $0 "\tExplore a new genre: " $3 "\t2"}
' "$ROOT/books/catalog.tsv"
