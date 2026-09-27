#!/bin/bash
# stdin: title,author,genre,year,link,reason,score (tabs). stdout: up to 5 rows.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
LIBRARY=$(bash "$ROOT/data/book_database.sh" list)
export LIBRARY
# Sort strongest candidates first. Preserve one discovery slot for variety.
LC_ALL=C sort -t $'\t' -k7,7nr | awk -F '\t' 'BEGIN {
  n=split(ENVIRON["LIBRARY"], lines, "\n")
  for(i=1;i<=n;i++){split(lines[i], b, "\t"); saved[tolower(b[1]) SUBSEP tolower(b[2])]=1}
}
NF==7 {
  key=tolower($1) SUBSEP tolower($2)
  if ((key in saved) || seen[key]++) next
  if ($6 ~ /^Explore a new genre:/) {if(!discovery) discovery=$0; extra[++ne]=$0}
  else picks[++np]=$0
}
END {
  limit=(discovery ? 4 : 5); count=0
  for(i=1;i<=np && count<limit;i++){print picks[i]; count++}
  if(discovery){print discovery; count++}
  for(i=2;i<=ne && count<5;i++){print extra[i]; count++}
}'
