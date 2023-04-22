install httpfs;
load httpfs;

select count(*) from 'https://github.com/marhar/duckdb_tools/raw/main/full-text/kjv-4col.parquet';
