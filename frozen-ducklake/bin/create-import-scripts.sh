.header off
.mode tabs

-- prefix:
-- LOAD ducklake;
-- LOAD httpfs;
-- ATTACH 'ducklake:myfrozen.ducklake' AS myfrozen (DATA_PATH 's3://frequence-parquet-archival/test3-metadata');
-- .echo on
-- .header off
-- .mode tabs
-- .bail on

-- .read tmp_create_tables.sql
-- .read tmp_add_data_files.sql

-- duckdb  2.23s user 0.51s system 26% cpu 10.280 total
-- duckdb  629.58s user 32.02s system 45% cpu 24:23.00 total

CREATE OR REPLACE TABLE frozen_parms AS
SELECT
  'myfrozen'                     as db_name,
  split_part(full_path, '/', -2) as table_name,
                                    full_path
FROM 'tmp_files.csv';

#-- for debugging reference
#.header on
#.mode box
#.once tmp_00_frozen_parms.txt
#SELECT * FROM frozen_parms ORDER BY full_path;

.header off
.mode tabs
.once tmp_01_create_tables.sql
SELECT
  printf('CREATE TABLE %s.%s AS SELECT * FROM read_parquet(''%s'') WHERE 1<>1;',
    db_name, table_name, min(full_path)) AS create_statement
FROM frozen_parms
GROUP BY db_name, table_name
ORDER BY table_name;

.header off
.mode tabs
.once  tmp_02_add_data_files.sql
SELECT
  printf('CALL ducklake_add_data_files(''%s'', ''%s'', ''%s'');',
    db_name, table_name, full_path) AS add_data_statement
FROM frozen_parms
ORDER BY full_path;

-- stats


-- combined row count

.header off
.mode tabs
.once  tmp_03_insert_counts.sql
SELECT DISTINCT
printf('INSERT INTO frozen_counts(table_name, row_count) VALUES (''%s'', (select count(*) from ''%s''));',
  table_name, table_name) AS insert_statement
FROM frozen_parms
ORDER BY table_name;
