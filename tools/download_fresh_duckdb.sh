#!/bin/bash
# download_fresh_duckdb.sh - downloads and configures duckdb cli
# - downloads the latest duckdb cli.
# - symlinks to $HOME/bin
# - installs favorite extensions.

curl https://install.duckdb.org | sh

echo '--------------------------------'
echo configuring local duckdb
echo '--------------------------------'
test -d ~/bin || mkdir ~/bin
rm -f ~/bin/duckdb
ln -s ~/.duckdb/cli/${DUCKDB_VERSION:-latest}/duckdb ~/bin/duckdb

echo duckdb is:
ls -l $(which duckdb)

cat <<. |duckdb

INSTALL ducklake;
INSTALL fts;
INSTALL iceberg;
INSTALL mysql;
INSTALL postgres;
INSTALL spatial;
INSTALL vss;
INSTALL crypto from community;
INSTALL gsheets from community;
INSTALL textplot FROM community;
INSTALL gcs FROM community;

SELECT version() as "DuckDB Version";
SELECT extension_name, extension_version
FROM duckdb_extensions()
WHERE install_path IS NOT NULL AND install_path NOT IN ('(BUILT-IN)','')
;
.

if [[ -n "${GCS_ACCESS_KEY}" && -n "${GCS_ACCESS_SECRET}" ]]; then
    duckdb -c "
    CREATE OR REPLACE PERSISTENT SECRET (
      TYPE GCS,
      KEY_ID '$GCS_ACCESS_KEY',
      SECRET '$GCS_ACCESS_SECRET'
    );
"
fi

echo 'Secret Summary:'
duckdb -c "SELECT * FROM duckdb_secrets();"
