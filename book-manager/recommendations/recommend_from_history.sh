#!/bin/bash
# Prefer authors/genres from positively rated books (or unrated saved books).
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
LIBRARY=$(bash "$ROOT/data/book_database.sh" list)
export LIBRARY
awk -F '\t' 'BEGIN {
  n=split(ENVIRON["LIBRARY"], lines, "\n")
  for(i=1;i<=n;i++) {
    split(lines[i], b, "\t")
    if(b[1]!="" && (b[5]==0 || b[5]>=3)) {authors[tolower(b[2])]=1; genres[tolower(b[3])]=1}
  }
}
NR>1 {
  if(tolower($2) in authors) print $0 "\tShared author with your library\t5"
  else if(tolower($3) in genres) print $0 "\tMatches a genre in your library\t4"
}' "$ROOT/books/catalog.tsv"
