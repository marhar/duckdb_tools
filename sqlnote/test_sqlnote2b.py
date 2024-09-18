#!/usr/bin/env python3

from io import StringIO
import json
import re
import sqlite3
import subprocess
import sys


def execute_sql_bq_table(sql_code):
    try:
        # Execute the BigQuery SQL using 'bq query' command with default table format
        result = subprocess.run(['bq', 'query', '--use_legacy_sql=false', sql_code], 
                                capture_output=True, text=True, check=True)
        
        # The output is already formatted as a table, so we can return it directly
        return result.stdout if result.stdout else "No results.\n"
    except subprocess.CalledProcessError as e:
        return f"Error: {e.stdout}\n{e.stderr}\n"


def execute_sql_bq_json(sql_code):
    try:
        # Execute the BigQuery SQL using 'bq query' command
        result = subprocess.run(['bq', 'query', '--format=json', '--use_legacy_sql=false', sql_code], 
                                capture_output=True, text=True, check=True)
        
        # Parse the JSON output
        data = json.loads(result.stdout)
        
        output = StringIO()
        if data:
            # Extract column names from the first row
            column_names = list(data[0].keys())
            output.write(" | ".join(column_names) + "\n")
            output.write("-|-".join(["-" * len(name) for name in column_names]) + "\n")
            
            # Write each row of data
            for row in data:
                output.write(" | ".join(str(row[col]) for col in column_names) + "\n")
        else:
            output.write("No results.\n")
        
        return output.getvalue()
    except subprocess.CalledProcessError as e:
        return f"Error: {e.stdout}\n{e.stderr}\n"
    except json.JSONDecodeError:
        return f"Error: Unable to parse BigQuery output\n"

execute_sql = execute_sql_bq_table


def execute_sql_sqlite(sql_code):
    conn = sqlite3.connect(':memory:')
    cursor = conn.cursor()
    try:
        cursor.execute(sql_code)
        result = cursor.fetchall()
        
        output = StringIO()
        if result:
            column_names = [description[0] for description in cursor.description]
            output.write(" | ".join(column_names) + "\n")
            output.write("-|-".join(["-" * len(name) for name in column_names]) + "\n")
            for row in result:
                output.write(" | ".join(str(item) for item in row) + "\n")
        else:
            output.write("No results.\n")
        
        return output.getvalue()
    except sqlite3.Error as e:
        return f"Error: {str(e)}\n"
    finally:
        conn.close()

def filter_markdown(content):
    def replace_sql_block(match):
        sql_code = match.group(1).strip()
        output = execute_sql(sql_code)
        return f"```sql\n{sql_code}\n```\n```\n{output}```"

    sql_block_pattern = re.compile(r'```sql\n(.*?)\n```(?:\n```\n(.*?)\n```)?', re.DOTALL)
    return sql_block_pattern.sub(replace_sql_block, content)

def main():
    input_content = sys.stdin.read()
    output_content = filter_markdown(input_content)
    sys.stdout.write(output_content)

if __name__ == "__main__":
    main()
