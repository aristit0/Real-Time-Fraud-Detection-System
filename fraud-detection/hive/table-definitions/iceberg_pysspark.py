from pyspark.sql import SparkSession

# Initialize Spark with Iceberg Hive catalog
spark = SparkSession.builder \
    .appName("Recreate Iceberg Table") \
    .config("spark.sql.catalog.fraud_alerts", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.fraud_alerts.type", "hive") \
    .config("spark.sql.catalog.fraud_alerts.uri", "thrift://cdpm2.cloudeka.ai:9083") \
    .config("spark.sql.iceberg.handle-timestamp-without-timezone", "true") \
    .getOrCreate()

# Drop the existing table if it exists
spark.sql("DROP TABLE IF EXISTS fraud_alerts.datamart.fraud_alerts")

# Create a new Iceberg table (backed by Parquet files)
spark.sql("""
CREATE TABLE fraud_alerts.datamart.fraud_alerts (
  transaction_id STRING,
  account_id STRING,
  amount DECIMAL(32,2),
  fraud_type STRING,
  flagged_time TIMESTAMP
)
USING iceberg
TBLPROPERTIES (
  'format-version'='2',
  'write.format.default'='parquet',
  'write.upsert.enabled'='false',
  'sink.parallelism'='1',
  'sink.commit-policy'='success-file'
)
""")