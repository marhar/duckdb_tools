-- customization:
-- replace db_name as necessary.
-- generate table name as needed.  This two-part split
-- uses the first part of the filename.

CREATE OR REPLACE TABLE frozen_parms AS
SELECT
  'myfrozen' as db_name,
  split_part(split_part(full_path, '/', -1), '.', 1) as table_name,
  full_path
FROM 'tmp_files.csv';

.header off
.mode tabs

.once tmp_create_tables.sql
SELECT
  printf('CREATE TABLE %s.%s AS SELECT * FROM read_parquet(''%s'') WITH NO DATA;',
    db_name, table_name, min(full_path)) AS create_statement
FROM frozen_parms
GROUP BY db_name, table_name
ORDER BY table_name;

.once  tmp_add_data_files.sql
SELECT
  printf('CALL ducklake_add_data_files(''%s'', ''%s'', ''%s'');',
    db_name, table_name, full_path) AS add_data_statement
FROM frozen_parms
ORDER BY full_path;
