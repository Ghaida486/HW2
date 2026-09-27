# Understand your homework

Start by running `bash app.sh`. Open each file in VS Code while reading this guide.
The program was built with Codex assistance. Review, adapt, and explain it yourself.

## The files, in ordinary language

| File | Input | Job | Output |
|---|---|---|---|
| `app.sh` | No arguments | Check Gum/Python, start menu | Running interface |
| `ui/main_menu.sh` | Menu selection | Choose a screen; edit interests | The requested screen |
| `ui/library_screen.sh` | browse, add, or search | Ask questions, display books, offer updates | Prompts and book details |
| `ui/recommendations_screen.sh` | Optional discovery mode | Display shortlist and offer save | Suggestions or saved book |
| `workflows/manage_library.sh` | Action and book fields | Coordinate metadata, search, database | Book records or completed change |
| `workflows/get_recommendations.sh` | Interests and optional mode | Run strategies, wait, combine, refine | Up to five suggestion records |
| `books/fetch_book_metadata.sh` | Title and optional author | Look up catalog details | Five tab-separated fields; exit 1 if unknown |
| `books/search_books.sh` | Search term, or a piped line | Ask database to search | Matching library records |
| `recommendations/recommend_from_history.sh` | Library via database | Match authors and genres | Scored candidates |
| `recommendations/recommend_from_interests.sh` | Comma-separated genres | Match chosen genres | Scored candidates |
| `recommendations/recommend_for_discovery.sh` | Interests and library | Find unfamiliar genres | Scored discovery candidates |
| `recommendations/refine_recommendations.sh` | Piped candidates | Exclude saved books, deduplicate, rank | Up to five suggestions |
| `data/book_database.sh` | Operation and arguments | Validate, read, write library | Tab-separated records or success/error |
| `data/books.csv` | Saved book rows | Keep books between runs | Persistent storage |
| `data/interests.txt` | Selected genre names | Keep preferences between runs | Default interests |
| `books/catalog.tsv` | Curated book records | Supply offline metadata and candidates | Read by book/recommendation components |
| `tests/test_app.py` | Temporary test libraries | Check that behavior works | Test report |

## Follow one complete action: Add Book

1. `app.sh` launches `ui/main_menu.sh`.
2. You select **Add Book**. The menu starts `ui/library_screen.sh add`.
3. The screen asks for title, author, genre, and reading status.
4. It passes those values to `workflows/manage_library.sh add`.
5. The workflow asks `books/fetch_book_metadata.sh` for known catalog information.
6. If found, the catalog supplies genre, year, author, and a link. Otherwise, your
   supplied fields are kept and unknown fields are marked honestly.
7. The workflow asks `data/book_database.sh add` to validate and save the book.
8. The database rejects duplicates or invalid values, or writes a new CSV safely
   using a temporary file followed by replacement.
9. The UI prints a confirmation only after saving succeeds.

Why have so many files? Each has one understandable job. The screen does not need
to know how CSV is stored, and the database does not need to know menu colors.

## Follow recommendations

1. The UI calls the recommendation workflow.
2. Three scripts start with `&`, so they can work concurrently.
3. `$!` gives the process ID of the most recently started background script.
4. The workflow stores these IDs in an array. `kill -0` checks whether a process
   still exists; it does not kill the process.
5. Status messages go to stderr. Each strategy's book records go to its own
   temporary file, preventing their output from colliding.
6. `wait` collects each process's exit status. If a strategy fails, the workflow
   reports failure and does not present an incomplete result as success.
7. `cat` combines the files. `|` gives those records to the refinement script.
8. Refinement sorts scores, removes duplicates and already-saved books, and limits
   the list. One discovery slot encourages exploration.
9. The UI lets you choose a suggestion and save it through the usual add workflow.
10. A cleanup trap removes temporary files when the workflow finishes or is interrupted.

The offline strategies are fast, so progress may last less than a second. They
still run as separate background processes; no artificial delay is needed.

## Small syntax guide

- `#!/bin/bash`: run this file using Bash.
- `set -euo pipefail`: stop on many failures, catch unset variables, and detect
  failed commands inside pipelines. Explicit `if`/`||` checks handle expected errors.
- `ROOT=...`: save the project's location so paths work from any current folder.
- `"$1"`: first argument; `"$@"`: all arguments, preserving spaces.
- `$(command)`: run a command and capture its normal output.
- `IFS=$'\t' read -r ...`: split one line at tabs into named variables.
- `awk -F '\t'`: process text as tab-separated fields (`$1`, `$2`, etc. inside awk).
- `> file`: put normal output into a file, replacing that file's prior contents.
- `>&2`: send a message to the error/progress stream instead of the data stream.
- `&`: start a background task. `$!`: remember its ID. `wait`: collect its result.
- `|`: pass normal output from one program into another.
- `case`: choose which action to perform.
- `exec`: replace the current process with the next program.
- Exit status `0`: success. Nonzero: error or no match, depending on the command.

## Why the small Python section?

CSV can contain quoted commas, such as a title `A "Curious", Book`. Splitting on
commas with ordinary shell tools breaks those records. Python's standard `csv`
module handles that reliably. It lives inside the data-layer script, preserving
the rule that no other application component accesses the library CSV.

## Practice explaining

- Which file starts the app? Which file saves a book?
- How does the app remember books after closing Terminal?
- How do the three recommendation strategies differ?
- Point to `&`, `$!`, `wait`, and `|` and explain each one.
- Why is progress on stderr rather than stdout?
- Why can a newly added book appear in search but not in recommendations?
- What happens if a title is outside the small catalog?
- What would you need to change to add a live book API later?

Be honest: the catalog and rules are not live AI agents, and the app does not
fetch fresh metadata online. AI use is optional in the assignment.
