import os
import psycopg2
from mt5linux import MetaTrader5
import pandas as pd

# Connect to PostgreSQL (use POSTGRES_HOST for separate container setup)
conn = psycopg2.connect(
    host=os.environ.get("POSTGRES_HOST", "postgres"),
    port=int(os.environ.get("POSTGRES_PORT", "5432")),
    database=os.environ.get("POSTGRES_DB", "mt5_data"),
    user=os.environ.get("POSTGRES_USER", "tepafril"),
    password=os.environ.get("POSTGRES_PASSWORD", "316619AAbbcc**!!")
)
cursor = conn.cursor()

# Create table
cursor.execute("""
    CREATE TABLE IF NOT EXISTS ohlc_data (
        id SERIAL PRIMARY KEY,
        symbol VARCHAR(20),
        timeframe VARCHAR(10),
        time TIMESTAMP,
        open DECIMAL(10,5),
        high DECIMAL(10,5),
        low DECIMAL(10,5),
        close DECIMAL(10,5),
        volume BIGINT
    )
""")
conn.commit()

# Get data from MT5
mt5 = MetaTrader5(host='localhost', port=8001)
mt5.initialize()

rates = mt5.copy_rates_from_pos("XAUUSD", mt5.TIMEFRAME_D1, 0, 100)
df = pd.DataFrame(rates)
df['time'] = pd.to_datetime(df['time'], unit='s')

# Insert into PostgreSQL
for _, row in df.iterrows():
    cursor.execute("""
        INSERT INTO ohlc_data (symbol, timeframe, time, open, high, low, close, volume)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """, ('XAUUSD', 'D1', row['time'], row['open'], row['high'], 
          row['low'], row['close'], row['tick_volume']))

conn.commit()
print(f"✅ Inserted {len(df)} records")
for idx, row in df.iterrows():
    print(f"  [{idx}] {row.to_dict()}")

mt5.shutdown()
cursor.close()
conn.close()