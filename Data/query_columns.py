import sqlite3
import pandas as pd

class BacteriaDatabase:
    def __init__(self, db_path):
        self.db_path = db_path
        self.conn = sqlite3.connect(db_path)

    def get_table_columns(self, table_name):
        query = f"PRAGMA table_info({table_name})"
        df = pd.read_sql(query, self.conn)
        return df["name"].tolist()  # Return only the column names

    def query(self, query):
        return pd.read_sql(query, self.conn)

    def close(self):
        self.conn.close()

    def __del__(self):
        self.close()

def list_tables(db_path):
    conn = sqlite3.connect(db_path)
    query = "SELECT name FROM sqlite_master WHERE type='table';"
    tables = pd.read_sql(query, conn)
    return tables

# Example usage:
db_path = 'bacteria.db'  # replace with your actual database path
tables = list_tables(db_path)
print("Tables in database:", tables)


# Example usage:
db = BacteriaDatabase('bacteria.db')
columns = db.get_table_columns('gff')  # Change 'gff' to the correct table name
print("Columns in 'gff' table:", columns)

