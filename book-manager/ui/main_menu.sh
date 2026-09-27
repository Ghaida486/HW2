#!/bin/bash
# Keep navigation in the UI; hand off actual work to the other components.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
export GUM_CHOOSE_CURSOR_FOREGROUND=141 GUM_CHOOSE_HEADER_FOREGROUND=141
while true; do
  gum style --foreground 141 --border rounded --padding '1 3' 'Between the Pages' 'Your fiction, mystery & fantasy shelf'
  printf 'Interests: %s\n\n' "$(cat "$ROOT/data/interests.txt")"
  choice=$(gum choose --header 'What would you like to do?' 'Browse Library' 'Add Book' 'Search Library' 'Get Recommendations' 'Surprise Me' 'Edit Interests' 'Quit') || exit 0
  case "$choice" in
    'Browse Library') bash "$ROOT/ui/library_screen.sh" browse || echo 'Could not complete that action.' ;;
    'Add Book') bash "$ROOT/ui/library_screen.sh" add || echo 'Book was not saved. Check the message above.' ;;
    'Search Library') bash "$ROOT/ui/library_screen.sh" search || echo 'Search failed.' ;;
    'Get Recommendations') bash "$ROOT/ui/recommendations_screen.sh" || echo 'Recommendations failed.' ;;
    'Surprise Me') bash "$ROOT/ui/recommendations_screen.sh" discovery || echo 'Discovery failed.' ;;
    'Edit Interests')
      genres=$(tail -n +2 "$ROOT/books/catalog.tsv" | cut -f3 | sort -u)
      if selected=$(printf '%s\n' "$genres" | gum choose --no-limit --header 'Space selects genres; Enter saves'); then
        if [[ -n "$selected" ]]; then printf '%s\n' "$selected" | paste -sd, - > "$ROOT/data/interests.txt"; fi
      fi ;;
    'Quit') echo 'Happy reading!'; exit 0 ;;
  esac
  gum input --placeholder 'Press Enter to return to the menu' >/dev/null || exit 0
done
