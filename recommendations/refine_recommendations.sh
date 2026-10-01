#!/bin/bash
# stdin: candidate TSV records. stdout: up to five unique, unsaved books.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
LIBRARY=$(bash "$ROOT/data/book_database.sh" list)
export LIBRARY
# Keep the strongest record, but remember interest matches across duplicates.
LC_ALL=C sort -t $'\t' -k7,7nr | awk -F '\t' 'BEGIN {
  n=split(ENVIRON["LIBRARY"], lines, "\n")
  for(i=1;i<=n;i++){split(lines[i], b, "\t"); saved[tolower(b[1]) SUBSEP tolower(b[2])]=1}
}
NF==7 {
  key=tolower($1) SUBSEP tolower($2)
  if (key in saved) next
  if ($6 ~ /^Matches your interests:/) interest[key]=1
  if (key in records) next
  records[key]=$0; ordered[++total]=key
  if ($6 ~ /^Explore a new genre:/) discovery[key]=1
}
END {
  for(i=1;i<=total;i++) {
    key=ordered[i]
    if (!preferred && interest[key]) preferred=key
    if (!explore && discovery[key]) explore=key
  }
  count=0
  if(preferred){print records[preferred]; used[preferred]=1; count++}
  limit=(explore ? 4 : 5)
  for(i=1;i<=total && count<limit;i++) {
    key=ordered[i]
    if(used[key] || discovery[key]) continue
    print records[key]; used[key]=1; count++
  }
  if(explore && !used[explore]){print records[explore]; used[explore]=1; count++}
  for(i=1;i<=total && count<5;i++) {
    key=ordered[i]
    if(used[key]) continue
    print records[key]; used[key]=1; count++
  }
}'
