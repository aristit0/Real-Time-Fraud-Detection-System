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
  AND ABS(t1.timestamp - t2.timestamp) <= 5000;INSERT INTO `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_alerts`

-- Rule 1: Account used on different devices in 5s window
SELECT
  t1.transaction_id,
  t1.account_id,
  t1.amount,
  'ACCOUNT_DEVICE_MISMATCH' AS fraud_type,
  CURRENT_TIMESTAMP AS flagged_time
FROM `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_transaction_flattened` t1
JOIN `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_transaction_flattened` t2
  ON t1.account_id = t2.account_id
  AND t1.device_id <> t2.device_id
  AND ABS(t1.`timestamp` - t2.`timestamp`) <= 5000
  AND t1.transaction_id <> t2.transaction_id

UNION ALL

-- Rule 2: Same device used in multiple locations in 30s
SELECT
  t1.transaction_id,
  t1.account_id,
  t1.amount,
  'DEVICE_LOCATION_ANOMALY' AS fraud_type,
  CURRENT_TIMESTAMP AS flagged_time
FROM `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_transaction_flattened` t1
JOIN `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_transaction_flattened` t2
  ON t1.device_id = t2.device_id
  AND t1.location <> t2.location
  AND ABS(t1.`timestamp` - t2.`timestamp`) <= 30000
  AND t1.transaction_id <> t2.transaction_id

UNION ALL

-- Rule 3: Two high-value txns from same account within 10s
SELECT
  t1.transaction_id,
  t1.account_id,
  t1.amount,
  'REPEATED_HIGH_SPEND' AS fraud_type,
  CURRENT_TIMESTAMP AS flagged_time
FROM `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_transaction_flattened` t1
JOIN `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_transaction_flattened` t2
  ON t1.account_id = t2.account_id
  AND t1.transaction_id <> t2.transaction_id
  AND CAST(t1.amount AS DOUBLE) > 100000
  AND CAST(t2.amount AS DOUBLE) > 100000
  AND ABS(t1.`timestamp` - t2.`timestamp`) <= 10000;




