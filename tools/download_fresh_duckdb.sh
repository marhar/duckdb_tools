#!/bin/bash
# download_fresh_duckdb.sh - downloads and configures duckdb cli
# - downloads the latest duckdb cli.
# - symlinks to $HOME/bin
# - installs favorite extensions.

curl https://install.duckdb.org | sh

echo '--------------------------------'
echo configuring local duckdb
echo '--------------------------------'
rm -f ~/bin/duckdb
ln -s ~/.duckdb/cli/latest/duckdb ~/bin/duckdb

echo duckdb is:
ls -l $(which duckdb)

cat <<. |duckdb

INSTALL ducklake;
INSTALL httpfs;
INSTALL iceberg;
INSTALL mysql;
INSTALL postgres;
INSTALL spatial;
INSTALL crypto from community;
INSTALL gsheets from community;
INSTALL textplot FROM community;

SELECT version() as "DuckDB Version";
SELECT extension_name, extension_version
FROM duckdb_extensions()
WHERE install_path IS NOT NULL AND install_path NOT IN ('(BUILT-IN)','')
;
.
