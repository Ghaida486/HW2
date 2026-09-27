# Record your narrated demo

Aim for about 2–3 minutes. Use your own words after understanding the code.
Your voice and actual video are still required; this is only a suggested script.

1. Open this project in VS Code. Open its terminal and enlarge the text.
2. Start your screen recording, including your microphone.
3. Run `bash app.sh`.
4. Demonstrate these operations:

## Add a book

Choose **Add Book**, enter **The Hobbit**, leave author blank, keep the genre
prompt, and choose **reading**. If it is already in your library, choose another
catalog title such as **Piranesi** or **The Moonstone**.

Suggested narration: “This is Between the Pages, my personal book manager. I
personalized it for fiction, mystery, and fantasy. When I add a known book, the
app fills in metadata from its offline catalog and saves it through the data layer.”

## Find and update it

Choose **Search Library**, type part of the title, and select the book. Show the
metadata, choose **Rate book**, and give it a rating. You can also show status changes.

Suggested narration: “Search goes through a separate component. The CSV stores
my books between sessions. Only the database script reads or writes that file.”

## Request recommendations

Choose **Get Recommendations**. Show the running/done messages, shortlist, and
explanation for a suggestion. Choose a book and save it if desired.

Suggested narration: “Three Bash programs run in parallel: history, interests,
and discovery. The workflow uses background processes and waits for all three.
It pipes the combined output into refinement, which removes duplicates and books
I already saved. The list includes a discovery pick outside my usual genres.”

Finish by pointing briefly to the project folders. Explain that this is an offline,
rule-based app and that Codex helped develop it. Mention the small Python CSV helper
if discussing implementation. Stop recording and add the actual video or its link
under **Demo video** in README.md before submission.
