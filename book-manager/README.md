# Between the Pages

Save books, search your library, update reading status and ratings, and get personalized suggestions in Terminal.

## Run

In this folder, run:

```bash
bash app.sh
```

Requires Bash, Gum, and Python 3. On a Mac with Homebrew, use `brew install gum python` for missing tools. Use arrow keys and Enter in menus; press X to select genres in **Edit Interests**. After an operation, press Enter to return to the menu.

## Architecture

The app follows `UI → Workflows → Book/Recommendation Components → Data Layer → Storage`. `app.sh` checks dependencies and opens a Gum menu; screens collect user choices and display results, while workflows coordinate the work. Book components search the library and enrich known titles from a bundled catalog. Three independent Bash recommendation programs examine saved authors/genres, selected interests, and unfamiliar genres. The recommendation workflow starts them with `&`, records their process IDs with `$!`, waits for completion with `wait`, and pipes their combined output through refinement to remove duplicates and saved books and produce a ranked shortlist. Progress messages go to stderr so stdout remains usable as data. Only `data/book_database.sh` accesses `books.csv`; an embedded Python CSV helper handles quoted commas reliably. This separation keeps each component focused and allows it to be tested independently.

## Personalization

Between the Pages reflects my interest in fiction, mystery, and fantasy through its default genres, curated catalog, and purple terminal interface. I can edit my interests and track each book as owned, want-to-read, reading, or finished. History recommendations use authors and genres from books rated 3–5 or left unrated; the final shortlist puts an available interest match first and reserves a discovery slot, and **Surprise Me** shows only unfamiliar-genre suggestions. The repository includes example library books with sample ratings to demonstrate the features; these are demonstration data, not claims about books I have read or my actual reviews.

## Your library versus the catalog

- `data/books.csv` holds the books you have saved, their reading status, and their rating. This copy includes nine saved books; new books are added through the app.
- `books/catalog.tsv` holds 23 reference books with title, author, genre, publication year, and an information link. It supplies metadata and recommendation candidates.
- `data/interests.txt` stores your selected genres. The library and catalog are separate: saving a recommendation adds it to the library, and future suggestions exclude it.

A book outside the catalog can still be saved with a supplied author and genre; its unknown year and link remain `Unknown`. Known-title matching is exact apart from case. New books start at rating 0 (unrated); ratings 1–5 and reading status are separate fields.

## Check and learn

```bash
python3 tests/test_app.py
```

The 21 integration tests use temporary data. See [WALKTHROUGH.md](WALKTHROUGH.md) for input/output traces and recommendation rules, and [REQUIREMENTS.md](REQUIREMENTS.md) for assignment coverage. The app is primarily Bash, with Python used inside the database component for reliable CSV handling. It assumes a single app instance and does not call live AI or external metadata services.

## Demo and submission

[**Watch the demo video**](../HW2_DEMO_tiny.mp4). The recording is included in the repository and linked from the main README. See [SUBMISSION.md](SUBMISSION.md) for the final class-sheet submission step.

Based on the [course starter](https://github.com/onexi/ps02), with its LICENSE retained. Developed with Codex assistance.

## Delete a saved book

Choose **Browse Library** or **Search Library**, select a book, then choose **Delete book**. Confirm Yes to remove it, or No to keep it. Deletion removes the saved record (including its status and rating), not the catalog entry. A deleted catalog book can appear in future recommendations again. The UI asks for confirmation, the workflow routes the request, and the database component performs the deletion.
