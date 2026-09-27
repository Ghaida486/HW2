#!/bin/bash
# Display progress from the workflow and let the user save a recommendation.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
echo 'Looking through the offline book catalog…'
rows=$(bash "$ROOT/workflows/get_recommendations.sh" "$(cat "$ROOT/data/interests.txt")" "${1:-all}")
[[ -n "$rows" ]] || { echo 'No new matches. Try changing interests or expanding books/catalog.tsv.'; exit 0; }
labels=$(printf '%s\n' "$rows" | awk -F '\t' '{printf "%d. %s — %s (%s)\n",NR,$1,$2,$6}')
choice=$(printf '%s\n' "$labels" | gum choose --header 'Your shortlist — choose a book, or Esc to return') || exit 0
index=${choice%%.*}
row=$(printf '%s\n' "$rows" | sed -n "${index}p")
IFS=$'\t' read -r title author genre year link reason score <<< "$row"
printf '\n%s by %s\n%s | %s\nWhy: %s\nMore information: %s\n\n' "$title" "$author" "$genre" "$year" "$reason" "$link"
if gum confirm 'Save to your want-to-read list?'; then
  bash "$ROOT/workflows/manage_library.sh" add "$title" "$author" want-to-read "$genre"
  echo 'Saved to your library.'
fi
