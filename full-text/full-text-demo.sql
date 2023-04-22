create table corpus as select * from read_parquet('kjv-2col.parquet');

install 'fts';
load fts;

pragma create_fts_index('corpus', 'ref', 'ref', 'body');

select fts_main_corpus.match_bm25(ref, 'whale') as score,
      ref, body as "search for 'whale'"
    from corpus
    where score is not null
    order by score;
