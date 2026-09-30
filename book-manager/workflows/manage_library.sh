#!/bin/bash
# Coordinate book lookup/search and the database; do not access the CSV here.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
DB="$ROOT/data/book_database.sh"
command=${1:-}; shift || true
case "$command" in
  list|update|exists|delete) bash "$DB" "$command" "$@" ;;
  search) bash "$ROOT/books/search_books.sh" "$@" ;;
  add)
    [[ $# -ge 3 ]] || { echo 'Usage: manage_library.sh add TITLE AUTHOR STATUS [GENRE]' >&2; exit 1; }
    title=$1; author=$2; status=$3; genre=${4:-Unknown}; year=Unknown; link=Unknown
    if metadata=$(bash "$ROOT/books/fetch_book_metadata.sh" "$title" "$author"); then
      IFS=$'\t' read -r title author genre year link <<< "$metadata"
    fi
    [[ -n "$author" ]] || { echo 'Please supply an author for a book outside the catalog.' >&2; exit 1; }
    bash "$DB" add "$title" "$author" "$genre" "$status" 0 "$link" "$year"
    ;;
  *) echo 'Usage: manage_library.sh list|search|add|update|exists|delete ...' >&2; exit 1 ;;
esac
