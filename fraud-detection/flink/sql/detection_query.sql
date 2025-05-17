-- High amount detection
SELECT
  transaction_id,
  account_id,
  amount,
  'HIGH_VALUE_TXN' AS fraud_type,
  CURRENT_TIMESTAMP AS flagged_time
FROM transactions
WHERE CAST(amount AS DOUBLE) > 100000000

UNION ALL

-- Rapid repeat device usage
SELECT
  t1.transaction_id,
  t1.account_id,
  t1.amount,
  'MULTI_DEVICE_TXN' AS fraud_type,
  CURRENT_TIMESTAMP AS flagged_time
FROM transactions t1
JOIN transactions t2
  ON t1.device_id = t2.device_id
  AND t1.transaction_id != t2.transaction_id
  AND ABS(t1.timestamp - t2.timestamp) <= 5000