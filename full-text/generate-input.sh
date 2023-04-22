#!/bin/bash

# Generate two flavors of kjv.txt, with one row per verse.
# 1.  Two columns, ref and body.
# 2.  Four columns, with separate book, chap, verse, body.

sed '1d;s/ /|/'                                                <kjv.txt >kjv2.tmp
sed '1d;s/^\([0-9]*[A-Za-z]*\)\([^:]*\):\([^ ]*\) /\1|\2|\3|/' <kjv.txt >kjv4.tmp

duckdb <<.
create table corpus2 as select * from read_csv('kjv2.tmp', delim='|', header=False,
   columns={'ref': 'text', 'body': 'text'});
create table corpus4 as select * from read_csv('kjv4.tmp', delim='|', header=False,
   columns={'book': 'text','chap': 'int', 'verse': 'int', 'body': 'text'});

copy corpus2 TO 'kjv-2col.csv'     (header, delimiter '|');
copy corpus4 TO 'kjv-4col.csv'     (header, delimiter '|');
copy corpus2 TO 'kjv-2col.parquet' (format parquet, compression zstd);
copy corpus4 TO 'kjv-4col.parquet' (format parquet, compression zstd);
.
rm kjv2.tmp kjv4.tmp
