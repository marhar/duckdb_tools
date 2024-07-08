#!/usr/bin/env python
# sql_split -- split a file into ❖-delimited sql statements.

import sys
import sqlglot

sql_text = open(sys.argv[1]).read()
statements = sqlglot.parse(sql_text)
split_sql = [str(statement) for statement in statements]
print(';❖'.join(split_sql)+';')
