CREATE TABLE transactions (
  transaction_id STRING,
  account_id STRING,
  amount STRING,
  transaction_type STRING,
  location STRING,
  device_id STRING,
  timestamp BIGINT,
  op STRING
) WITH (
  'connector' = 'kafka',
  'topic' = 'transaction_data.transaction.transaction_data',
  'format' = 'avro',
  'scan.startup.mode' = 'latest-offset'
);