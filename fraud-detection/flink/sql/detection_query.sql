INSERT INTO `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_alerts`
SELECT
  transaction_id,
  account_id,
  amount,
  'HIGH_VALUE_TXN' AS fraud_type,
  CURRENT_TIMESTAMP AS flagged_time
FROM `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_transaction_flattened`
WHERE CAST(amount AS DOUBLE) > 100000000

UNION ALL

SELECT
  t1.transaction_id,
  t1.account_id,
  t1.amount,
  'MULTI_DEVICE_TXN' AS fraud_type,
  CURRENT_TIMESTAMP AS flagged_time
FROM `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_transaction_flattened` t1
JOIN `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_transaction_flattened` t2
  ON t1.device_id = t2.device_id
  AND t1.transaction_id <> t2.transaction_id
  AND ABS(t1.timestamp - t2.timestamp) <= 5000;