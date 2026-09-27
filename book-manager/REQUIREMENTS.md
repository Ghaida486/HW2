# Assignment coverage

This maps the implementation to the provided ps02 assignment. It is not a promise
of a grade; the instructor evaluates your explanation and demo as well as the code.

| Requirement | Implementation | Verification |
|---|---|---|
| Small application entry point | `app.sh` checks tools and calls the main menu | Syntax test and interactive launch |
| Gum main menu and selections | `ui/main_menu.sh` contains all five specified actions, plus two personal extras | Interactive menus and Quit checked |
| Library display, search results, details, status | `ui/library_screen.sh` calls the library workflow | Added, browsed, and rated a book through the UI |
| Recommendation screen and save selection | `ui/recommendations_screen.sh` shows progress/results and saves through the workflow | Selected and saved a suggestion interactively |
| Library orchestration | `workflows/manage_library.sh` coordinates metadata and data operations | Integration tests for add, update, search |
| Parallel strategies and synchronization | `workflows/get_recommendations.sh` launches three Bash processes with `&`, records `$!`, checks each `wait` result | Full workflow and failed-strategy tests |
| Progress/streaming | Running/done messages and active-process timer go to stderr | Progress assertions and interactive check |
| Meaningful pipe | Combined candidate files are piped to `refine_recommendations.sh` | End-to-end recommendation test |
| Metadata enrichment | `books/fetch_book_metadata.sh` retrieves author, genre, year, link from `catalog.tsv` | Known-title enrichment test; unknowns stay explicit |
| Search by argument or pipe | `books/search_books.sh` accepts either | Both interfaces tested |
| History strategy | Uses saved authors and genres; excludes low-rated examples | History and rating tests |
| Interest strategy | Matches chosen comma-separated genres | Exact-genre matching test |
| Discovery strategy | Excludes genres already in library/interests | Discovery test and Surprise Me |
| Refinement through stdin/stdout | Deduplicates, excludes saved books, ranks, caps at five, reserves discovery slot | Duplicate, exclusion, limit, empty-result tests |
| Single library data boundary | Only application component `data/book_database.sh` accesses `books.csv` | Source inspection; workflows go through its commands |
| Persistent storage | CSV with atomic replacement and validation | Persistence, punctuation, invalid-input tests |
| Primarily Bash | 13 Bash scripts, with embedded Python only for robust CSV handling | Required file structure present |
| Personalization | Fiction/mystery/fantasy interests, purple menu, ratings, discovery slot, Surprise Me | Preferences visible in app |
| README | Root README includes launch steps, architecture, personalization | Written |
| Personal GitHub repository | Local project is inside existing `Ghaida486/HW2` clone | Remote checked; not yet pushed |
| Narrated demo | `DEMO_GUIDE.md` provides a short recording outline | **Your recording and real video link are still required** |
| Explain each file and a workflow | `WALKTHROUGH.md` covers responsibilities, inputs/outputs, syntax and data flow | **Read and practice explaining it yourself** |
| Submit GitHub URL to class sheet | `SUBMISSION.md` gives exact existing-repo steps | **Not submitted** |

## Test result

All 16 automated tests passed in the installed Desktop project. Manual terminal
checks also passed for launching, adding an enriched book, browsing details,
rating, parallel recommendations, saving a recommendation, returning to the menu,
and quitting. Tests used temporary libraries; your actual library remains empty.

## Deliberate limits

Metadata and suggestions come from a small bundled catalog. These are rule-based
recommendation components; the app does not claim to call live AI or a live book
service. The assignment permits, but does not require, Codex inside the app. It is
a single-user application, not a database designed for concurrent app instances.
