.echo on
-- First, let's create a table containing the text of Shakespeare's plays.
-- The Columns are:  line_id, play_name, line_number, speaker, text_entry.
-- The line_id "KL/2.4.132" means King Lear, Act 2, Scene 4, Line 132.
-- Details on how this file was generated are here:
--  https://duckdb.blogspot.com/2023/04/generating-shakespeare-corpus-for-full.html

create table corpus as
    select * from read_parquet('https://github.com/marhar/duckdb_tools/raw/main/full-text-shakespeare/shakespeare.parquet');

describe corpus;

-- Create the index. Parameters are table name, key column,
-- and the column(s) to index.

INSTALL 'fts';
LOAD fts;
PRAGMA create_fts_index('corpus', 'line_id', 'text_entry');

-- The table is now ready to query. Rows with no match return a null score.
-- What does Shakespeare say about butter?

SELECT fts_main_corpus.match_bm25(line_id, 'butter') AS score,
    line_id,play_name,speaker,text_entry
  FROM corpus
  WHERE score IS NOT NULL
  ORDER BY score;

-- Unlike standard indexes, full text indexes don't auto-updated, so you need to
-- `PRAGMA drop_fts_index(my_fts_index)` and recreate it.
