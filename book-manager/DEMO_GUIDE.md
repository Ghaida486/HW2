# Recording script: Between the Pages

Checked against the current app on September 29, 2026. Aim for about 3 minutes; the assignment specifies a short video, not an exact duration. Show your terminal and narrate in your own words. No slides or face camera are required by the assignment.

## How this video covers every requirement in your screenshot

| Assignment requirement | What you will include |
|---|---|
| Application running in the terminal | Record the launch command and the live app throughout the demo. |
| Clearly visible interface | Enlarge the terminal text, widen the window, and pause on menus and results. Check a short test recording for readability. |
| Two or three operations | Demonstrate exactly three: Browse Library, Search Library, and Get Recommendations. |
| Your narration: what you do and what the app does | Read or adapt the SAY passages while performing the matching DO steps. Each operation explains both your action and the application's response. |
| Short, easy-to-understand video | Aim for roughly three minutes, including a brief introduction and closing. This is a suggested duration, not an assignment limit. |
| Video in repository or clearly visible README link | After recording, add the actual video or a working link under the root README's Demo video heading and push it to GitHub. |

## Before recording

1. Open Terminal, change to the project folder, and rehearse the launch with:

```bash
cd ~/Desktop/MIT/1.125/HW/HW2/book-manager
bash app.sh
```

2. Enlarge the font and widen the window so titles are readable. Keep this guide beside the recording area.
3. Start your screen recorder, select the terminal area, and enable your microphone. Make a ten-second test and play it back to check sound and readability.
4. After rehearsing, choose Quit. For the final take, start recording before typing `bash app.sh` so the video shows the launch and then the live menu.
5. Use arrow keys and Enter. This walkthrough uses Browse, Search, and Get Recommendations and does not change saved books.

Current state: seven saved books; selected interest Mystery. If you change your library before recording, the shortlist may change.

## 0:00–0:20 — Introduce the project

DO: With recording and microphone on, type `bash app.sh`, press Enter, and let the main menu appear. Keep the app visible throughout your narration.

SAY: “This is Between the Pages, my personal terminal book manager. I can save books, track reading status and ratings, search my library, and find recommendations. I personalized it with a purple interface, editable genre interests, and a Surprise Me option. My current interest is Mystery.”

## 0:20–1:00 — Operation 1: Browse Library

DO: Select Browse Library, then A Wizard of Earthsea. Pause on its details. Select Back with the down arrow three times, then Enter. Press Enter again to return to the main menu.

SAY while selecting Browse Library: “First, I’m opening my saved library and selecting A Wizard of Earthsea. The app retrieves my saved records and displays this book’s details.”

SAY on its details: “Here is a saved book with its author, genre, publication year, reading status, rating, and information link. I can change its status, rate it, or delete it with confirmation. The library stores my saved records; a separate 23-book catalog provides metadata and recommendation candidates. Only the database component reads and writes the library CSV.”

## 1:00–1:40 — Operation 2: Search Library

DO: Select Search Library. Type Earthsea and press Enter. Select A Wizard of Earthsea. Show the details, choose Back, and press Enter to return.

SAY: “I’m searching for Earthsea. The interface collects this text and sends it to the library workflow. The workflow calls the search component, which asks the database component for matching records. Those records return to the interface. This traces one complete workflow from my input to the result, without changing the saved library.”

## 1:40–2:40 — Operation 3: Get Recommendations

DO: Select Get Recommendations. Let the running and done messages appear. Pause on the shortlist. Select The Dispossessed. Show its explanation. At the save question choose No with the arrow keys and press Enter, then press Enter to return to the main menu.

SAY as you select Get Recommendations: “Now I’m asking the app for suggestions based on my library and interests.”

SAY while the shortlist is visible: “Three independent Bash programs run in parallel: history looks at saved authors and genres, interests uses my selected genres, and discovery explores unfamiliar genres. The workflow starts them with ampersand, captures their process IDs, and waits for them to finish. Progress messages show that work is happening. Then it combines their outputs and pipes them into refinement, which removes duplicates and saved books and returns up to five suggestions.”

SAY on The Dispossessed: “This suggestion shares an author with books in my library. If I saved it, it would be added as want-to-read and excluded from future suggestions. I’ll choose No for this demonstration.”

The verified shortlist was The Moonstone, The Dispossessed, Dune, Howl’s Moving Castle, and A Brief History of Time. If it changes, select an available book and explain the reason actually shown. Progress can be fast because the catalog is small.

## 2:40–3:00 — Close

SHOW: main menu, then select Quit.

SAY: “The application separates interaction, workflow coordination, book and recommendation components, and storage. I used Codex during development. The app itself uses an offline catalog and rules, rather than a live AI service. Its main limitation is the small fixed catalog.”

Stop recording and play it back. Check:

- The launch and live terminal app are visible.
- Menu labels, book details, search results, and recommendation reasons are readable.
- Your voice is audible and explains both your actions and the app's behavior.
- All three operations are shown, with a brief pause on each result.
- The video stays short; trim long silent setup or waiting periods if necessary. Explain only statements you understand; practice the workflow in WALKTHROUGH.md before recording.

## After recording

1. Add the video to the repository or upload it somewhere the instructor can access.
2. Replace the pending video message in the root README.md with the real video or link. Put it under **Demo video**, where it is easy to find. For example, use `[Watch the narrated demo](ACTUAL_VIDEO_URL)` after replacing `ACTUAL_VIDEO_URL` with your working link; never submit the placeholder.
3. Commit and push the latest project and documentation. There were uncommitted changes at the September 29 review; the remote could not be verified because SSH authentication failed.
4. Check the actual GitHub page and video access, then enter the repository URL in the class sheet’s Assignment No 2 column.

Repository: https://github.com/Ghaida486/HW2
