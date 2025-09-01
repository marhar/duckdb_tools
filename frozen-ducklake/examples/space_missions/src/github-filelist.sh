#!/bin/bash

TMPJ=/tmp/fetch.$$.json
trap "rm -f $TMPJ" 0

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 github-url" 1>&2
    echo "example: $0 https://github.com/marhar/duckdb_tools/tree/main/frozen-ducklake/examples/space_missions/data" 1>&2
    exit 1
fi

URL=$1
REPO=$(duckdb -noheader -ascii -c "SELECT array_to_string((split('$URL', '/'))[4:5], '/');")
DPATH=$(duckdb -noheader -ascii -c "SELECT array_to_string((split('$URL', '/'))[8:], '/');")
CPATH=https://api.github.com/repos/$REPO/contents/$DPATH

curl -s $CPATH > $TMPJ

# if row is a directory, recurse into it, else print the download_url if it's a parquet file
for xdir in $(duckdb -noheader -ascii -c "select path from '$TMPJ' where type='dir';"); do
    SUBDIR_URL=https://github.com/$REPO/tree/main/$xdir
    $0 $SUBDIR_URL
done
duckdb -noheader -ascii -c "select download_url from '$TMPJ' where type='file' and name like '%.parquet';"
