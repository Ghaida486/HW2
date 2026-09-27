# HW2 — Between the Pages

A personal terminal book manager for fiction, mystery, and fantasy.
The complete application is in [`book-manager/`](book-manager/).

## Run on your Mac

```bash
cd ~/Desktop/MIT/1.125/HW/HW2/book-manager
bash app.sh
```

Requires Bash, Gum, and Python 3. Gum and Python 3 are installed on this Mac.
For another Mac with Homebrew, install missing tools with `brew install gum python`.
No API key is needed: recommendations and metadata use a small offline catalog.

## Architecture

Small Bash scripts separate the Gum UI, workflows, book operations,
recommendation strategies, and data access. Only `data/book_database.sh` accesses
`books.csv`; its embedded Python CSV helper handles commas and quotes. Three
recommendation programs run concurrently using `&`, `$!`, and `wait`. Their results
are combined and piped into refinement, which excludes saved books, removes
duplicates, and ranks a shortlist. Progress is reported separately from data.

## Personalization

The app is themed around fiction, mystery, and fantasy. Interests are editable,
ratings influence history recommendations, and one discovery pick is reserved in
the shortlist. The extra **Surprise Me** action explores unfamiliar genres. The
library starts empty and can track owned, planned, current, and finished reads.

## Demo video — pending

**Record and link your own narrated demo here before submission.**
Follow the [demo guide](book-manager/DEMO_GUIDE.md) to show 2–3 operations.
No video has been recorded or supplied yet.

## Learn and verify

- [Full app instructions](book-manager/README.md)
- [File-by-file walkthrough](book-manager/WALKTHROUGH.md)
- [Assignment coverage](book-manager/REQUIREMENTS.md)
- [Submission steps](book-manager/SUBMISSION.md)

Run tests with `python3 book-manager/tests/test_app.py` from this folder.
Tests use temporary data and do not change your library.

Based on the [course starter](https://github.com/onexi/ps02); its LICENSE is retained
inside the app folder. Implementation developed with Codex assistance.
