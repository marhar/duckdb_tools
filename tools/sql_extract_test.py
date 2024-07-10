#!/usr/bin/env python

import unittest
from typing import List
import textwrap
from sql_extract import extract_sql_statements  # Replace 'your_module' with the actual module name

class TestExtractSQLStatements(unittest.TestCase):

    def test_single_statement(self):
        sql = "SELECT * FROM users;"
        expected = ["SELECT * FROM users;"]
        self.assertEqual(extract_sql_statements(sql), expected)

    def test_multiple_statements(self):
        sql = textwrap.dedent("""
        SELECT * FROM users;
        INSERT INTO logs (user_id, action) VALUES (1, 'login');
        UPDATE products SET stock = stock - 1 WHERE id = 5;
        """)
        expected = [
            "SELECT * FROM users;",
            "INSERT INTO logs (user_id, action) VALUES (1, 'login');",
            "UPDATE products SET stock = stock - 1 WHERE id = 5;"
        ]
        self.assertEqual(extract_sql_statements(sql), expected)

    def test_statements_without_semicolons(self):
        sql = textwrap.dedent("""
        SELECT * FROM users;
        INSERT INTO logs (user_id, action) VALUES (1, 'login');
        UPDATE products SET stock = stock - 1 WHERE id = 5;
        """)
        expected = [
            "SELECT * FROM users;",
            "INSERT INTO logs (user_id, action) VALUES (1, 'login');",
            "UPDATE products SET stock = stock - 1 WHERE id = 5;"
        ]
        self.assertEqual(extract_sql_statements(sql), expected)

    def test_mixed_semicolon_usage(self):
        sql = textwrap.dedent("""
        SELECT * FROM users;
        INSERT INTO logs (user_id, action) VALUES (1, 'login');
        UPDATE products SET stock = stock - 1 WHERE id = 5;
        DELETE FROM expired_sessions
        """)
        expected = [
            "SELECT * FROM users;",
            "INSERT INTO logs (user_id, action) VALUES (1, 'login');",
            "UPDATE products SET stock = stock - 1 WHERE id = 5;",
            "DELETE FROM expired_sessions"
        ]
        self.assertEqual(extract_sql_statements(sql), expected)

    def test_empty_input(self):
        sql = ""
        expected = []
        self.assertEqual(extract_sql_statements(sql), expected)

    def test_whitespace_only_input(self):
        sql = "    \n\t  "
        expected = []
        self.assertEqual(extract_sql_statements(sql), expected)

    def test_complex_statements(self):
        sql = textwrap.dedent("""\
        CREATE TABLE users (
            id INT PRIMARY KEY,
            name VARCHAR(50),
            email VARCHAR(100) UNIQUE
        );

        INSERT INTO users (id, name, email) VALUES
        (1, 'John Doe', 'john@example.com'),
        (2, 'Jane Smith', 'jane@example.com');

        SELECT u.name, o.order_date
        FROM users u
        JOIN orders o ON u.id = o.user_id
        WHERE o.status = 'shipped';
        """)
        expected = [
            textwrap.dedent("""\
            CREATE TABLE users (
                id INT PRIMARY KEY,
                name VARCHAR(50),
                email VARCHAR(100) UNIQUE
            );"""),
            textwrap.dedent("""\
            INSERT INTO users (id, name, email) VALUES
            (1, 'John Doe', 'john@example.com'),
            (2, 'Jane Smith', 'jane@example.com');"""),
            textwrap.dedent("""\
            SELECT u.name, o.order_date
            FROM users u
            JOIN orders o ON u.id = o.user_id
            WHERE o.status = 'shipped';""")
        ]
        self.assertEqual(extract_sql_statements(sql), expected)

    def test_statements_with_semicolons_in_strings(self):
        sql = textwrap.dedent("""\
        SELECT * FROM users WHERE name = 'John; Doe';
        INSERT INTO messages (content) VALUES ('Hello; World;');
        """)
        expected = [
            "SELECT * FROM users WHERE name = 'John; Doe';",
            "INSERT INTO messages (content) VALUES ('Hello; World;');"
        ]
        self.assertEqual(extract_sql_statements(sql), expected)

    def test_preserving_leading_whitespace(self):
        sql = (
            "    SELECT * FROM table1;\n"
            "        INSERT INTO table2 VALUES (1, 2, 3);\n"
            "\tUPDATE table3 SET column = value;"
              )
        expected = [
            "    SELECT * FROM table1;",
            "        INSERT INTO table2 VALUES (1, 2, 3);",
            "\tUPDATE table3 SET column = value;"
        ]
        self.assertEqual(extract_sql_statements(sql), expected)

if __name__ == '__main__':
    unittest.main()
