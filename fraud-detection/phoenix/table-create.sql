CREATE TABLE fraud_alerts (
  transaction_id VARCHAR PRIMARY KEY,
  account_id VARCHAR,
  amount VARCHAR,
  fraud_type VARCHAR,
  flagged_time TIMESTAMP
);