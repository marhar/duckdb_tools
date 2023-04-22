#!/Users/mark/opt/anaconda3/bin/python3

# create kjv.csv, kjv.parquet

import re
import duckdb

# -------- prepare the data -----------
fd = open('kjv.txt') # https://www.o-bible.com/download/kjv.txt
fd.readline() # skip first line
data2 = []
data4 = []
for line in fd.readlines():
    line = line.rstrip()
    book, chap, verse = re.match(r'(\d?[A-Za-z]+)(\d+):(\d+)\s+', line).groups()
    ref, body = re.match(r'(\d?[A-Za-z]+\d+:\d+)\s+(.*)', line).groups()
    data2.append((ref,body,))
    data4.append((book,chap,verse,body,))

# -------- create the table -----------
db = duckdb.connect()
curs = db.cursor()
curs.execute("""
    create table corpus2(ref text, body text);
    create table corpus4(book text, chap int, verse int, body text);
""")

curs.executemany("insert into corpus2(ref, body) values($1, $2)", data2)
curs.executemany("insert into corpus4(book, chap, verse, body) values($1, $2, $3, $4)", data4)

curs.execute("""
    copy corpus2 TO 'kjv-2col.csv'     (header, delimiter '|');
    copy corpus2 TO 'kjv-2col.parquet' (format parquet, compression zstd);
    copy corpus4 TO 'kjv-4col.csv'     (header, delimiter '|');
    copy corpus4 TO 'kjv-4col.parquet' (format parquet, compression zstd);
""")
