# Between the Pages

A small terminal book manager personalized for **fiction, mystery, and fantasy**.
Add and search books, track reading status and ratings, and discover your next read.

## Run

Requires Bash, Python 3, and [Gum](https://github.com/charmbracelet/gum).
On a Mac with Homebrew, install missing dependencies with `brew install gum python`.
Bash is included with macOS. No API key, AI subscription, or internet connection is
required to run the app. The optional book-information links open external pages.

Open this project folder in VS Code, choose **Terminal → New Terminal**, then run:

```bash
bash app.sh
```

Use arrow keys and Enter in menus. For **Edit Interests**, Space selects genres and
Enter saves. Escape cancels a selection. Ratings run from 1 to 5; 0 means unrated.
The four statuses are `want-to-read`, `owned`, `reading`, and `finished`.

Try adding **The Hobbit** (leave the author blank to use the catalog), browse your
library, then request recommendations. The library starts empty: no books are
claimed as your reading history. If a title is outside the catalog, supply its
author and genre. Unknown publication years and links remain `Unknown`.

## Architecture

`app.sh` starts the Gum UI in `ui/`. Screens call `workflows/`, which coordinate
book components, recommendation components, and the data layer. Only
`data/book_database.sh` reads or writes `data/books.csv`. It uses a short embedded
Python helper for CSV parsing, so commas and quotes in titles are handled
correctly; the application is otherwise composed of small Bash programs. The
recommendation workflow starts three background processes with `&`, records their
PIDs with `$!`, monitors progress, and synchronizes with `wait`. It combines their
TSV results and uses `|` to feed the refinement component. Progress goes to stderr;
book records go to stdout so they can be piped without mixing in status messages.

## Personalization

The default interests are fiction, mystery, and fantasy, with a purple menu and
the name **Between the Pages**. Interests can be changed from the menu. History
recommendations favor authors and genres from saved books, ignoring ratings below
3 except 0 (unrated). Interest recommendations match chosen genres. Discovery
recommendations explore genres outside both the library and chosen interests.
The five-book shortlist reserves one discovery slot when available. **Surprise Me**
is an extra feature that shows only discovery suggestions, with an option to save
one to the want-to-read list.

## Recommendation limits

This is a transparent, rule-based recommendation system, not a live AI service.
It uses the small, bundled `books/catalog.tsv` and does not query a book API.
Metadata lookup requires an exact title and, when supplied, exact author, ignoring
case. Recommendations are deterministic, not random; expand the catalog for more
variety. A title/author pair identifies a book. The app assumes one person runs
one copy at a time; simultaneous writes from several app instances are unsupported.
Tabs, newlines, and control characters are rejected in book fields because the
components exchange one tab-separated record per line.

## Tests

```bash
python3 tests/test_app.py
```

Tests use a temporary database and never modify your library. They check persistence,
CSV punctuation, duplicate prevention, updates, invalid inputs, search through a
pipe, each strategy, refinement, failure handling, and the complete workflow.

## Useful terminal examples

```bash
bash workflows/manage_library.sh add "The Hobbit" "J. R. R. Tolkien" reading
bash books/search_books.sh fantasy
echo mystery | bash books/search_books.sh
bash workflows/manage_library.sh update "The Hobbit" "J. R. R. Tolkien" rating 5
bash workflows/get_recommendations.sh "Fiction, Mystery, Fantasy"
```

These commands modify or inspect your real library. For experiments, set
`BOOK_DB` to a different CSV path. Run the menu from any directory by passing the
full path to `app.sh`; scripts locate their sibling files themselves.

## Data formats

Storage CSV: `title,author,genre,status,rating,link,year`.
Database output uses the same field order, separated by tabs and without a header.
Catalog: `title,author,genre,year,link`, separated by tabs with a header.
Recommendation output: `title,author,genre,year,link,reason,score`, separated by tabs.
Scores: shared author 5, shared genre 4, interest 3, discovery 2.
`book_database.sh add` accepts seven arguments in storage field order;
`update` accepts title, author, field (`status` or `rating`), and new value.

## Demo video — still to record

**The required narrated demo has not been recorded yet.** Use
[DEMO_GUIDE.md](DEMO_GUIDE.md) to record your own short walkthrough. Add a visible
link to your actual video here before submitting. This guide is not a replacement
for the video.

## Submission — still to complete

Read [WALKTHROUGH.md](WALKTHROUGH.md) until you can explain each file, then follow
[SUBMISSION.md](SUBMISSION.md) to publish to your existing HW2 GitHub repository, attach the
narrated video, and submit your repository URL. This project has not been uploaded
or submitted on your behalf.

## Starter attribution

Based on the [course starter](https://github.com/onexi/ps02), with its LICENSE retained.
Implementation developed with Codex assistance. See [REQUIREMENTS.md](REQUIREMENTS.md)
for the assignment mapping and the remaining video/submission tasks.
