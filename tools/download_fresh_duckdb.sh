#!/bin/bash
# Download and install the latest DuckDB CLI.
# Handy for initially setting up a new docker.

case $(uname -s) in
    Linux)     OSPART=linux-amd64 ;;
    Darwin)    OSPART=osx-universal ;;
esac

VERSION=v1.1.2
DUCKDB=./duckdb
FNAME=duckdb_cli-$OSPART.zip
URL=https://github.com/duckdb/duckdb/releases/download/$VERSION/$FNAME

echo URL: $URL
rm -f $FNAME $DUCKDB
wget -q $URL
if [ $? -ne 0 ]; then
    echo could not fetch $FNAME
    exit 1
fi
unzip -q $FNAME
rm $FNAME
chmod +x $DUCKDB
cat <<. |$DUCKDB
INSTALL httpfs;
INSTALL iceberg;
INSTALL mysql;
INSTALL postgres;
SELECT extension_name, extension_version
FROM duckdb_extensions()
WHERE install_path IS NOT NULL AND install_path NOT IN ('(BUILT-IN)','')
;
.
