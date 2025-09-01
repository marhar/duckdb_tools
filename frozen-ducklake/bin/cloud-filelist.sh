#!/bin/bash
# cloud-filelist.sh -- recursively list all parquet files in a cloud directory
# This works for all duckdb-supported cloud storage backends (s3, gcs, azure, ...)

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 cloud-dir" 1>&2
  echo "example: $0 s3://mybucket/myproject/data" 1>&2
  exit 1
fi

# Use the duckdb recursive glob syntax
WILDCARD="$1/**/*.parquet"

duckdb -c "
LOAD httpfs;
COPY (SELECT file AS full_path FROM glob('$WILDCARD')) TO 'tmp_files.csv';
"
