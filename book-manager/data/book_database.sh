#!/bin/bash
# Only this component accesses books.csv. Python's csv module handles quotes/commas.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
export BOOK_DB="${BOOK_DB:-$HERE/books.csv}"
python3 - "$@" <<'PYDB'
import csv, os, sys, tempfile
from pathlib import Path
path = Path(os.environ['BOOK_DB'])
fields = ['title', 'author', 'genre', 'status', 'rating', 'link', 'year']
statuses = ['want-to-read', 'owned', 'reading', 'finished']
args = sys.argv[1:]
def fail(message):
    print(message, file=sys.stderr); sys.exit(1)
def key(title, author):
    return (title.strip().casefold(), author.strip().casefold())
def emit(rows):
    for row in rows:
        print('\t'.join(row.get(f, '') or 'Unknown' for f in fields))
def save(rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=path.parent, prefix='.books-')
    try:
        with os.fdopen(fd, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fields)
            writer.writeheader(); writer.writerows(rows)
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp): os.unlink(tmp)
if not args: fail('Usage: book_database.sh list|add|search|exists|update ...')
if any(any(ord(c) < 32 or ord(c) == 127 for c in a) for a in args):
    fail('Fields cannot contain tabs, newlines, or control characters.')
args = [a.strip() for a in args]
rows = []
if path.exists():
    with path.open(newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        if reader.fieldnames != fields: fail('Unexpected CSV header. See README for the schema.')
        rows = list(reader)
command, *values = args
if command == 'list' and not values:
    emit(rows)
elif command == 'search' and len(values) == 1:
    term = values[0].casefold()
    emit([r for r in rows if term in ' '.join(r.values()).casefold()])
elif command == 'exists' and len(values) == 2:
    sys.exit(0 if any(key(r['title'],r['author']) == key(*values) for r in rows) else 1)
elif command == 'add' and len(values) == 7:
    row = dict(zip(fields, values))
    if not row['title'] or not row['author']: fail('Title and author are required.')
    if row['status'] not in statuses: fail('Choose a valid reading status.')
    if row['rating'] not in ['0','1','2','3','4','5']: fail('Rating must be 0 (unrated) through 5.')
    if any(key(r['title'],r['author']) == key(row['title'],row['author']) for r in rows):
        fail('That title and author are already in your library.')
    rows.append(row); save(rows)
elif command == 'update' and len(values) == 4:
    title, author, field, value = values
    if field not in ['status','rating']: fail('Only status and rating can be updated.')
    if field == 'status' and value not in statuses: fail('Choose a valid reading status.')
    if field == 'rating' and value not in ['0','1','2','3','4','5']: fail('Rating must be 0 through 5.')
    matches = [r for r in rows if key(r['title'],r['author']) == key(title,author)]
    if not matches: fail('Book not found.')
    matches[0][field] = value; save(rows)
else:
    fail('Invalid command or arguments. See README.md for examples.')
PYDB
