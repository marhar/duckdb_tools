#!/Users/mark/opt/anaconda3/bin/python3

import re
import duckdb

# -------- prepare the data -----------
fd = open('kjv.txt') # https://www.o-bible.com/download/kjv.txt
fd.readline() # skip first line
data = []
for line in fd.readlines():
    line = line.rstrip()
    # book, chap, verse, body = re.match(r'(\d?[A-Za-z]+)(\d+):(\d+)\s+(.*)', line).groups()
    ref, body = re.match(r'(\d?[A-Za-z]+\d+:\d+)\s+(.*)', line).groups()
    data.append((ref,body,))

# -------- create the table -----------
db = duckdb.connect()
db.cursor().execute("create table corpus(ref text, body text)")
db.cursor().executemany("insert into corpus(ref, body) values($1, $2)", data)

# -------- everything below could be run in the duckdb cli ---------

# -------- create the index -----------
db.cursor().execute(
    """
    install 'fts';
    load fts;
    pragma create_fts_index('corpus', 'ref', 'ref', 'body');
    """)

# -------- full text query -----------
print(db.sql("""
    select fts_main_corpus.match_bm25(ref, 'whale') as score,
      ref, body as "search for 'whale'"
    from corpus
    where score is not null
    order by score;
    """))
