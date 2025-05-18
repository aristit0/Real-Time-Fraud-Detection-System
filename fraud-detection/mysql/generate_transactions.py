import mysql.connector
import time
import random
import uuid
from datetime import datetime, timedelta

# --- CONFIGURATION ---
DB_CONFIG = {
    'host': 'localhost',        # or your MySQL server
    'user': 'root',
    'password': 'Admin123',
    'database': 'transaction'
}
TABLE_NAME = 'fraud_transaction_data'
TOTAL_ROWS = 1_000_000
BATCH_SIZE = 1000
DELAY_SECONDS = 1


def create_table_if_not_exists(cursor):
    cursor.execute(f"""
    CREATE TABLE IF NOT EXISTS {TABLE_NAME} (
        transaction_id VARCHAR(36) PRIMARY KEY,
        account_id VARCHAR(36),
        amount DECIMAL(12, 2),
        transaction_type VARCHAR(10),
        location VARCHAR(100),
        device_id VARCHAR(36),
        timestamp DATETIME
    );
    """)


def generate_row():
    return (
        str(uuid.uuid4()),
        str(uuid.uuid4()),
        round(random.uniform(10, 5000), 2),
        random.choice(['DEBIT', 'CREDIT']),
        random.choice(['Jakarta', 'Singapore', 'New York', 'London', 'Tokyo']),
        str(uuid.uuid4()),
        datetime.now() - timedelta(seconds=random.randint(0, 300))
    )


def main():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    create_table_if_not_exists(cursor)

    print(f"Inserting {TOTAL_ROWS} rows into `{TABLE_NAME}` in batches of {BATCH_SIZE}...")

    for batch_start in range(0, TOTAL_ROWS, BATCH_SIZE):
        batch = [generate_row() for _ in range(BATCH_SIZE)]
        cursor.executemany(
            f"INSERT INTO {TABLE_NAME} (transaction_id, account_id, amount, transaction_type, location, device_id, timestamp) VALUES (%s, %s, %s, %s, %s, %s, %s)",
            batch
        )
        conn.commit()
        print(f"Inserted rows {batch_start + 1} to {batch_start + BATCH_SIZE}")
        time.sleep(DELAY_SECONDS)

    cursor.close()
    conn.close()
    print("Data generation complete.")


if __name__ == '__main__':
    main()