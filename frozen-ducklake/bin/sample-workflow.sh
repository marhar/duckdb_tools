#!/bin/bash
# sample_workflow.sh -- showing how to create and use a frozen DuckLake

./github-filelist.sh https://github.com/marhar/frozen/tree/main/space
duckdb -f create-import-scripts.sql

cat <<. | duckdb
.header off
.mode tabs
.bail on
.echo on
LOAD ducklake;
LOAD httpfs;
ATTACH 'ducklake:myfrozen.ducklake' AS myfrozen (DATA_PATH 'tmp_always_empty');
.read tmp_create_tables.sql
.read tmp_add_data_files.sql
.

duckdb ducklake:myfrozen.ducklake -c "SHOW TABLES;"

# publish and use like this:
# copy myfrozen.ducklake somecloud://mybucket/space.ducklake
# duckdb ducklake:somecloud://mybucket/space.ducklake -c "SELECT * FROM missions LIMIT 3;"
