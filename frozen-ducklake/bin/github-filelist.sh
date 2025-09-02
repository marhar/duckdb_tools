#!/bin/bash
# github-filelist.sh -- recursively list all parquet files in a github directory

TMPJ=/tmp/fetch.$$.json
trap "rm -f $TMPJ" 0

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 github-url" 1>&2
  echo "example: $0 https://github.com/marhar/duckdb_tools/tree/main/frozen-ducklake/examples/space_missions/data" 1>&2
  exit 1
fi

process() {
  CPATH=https://api.github.com/repos/$REPO/contents/$DPATH

  # plain curl will work with a limited number of requests per hour.
  # see https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api
  curl -s -H "Authorization: token $GH_RO_TOKEN" $CPATH > $TMPJ
  #curl -s $CPATH > $TMPJ
  

  # if row is a directory recurse into it, else print the download_url if it's a parquet file
  for DPATH in $(duckdb -noheader -ascii -c "SELECT path FROM '$TMPJ' WHERE type='dir' ORDER BY name;"); do
    process $REPO $DPATH
  done
  duckdb -noheader -ascii -c "select download_url from '$TMPJ' where type='file' and name like '%.parquet' ORDER BY name;"
}

URL=$1
REPO=$(duckdb -noheader -ascii -c "SELECT array_to_string((split('$URL', '/'))[4:5], '/');")
DPATH=$(duckdb -noheader -ascii -c "SELECT array_to_string((split('$URL', '/'))[8:], '/');")

echo full_path >tmp_files.csv
process $REPO $DPATH >>tmp_files.csv
