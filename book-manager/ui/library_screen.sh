#!/bin/bash
# UI only: prompts and display. All library operations go through the workflow.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
MANAGE="$ROOT/workflows/manage_library.sh"
case "${1:-browse}" in
  add)
    title=$(gum input --header 'Book title (required)') || exit 0
    [[ -n "$title" ]] || exit 0
    author=$(gum input --header 'Author (leave blank for a catalog title)') || exit 0
    genre=$(gum input --header 'Genre if outside catalog' --value 'Fiction') || exit 0
    status=$(gum choose --header 'Reading status' want-to-read owned reading finished) || exit 0
    bash "$MANAGE" add "$title" "$author" "$status" "$genre"
    printf 'Saved: %s\n' "$title"
    exit 0 ;;
  search)
    term=$(gum input --header 'Search title, author, genre, or status') || exit 0
    rows=$(bash "$MANAGE" search "$term") ;;
  browse) rows=$(bash "$MANAGE" list) ;;
  *) echo 'Unknown library screen.' >&2; exit 1 ;;
esac
[[ -n "$rows" ]] || { echo 'No books found. Try Add Book.'; exit 0; }
# Numbered labels let selection safely map back to the original TSV row.
labels=$(printf '%s\n' "$rows" | awk -F '\t' '{printf "%d. %s — %s [%s; rating %s/5]\n",NR,$1,$2,$4,$5}')
choice=$(printf '%s\n' "$labels" | gum choose --header 'Choose a book (Esc to return)') || exit 0
index=${choice%%.*}
row=$(printf '%s\n' "$rows" | sed -n "${index}p")
IFS=$'\t' read -r title author genre status rating link year <<< "$row"
printf '\n%s\nBy %s\nGenre: %s | Year: %s\nStatus: %s | Rating: %s/5 (0 = unrated)\nLink: %s\n\n' "$title" "$author" "$genre" "$year" "$status" "$rating" "$link"
action=$(gum choose 'Change status' 'Rate book' 'Back') || exit 0
case "$action" in
  'Change status')
    value=$(gum choose want-to-read owned reading finished) || exit 0
    bash "$MANAGE" update "$title" "$author" status "$value"; echo 'Status updated.' ;;
  'Rate book')
    value=$(gum choose --header '0 = unrated; 5 = loved it' 0 1 2 3 4 5) || exit 0
    bash "$MANAGE" update "$title" "$author" rating "$value"; echo 'Rating updated.' ;;
esac
