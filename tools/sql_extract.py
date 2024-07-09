#!/usr/bin/env python
import sqlglot
from sqlglot.tokens import TokenType, Tokenizer
from typing import List

def extract_sql_statements(sql: str) -> List[str]:
    """Extract SQL statements from a string, keeping original formatting."""
    tokenizer = Tokenizer()
    tokens = tokenizer.tokenize(sql)

    statements = []
    start_ix = 0

    for token in tokens:
        if token.token_type == TokenType.SEMICOLON:
            end_ix = token.end+1
            stmt = sql[start_ix:end_ix].lstrip('\n').rstrip()
            statements.append(stmt)
            start_ix = end_ix

    # If there are remaining tokens, it's because the last statement
    # was not semicolon terminated.  But if it's just whitespace,
    # it's not anything and we don't want to save it.
    if start_ix < len(sql):
        stmt = sql[start_ix:].lstrip('\n').rstrip()
        if stmt:
            statements.append(stmt)

    return statements

# Example usage
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
    print(f"Statement {i+1}:\n{statement}")
