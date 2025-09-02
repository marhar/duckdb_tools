# Frozen DuckLake

The bin/ directory contains scripts and code for creating and publishing a Frozen DuckLake.

## bin/

- cloud-filelist.sh
- github-filelist.sh

  Two scripts to create a list of data files that exist in cloud storage
  and that can be used to create a Frozen DuckLake.

- create-import-scripts.sql

  Used to generate the import scripts for a Frozen DuckLake.

- sample-workflow.sh
  The complete workflow I used to create the space missions example


## examples/space\_missions

```
duckdb ducklake:https://github.com/marhar/duckdb_tools/raw/refs/heads/main/frozen-ducklake/examples/space_missions/space_missions.ducklake
```
