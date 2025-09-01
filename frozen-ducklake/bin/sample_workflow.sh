#!/bin/bash
# sample_workflow.sh -- showing how to create and use a frozen DuckLake

./github-filelist.sh https://github.com/marhar/duckdb_tools/tree/main/frozen-ducklake/examples/space_missions/data
duckdb -f create-import-scripts.sh
ls -l tmp*

cat <<. | duckdb
LOAD ducklake;
LOAD httpfs;
ATTACH 'ducklake:myfrozen.ducklake' AS myfrozen (DATA_PATH 'tmp_always_empty');
.echo on
.header off
.mode tabs
.bail on
.read tmp_01_create_tables.sql
.read tmp_02_add_data_files.sql
.

duckdb ducklake:myfrozen.ducklake -c "SHOW TABLES;"

# publish and use like this:
# copy myfrozen.ducklake somecloud://mybucket/space.ducklake
# duckdb ducklake:somecloud://mybucket/space.ducklake -c "SELECT * FROM missions LIMIT 3;"
