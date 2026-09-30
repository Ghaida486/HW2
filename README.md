# HW2 — Between the Pages

A personal terminal app for saving books, searching a reading list, tracking status and ratings, and finding what to read next. The application is in [`book-manager/`](book-manager/).

## Run

Requires **Bash, Gum, and Python 3**. On macOS with Homebrew, install missing dependencies with `brew install gum python`. Bash is included with macOS.

From the cloned `HW2` repository:

```bash
cd book-manager
bash app.sh
```

For a fresh copy: `git clone https://github.com/Ghaida486/HW2.git`, then `cd HW2/book-manager` and `bash app.sh`.
Use arrow keys and Enter to choose an action. In **Edit Interests**, X selects genres and Enter saves. Book data persists between runs.

## Architecture

The app follows `UI → Workflows → Book/Recommendation Components → Data Layer → Storage`. `app.sh` checks dependencies and opens a Gum menu; screens collect user choices and display results, while workflows coordinate the work. Book components search the library and enrich known titles from a bundled catalog. Three independent Bash recommendation programs examine saved authors/genres, selected interests, and unfamiliar genres. The recommendation workflow starts them with `&`, records their process IDs with `$!`, waits for completion with `wait`, and pipes their combined output through refinement to remove duplicates and saved books and produce a ranked shortlist. Progress messages go to stderr so stdout remains usable as data. Only `data/book_database.sh` accesses `books.csv`; an embedded Python CSV helper handles quoted commas reliably. This separation keeps each component focused and allows it to be tested independently.

## Personalization

Between the Pages reflects my interest in fiction, mystery, and fantasy through its default genres, curated catalog, and purple terminal interface. I can edit my interests and track each book as owned, want-to-read, reading, or finished. History recommendations use authors and genres from books rated 3–5 or left unrated; the final shortlist puts an available interest match first and reserves a discovery slot, and **Surprise Me** shows only unfamiliar-genre suggestions. The repository includes example library books with sample ratings to demonstrate the features; these are demonstration data, not claims about books I have read or my actual reviews.

## Demo video

[**Watch the demo video**](HW2_DEMO.mov) · [Download the MOV recording](https://github.com/Ghaida486/HW2/raw/refs/heads/main/HW2_DEMO.mov)

The recording shows the application running in Terminal, including library management, recommendations, discovery, and editing interests. Duration: approximately 5 minutes 15 seconds. If GitHub does not play the MOV inline, download it to watch.

## Verify and understand

From `HW2`, run `python3 book-manager/tests/test_app.py`. The 21 integration checks use temporary libraries. Read the [walkthrough](book-manager/WALKTHROUGH.md) for file responsibilities and complete input-to-output examples.

**Scope:** metadata and recommendations use a bundled 23-book catalog and deterministic rules. No live AI or book API is called; internet is only needed for setup or opening information links. The app is designed for one user running one instance.

Based on the [course starter](https://github.com/onexi/ps02), with its license retained. Developed with Codex assistance; the submitted explanation and narration should reflect my own understanding.

## Delete a saved book

Choose **Browse Library** or **Search Library**, select a book, then choose **Delete book**. Confirm Yes to remove it, or No to keep it. Deletion removes the saved record (including its status and rating), not the catalog entry. A deleted catalog book can appear in future recommendations again. The UI asks for confirmation, the workflow routes the request, and the database component performs the deletion.
