#!/usr/bin/env python
import sqlglot
from typing import List

def extract_sql_statements(sql: str) -> List[str]:
    """Extract SQL statements from a string, keeping original formatting."""
    tokenizer = sqlglot.Tokenizer()
    tokens = tokenizer.tokenize(sql)

    statements = []
    start_ix = 0

    for token in tokens:
        if token.token_type == sqlglot.TokenType.SEMICOLON:
            end_ix = token.end+1
            stmt = sql[start_ix:end_ix].lstrip('\n').rstrip()
            statements.append(stmt)
            start_ix = end_ix

    # If there are remaining tokens, it's because the last statement
    # was not semicolon terminated.
    if start_ix < len(sql):
        stmt = sql[start_ix:].lstrip('\n').rstrip()
        if stmt:
            statements.append(stmt)

    return statements
