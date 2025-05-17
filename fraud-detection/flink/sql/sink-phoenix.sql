CREATE TABLE phoenix_fraud_alerts (
  transaction_id STRING,
  account_id STRING,
  amount STRING,
  fraud_type STRING,
  flagged_time TIMESTAMP,
  PRIMARY KEY (transaction_id) NOT ENFORCED
) WITH (
  'connector' = 'jdbc',
  'url' = 'jdbc:phoenix:thin:url=http://cdpm3.cloudeka.ai:8765;serialization=PROTOBUF',
  'table-name' = 'fraud_alerts',
  'driver' = 'org.apache.phoenix.queryserver.client.Driver'
);