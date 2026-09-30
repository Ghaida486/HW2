# Understand Between the Pages

Read one section at a time. The purpose is to explain the program in your own words, not memorize a script.

## 1. Start with the idea

This is a small reading-list app in Terminal. You choose an action, a workflow coordinates the necessary components, and the result appears on screen or is saved in a file. Gum supplies menus and input boxes. Bash connects the steps. A small Python helper safely reads and writes CSV.

**Architecture means how those responsibilities are divided and connected.**

```text
You choose an action
        ↓
UI: asks questions and displays answers
        ↓
Workflow: coordinates the steps
        ↓
Book or recommendation components: do specific tasks
        ↓
Data layer: reads or changes your saved library
        ↓
books.csv: remembers your books after the app closes
```

Some paths are shorter: Browse goes from the workflow directly to the data layer. The diagram describes the separation of responsibilities, not a requirement that every action visit every layer.

## 2. The three kinds of saved information

| File | What it means | Example |
|---|---|---|
| `books/catalog.tsv` | Reference titles the app knows about; 23 books currently | Piranesi, Susanna Clarke, Fantasy, 2020, information link |
| `data/books.csv` | Your saved library; five demonstration books currently | Piranesi plus want-to-read status and sample rating 1 |
| `data/interests.txt` | Genres you want suggestions about | Fiction, Mystery, Fantasy |

CSV separates fields with commas and quoting; TSV separates them with tabs. Neither is an AI model. They are text files containing structured records.

The five ratings were assigned randomly for demonstration. They are not actual reviews. Rating 0 means unrated; `want-to-read` is a separate status, so a number next to that label is not a count of readers. The app permits ratings with any status.

## 3. What happens at startup?

Run `bash app.sh` from this folder.

1. `app.sh` finds its own location and stores it as `ROOT`.
2. It checks that `gum` and `python3` are available. If one is missing, it displays an installation message and stops.
3. `exec bash .../ui/main_menu.sh` hands control to the menu.
4. The menu repeats inside `while true`. Gum returns the selected label, and `case` chooses which screen to call.
5. Quit ends the program. Other actions finish and offer a return to the menu.

This is why `app.sh` can stay small: it launches the interface; the menu and other files contain the rest of the behavior.

## 4. Trace Search from input to output

Try **Search Library → Piranesi**. This does not change your data.

```text
You type Piranesi
 → ui/library_screen.sh captures the term
 → workflows/manage_library.sh receives the search action
 → books/search_books.sh forwards the term
 → data/book_database.sh reads books.csv and finds matching rows
 → matching records return to the library screen
 → Gum lets you select one and the screen displays its details
```

- **Input:** the search text `Piranesi`.
- **Processing:** case-insensitive substring matching across the saved record fields.
- **Output:** the matching library record displayed on screen.
- **Storage change:** none, unless you later choose a status or rating update.

The search component can also accept a line from a pipe:

```bash
echo Piranesi | bash books/search_books.sh
```

`echo` produces the word; `|` gives it to the next script as input. The output is a tab-separated record, not the interactive menu.

## 5. Trace Add Book

The library screen gathers title, author, genre and status. The library workflow asks the metadata component for a catalog match. When there is a match, author/genre/year/link come from the catalog. Otherwise, it uses the supplied author/genre and marks unknown fields. It then asks the database component to validate and save the book with an initial rating of 0. Duplicate title/author pairs and invalid fields are rejected. The UI prints a saved message only after the operation succeeds.

Only `data/book_database.sh` accesses the personal-library CSV during application operation. It writes a temporary CSV and replaces the original after the write completes. This reduces the chance of leaving a half-written file; it is not multi-user database locking.

## 6. Trace Get Recommendations

### Three different questions

| Strategy | Question it answers | What it uses |
|---|---|---|
| History | Which catalog books share an author or genre with my qualifying saved books? | Library through the database component; catalog |
| Interests | Which catalog books match my selected genres? | Interests; catalog |
| Discovery | Which catalog genres are outside both my saved library and my selected interests? | Library, interests, catalog |

These are independent rule-based programs. They do not ask a live AI service for suggestions. Codex helped build the app; it does not run inside the app.

### How they run together

The recommendation workflow starts all three scripts using `&`. Each writes to a separate temporary file. `$!` captures each process ID. While tasks are active, the workflow prints status messages; `kill -0` checks whether a process exists without stopping it. `wait` collects the completion result of each process. If any strategy fails, the workflow reports failure instead of silently displaying a partial shortlist.

**Parallelization** means the strategies can work at the same time. It does not guarantee this tiny offline example is faster: launching processes has overhead, and the catalog is small.

Once all three finish:

```text
History candidates ───┐
Interest candidates ──┼→ cat combines them → | → refinement → shortlist → UI
Discovery candidates ┘
```

**The pipe passes data; it does not save the books to your library.** Refinement reads candidates from stdin (incoming data) and writes the shortlist to stdout (outgoing data). Progress uses stderr, a separate channel, so it cannot be mistaken for a book record. Candidate output is collected before refinement; progress is live, but final recommendations are not displayed incrementally as each candidate is generated.

### What the scores actually mean

| Match | Candidate score |
|---|---:|
| Same author as a qualifying saved book | 5 |
| Same genre as a qualifying saved book | 4 |
| Matches selected interests | 3 |
| Explores a new genre | 2 |

These are **recommendation scores**, not your 1–5 book ratings. A saved book qualifies for history when its rating is 0 or at least 3. Ratings of 3, 4, and 5 all qualify equally; rating 5 does not multiply the candidate score. Status is stored but is not used as a ranking weight.

Refinement sorts candidates, identifies a book by title plus author, removes books already saved, and keeps the strongest occurrence of a duplicate. It returns at most five books, puts an available interest match first, and reserves a slot for a remaining discovery candidate when available. Interest membership is retained even when a stronger history record wins deduplication. Thus the final list is not simply the five highest scores: the discovery slot deliberately adds variety. Scores are not added across strategies. Repeating a request with unchanged inputs gives the same results.

### A concrete example from your five-book library

`And Then There Were None` has a sample rating of 5, so Agatha Christie qualifies as a history author. `The Murder of Roger Ackroyd` shares that author and receives a candidate score of 5. It is not one of the five saved books, so it can remain after refinement. `And Then There Were None` itself is excluded because it is already saved.

A new-genre candidate such as `A Brief History of Time` can occupy the discovery slot because Science is outside your current library genres and selected interests. A science-fiction book by Ursula K. Le Guin can also appear as a history result: she wrote your saved `A Wizard of Earthsea`. Sharing an author does not require sharing a genre.

`Pride and Prejudice` has sample rating 2, so it does not supply history evidence. Fiction can still produce candidates through the separate interests strategy. Low ratings do not ban an entire genre from all recommendations.

### Saving a suggestion

The UI asks whether to save the selected book. If you choose Yes, it calls the same add workflow and database component used by Add Book. The new record is want-to-read with rating 0. On the next request, refinement excludes it from recommendations.

**Surprise Me** runs the same three-strategy workflow, but passes only the discovery output to refinement. It is deterministic, not a random selection.

## 7. Every application file: input, work, output, connection

| File | Input | What it does and returns | Connects to |
|---|---|---|---|
| `app.sh` | No user arguments required | Checks tools; launches menu | Main menu |
| `ui/main_menu.sh` | Gum selection | Routes actions; edits interest preferences; loops until Quit | Two screen scripts; interests file and catalog genres |
| `ui/library_screen.sh` | browse/add/search action, then user input | Displays records; gathers fields; offers status/rating updates | Library workflow |
| `ui/recommendations_screen.sh` | all/discovery mode and selections | Shows progress, shortlist, explanation, save prompt | Recommendation workflow and library add workflow |
| `workflows/manage_library.sh` | Action plus arguments | Coordinates lookup/search/storage | Metadata, search, database |
| `workflows/get_recommendations.sh` | Interests and optional mode | Coordinates processes, waits, combines, refines; returns TSV shortlist | Three strategies, refinement |
| `books/fetch_book_metadata.sh` | Title, optional author | Exact case-insensitive lookup; returns five catalog fields or no match | Catalog |
| `books/search_books.sh` | Search term as argument or stdin | Returns matching saved records | Database search |
| `recommendations/recommend_from_history.sh` | Library records | Returns scored shared-author/genre candidates | Database list; catalog |
| `recommendations/recommend_from_interests.sh` | Comma-separated genres | Returns scored genre matches | Interests default; catalog |
| `recommendations/recommend_for_discovery.sh` | Interests and library records | Returns candidates from unfamiliar genres | Database list; catalog |
| `recommendations/refine_recommendations.sh` | Piped candidate records | Returns deduplicated, filtered shortlist | Database list; stdout to UI through workflow |
| `data/book_database.sh` | list/add/search/exists/update and arguments | Validates and stores records; returns TSV or success/error status | Personal-library CSV |
| `data/books.csv` | Saved records | Persistent library storage | Database only during application operation |
| `books/catalog.tsv` | Curated reference records | Offline book details and candidate pool | Metadata and strategies; menu genre list |
| `data/interests.txt` | Chosen genres | Persistent preference storage | Menu and recommendation workflow/strategies |
| `tests/test_app.py` | Temporary fixtures | Checks the components and complete workflows; reports test results | Bash scripts; temporary test CSVs |

Supporting documents: README explains setup/design; DEMO_GUIDE prepares the recording; REQUIREMENTS maps the rubric; SUBMISSION explains GitHub/class steps; ASSIGNMENT preserves the original instructions; LICENSE preserves licensing terms. `.gitignore` keeps Mac housekeeping and Python cache files out of Git.

## 8. Why not write everything in one file?

The menu deals with interaction. The workflow deals with ordering tasks. Components handle one operation. The database handles storage. For example, the database can change its storage implementation later without teaching every screen how to parse CSV. This is the reason for the architecture, not just a folder naming exercise.

Python is used inside the data-layer script because CSV titles may contain commas and quotation marks. Python's standard CSV reader/writer handles that reliably. The rest is Bash with small text-processing commands such as awk, sort, and cut.

## 9. Read the syntax without memorizing it

| Syntax | Meaning here |
|---|---|
| `ROOT=$(...)` | Run a command and store the project location |
| `"$1"` / `"$@"` | First argument / all arguments, keeping spaces together |
| `case ... esac` | Choose the instructions for a matching option |
| `while true` | Repeat the menu until an exit occurs |
| `&`, `$!`, `wait` | Start in background, remember process ID, collect completion |
| `> file` | Write normal output to a file |
| `|` | Pass normal output into the next program |
| `>&2` | Send progress/errors separately from normal data |
| `IFS=$'	' read -r ...` | Split a tab-separated record into named values |
| `awk -F '	'` | Process records using tabs as field separators |
| `set -euo pipefail` | Enable checks for many failed commands, unset variables, and failed pipelines |
| `trap ... EXIT` | Run cleanup when the script exits |

## 10. Practice one answer at a time

1. Where do your five books live? **books.csv, accessed through book_database.sh.**
2. Why are there 23 catalog books but only five library books? **The catalog supplies reference data; the library stores selected books.**
3. Does choosing a suggestion automatically save it? **No; the UI asks first.**
4. How do you know tasks run in parallel? **Three launches use &, their IDs are stored, and wait synchronizes them.**
5. Why keep progress out of stdout? **The next program needs book records, not status text.**
6. Is this an AI recommendation service? **No; it uses explicit rules and a local catalog.**
7. What is a limitation? **A small fixed catalog, exact metadata matching, and no support for concurrent app instances.**
8. Can you trace Search without looking? **Screen → workflow → search component → database → results back to screen.**

Next, open a file with `cat` (read-only) and explain its input, work, output and next caller. If any term is unclear, pause there before moving to another file.
