# DuckDB Remote File Access

Access files remotely over https.


```
% cat remote.sql 

install httpfs;
load httpfs;

select count(*) from 'https://github.com/marhar/duckdb_tools/raw/main/full-text/kjv-4col.parquet';

mh duckdb_tools/remote_files% duckdb <remote.sql
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│        31102 │
└──────────────┘
```
