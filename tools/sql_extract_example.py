#!/usr/bin/env python

from sql_extract import extract_sql_statements

sql = """
SELECT * FROM table1;
INSERT INTO table2 (col1, col2) VALUES (1, 2);
UPDATE table3 SET col1 = 3 WHERE col2 = 4;
  SELECT foo
    FROM     table4;
select 1;
"""

sql_statements = extract_sql_statements(sql)
for i, statement in enumerate(sql_statements):
    print(f"-- Statement {i+1}:\n{statement}")
