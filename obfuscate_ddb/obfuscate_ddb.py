#!/usr/bin/env python3
"""
Obfuscates the text columns in a DB
WARNING: Overwrites the data, only do this on a copy.
"""

import hashlib
import sys
import duckdb


def obfuscate_column(curs, table_name, column_name):
    print(table_name, column_name)
    curs.execute(
        f"""
        update {table_name} set {column_name}=compute_md5({column_name})
        """)


def obfuscate_table(curs, table_name):
    for column_name, in curs.execute(
        """
        select column_name from information_schema.columns
        where table_name = $1 and data_type = 'VARCHAR'
        order by column_name
        """, (table_name,)).fetchall():
        obfuscate_column(curs, table_name, column_name)


def compute_md5(s: str) -> str:
    """
    Computes the MD5 hash of the input string and returns a string of
    the same length as the input, composed of repeated MD5 hashes.

    :param s: Input string, possibly None
    :return: None, or string of the same length as the input, composed of repeated MD5 hashes
    """
    if s is None:
        return None
    md5_hash = hashlib.md5(s.encode('utf-8')).hexdigest()
    repeated_hash = (md5_hash * (len(s) // len(md5_hash))) + md5_hash
    return repeated_hash[:len(s)]


def compute_md5_with_spaces(s: str) -> str:
    """
    Computes the MD5 hash of the input string (excluding spaces) and returns a string of the same length 
    as the input, composed of repeated MD5 hashes. Spaces from the input are preserved at the same positions.
    If the input is None, the function returns None.

    :param s: Input string
    :return: String of the same length as the input, composed of repeated MD5 hashes with spaces or None
    """
    if s is None:
        return None

    # Compute hash for the string without spaces
    md5_hash = hashlib.md5(s.replace(" ", "").encode('utf-8')).hexdigest()
    repeated_hash = (md5_hash * (len(s.replace(" ", "")) // len(md5_hash))) + md5_hash

    # Insert spaces back into their original positions
    output = ""
    hash_index = 0
    for char in s:
        if char == " ":
            output += " "
        else:
            output += repeated_hash[hash_index]
            hash_index += 1

    return output


def obfuscate_file(db_file):
    conn = duckdb.connect(db_file);

    conn.create_function('compute_md5', compute_md5_with_spaces)
    curs = conn.cursor()
    for table_name, in curs.sql(
        """
        select table_name from information_schema.tables
        where table_schema='main' and table_type = 'BASE TABLE'
        -- TODO add filtering of tables
        order by table_name
        """).fetchall():
        obfuscate_table(curs, table_name)


def main():
    if len(sys.argv) != 2:
        print("Usage: obfuscate.py database-file")
        sys.exit(1)

    db_file = sys.argv[1]
    obfuscate_file(db_file)


if __name__ == "__main__":
    main()
