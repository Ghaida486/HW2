"""Integration checks use a temporary library; your real books are never changed."""
import csv
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
DB = 'data/book_database.sh'
MANAGE = 'workflows/manage_library.sh'

class BookManagerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.env = dict(os.environ, BOOK_DB=str(Path(self.tmp.name) / 'books.csv'))
    def tearDown(self):
        self.tmp.cleanup()
    def run_script(self, script, *args, text=None, ok=True):
        p = subprocess.run(['bash', str(ROOT / script), *args], input=text,
                           capture_output=True, text=True, env=self.env, timeout=10)
        if ok:
            self.assertEqual(p.returncode, 0, p.stderr)
        return p
    def add(self, title='The Hobbit', author='J. R. R. Tolkien', status='reading'):
        return self.run_script(MANAGE, 'add', title, author, status)
    def test_empty_library(self):
        self.assertEqual(self.run_script(DB, 'list').stdout, '')
    def test_catalog_enrichment_and_persistence(self):
        self.add()
        row=self.run_script(DB,'list').stdout.strip().split('\t')
        self.assertEqual(row[:5], ['The Hobbit','J. R. R. Tolkien','Fantasy','reading','0'])
        self.assertEqual(row[6], '1937')
    def test_unknown_book_and_csv_punctuation(self):
        self.add('A "Curious", Book', 'Reader, A.')
        with open(self.env['BOOK_DB'], newline='') as f:
            row = next(csv.DictReader(f))
        self.assertEqual(row['title'], 'A "Curious", Book')
        self.assertEqual(row['genre'], 'Unknown')
    def test_duplicate_case_and_spaces(self):
        self.add()
        p=self.run_script(MANAGE,'add',' the hobbit ','j. r. r. tolkien','owned',ok=False)
        self.assertNotEqual(p.returncode,0)
        self.assertEqual(len(self.run_script(DB,'list').stdout.splitlines()),1)
    def test_search_argument_and_pipe(self):
        self.add()
        a=self.run_script('books/search_books.sh','FANTASY').stdout
        b=self.run_script('books/search_books.sh',text='FANTASY\n').stdout
        self.assertEqual(a,b); self.assertIn('The Hobbit',a)
    def test_status_and_rating_update(self):
        self.add()
        self.run_script(DB,'update','The Hobbit','J. R. R. Tolkien','status','finished')
        self.run_script(DB,'update','The Hobbit','J. R. R. Tolkien','rating','5')
        self.assertIn('\tfinished\t5\t',self.run_script(DB,'list').stdout)
    def test_invalid_input_does_not_damage_library(self):
        self.add()
        before=Path(self.env['BOOK_DB']).read_bytes()
        for field,value in [('rating','9'),('status','lost'),('title','new')]:
            self.assertNotEqual(self.run_script(DB,'update','The Hobbit','J. R. R. Tolkien',field,value,ok=False).returncode,0)
        self.assertNotEqual(self.run_script(MANAGE,'add','Bad\nTitle','A','reading',ok=False).returncode,0)
        self.assertEqual(before,Path(self.env['BOOK_DB']).read_bytes())
    def test_history_and_low_rating(self):
        self.add()
        self.assertIn('Piranesi',self.run_script('recommendations/recommend_from_history.sh').stdout)
        self.run_script(DB,'update','The Hobbit','J. R. R. Tolkien','rating','1')
        self.assertEqual('',self.run_script('recommendations/recommend_from_history.sh').stdout)
    def test_interests_are_exact_genres(self):
        rows=self.run_script('recommendations/recommend_from_interests.sh','Fiction').stdout
        self.assertIn('Jane Eyre',rows); self.assertNotIn('Dune',rows)
    def test_discovery_excludes_known_genres(self):
        self.add()
        rows=self.run_script('recommendations/recommend_for_discovery.sh','Mystery').stdout
        genres={r.split('\t')[2] for r in rows.splitlines()}
        self.assertNotIn('Fantasy',genres); self.assertNotIn('Mystery',genres)
    def test_refine_duplicates_saved_books_and_limit(self):
        self.add()
        catalog=(ROOT/'books/catalog.tsv').read_text().splitlines()[1:]
        candidates='\n'.join(r+'\tTest reason\t4' for r in catalog)*1+'\n'
        result=self.run_script('recommendations/refine_recommendations.sh',text=candidates+candidates).stdout
        rows=result.splitlines()
        self.assertEqual(len(rows),5); self.assertEqual(len(set(rows)),5)
        self.assertNotIn('The Hobbit\t',result)
    def test_full_workflow_clean_output_and_progress(self):
        self.add()
        p=self.run_script('workflows/get_recommendations.sh')
        self.assertEqual(len(p.stdout.splitlines()),5)
        self.assertTrue(all(len(r.split('\t'))==7 for r in p.stdout.splitlines()))
        self.assertIn('Explore a new genre:',p.stdout)
        self.assertNotIn('The Hobbit\t',p.stdout)
        for strategy in ['history','interests','discovery']:
            self.assertIn(strategy+': running',p.stderr)
            self.assertIn(strategy+': done',p.stderr)
    def test_discovery_mode(self):
        p=self.run_script('workflows/get_recommendations.sh','Fiction, Mystery, Fantasy','discovery')
        self.assertTrue(p.stdout.strip())
        self.assertTrue(all('Explore a new genre:' in r for r in p.stdout.splitlines()))
    def test_failure_propagation(self):
        Path(self.env['BOOK_DB']).write_text('broken,header\n')
        p=self.run_script('workflows/get_recommendations.sh',ok=False)
        self.assertNotEqual(p.returncode,0); self.assertEqual(p.stdout,'')
        self.assertIn('failed',p.stderr)
    def test_all_saved_yields_empty_recommendations(self):
        for r in (ROOT/'books/catalog.tsv').read_text().splitlines()[1:]:
            title, author, genre, year, link=r.split('\t')
            self.run_script(DB,'add',title,author,genre,'owned','0',link,year)
        self.assertEqual(self.run_script('workflows/get_recommendations.sh').stdout,'')
    def test_bash_syntax(self):
        for file in ROOT.rglob('*.sh'):
            p=subprocess.run(['bash','-n',str(file)],capture_output=True,text=True)
            self.assertEqual(p.returncode,0,p.stderr)

if __name__ == '__main__':
    unittest.main(verbosity=2)
