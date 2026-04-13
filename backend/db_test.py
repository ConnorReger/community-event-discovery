import mysql.connector
from mysql.connector import Error

DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "database": "droppin_db",
    "user": "droppin",
    "password": "droppin",
}

def test_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        if conn.is_connected():
            cursor = conn.cursor()

            #check if all tables exist
            cursor.execute("SHOW TABLES;")
            tables = [row[0] for row in cursor.fetchall()]
            print(f"Connected to database '{DB_CONFIG['database']}'")
            print(f"   Tables found: {', '.join(tables)}")

            #sanity checks on row counts
            checks = ["Users", "Events", "Location", "Categories", "RSVPs"]
            for table in checks:
                cursor.execute(f"SELECT COUNT(*) FROM {table};")
                count = cursor.fetchone()[0]
                print(f"   {table}: {count} rows")

            cursor.close()
            conn.close()
            print("\nAll checks passed. DB is ready.")

    except Error as e:
        print(f"Connection failed: {e}")
        print("   Make sure Docker is running: docker compose up -d")

if __name__ == "__main__":
    test_connection()