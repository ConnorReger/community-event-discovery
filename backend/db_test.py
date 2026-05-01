import os
import mysql.connector
from mysql.connector import Error

def db_config_from_env():
    """Load DB config from environment variables for local Docker setup."""
    return {
        "host": os.environ.get("DB_HOST", "localhost"),
        "port": int(os.environ.get("DB_PORT", 3306)),
        "database": os.environ.get("DB_NAME", "droppin_db"),
        "user": os.environ.get("DB_USER", "droppin"),
        "password": os.environ.get("DB_PASSWORD", "droppin"),
    }

DB_CONFIG = db_config_from_env()

def test_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        if conn.is_connected():
            cursor = conn.cursor()

            # check if all essential tables exist (case-sensitive depending on OS)
            cursor.execute("SHOW TABLES;")
            tables = [row[0] for row in cursor.fetchall()]
            print(f"Connected to database '{DB_CONFIG['database']}'")
            print(f"   Tables found: {', '.join(tables)}")

            # basic sanity checks on common tables
            for table in ("Users", "Events", "Location", "Categories", "RSVPs"):
                try:
                    cursor.execute(f"SELECT COUNT(*) FROM {table};")
                    count = cursor.fetchone()[0]
                    print(f"   {table}: {count} rows")
                except Error:
                    print(f"   Warning: table {table} not found or inaccessible in this DB schema.")

            cursor.close()
            conn.close()
            print("\nDB readiness check complete.")

    except Error as e:
        print(f"Connection failed: {e}")
        print("   Make sure Docker is running: docker compose up -d")

if __name__ == "__main__":
    test_connection()
