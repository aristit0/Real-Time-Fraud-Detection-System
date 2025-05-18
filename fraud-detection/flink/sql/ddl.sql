#### Realtime data transaction 
CREATE TABLE `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_transaction_flattened` (
  `payload` ROW<
    `after` ROW<
      `transaction_id` STRING,
      `account_id` STRING,
      `amount` STRING,
      `transaction_type` STRING,
      `location` STRING,
      `device_id` STRING,
      `timestamp` BIGINT
    >
  >
)
WITH (
  'properties.ssl.truststore.password' = 'Admin123',
  'properties.auto.offset.reset' = 'earliest',
  'properties.ssl.keystore.password' = 'Admin123',
  'format' = 'json',
  'properties.security.protocol' = 'SASL_SSL',
  'scan.startup.mode' = 'latest-offset',
  'properties.bootstrap.servers' = 'cdpm1.cloudeka.ai:9093,cdpm2.cloudeka.ai:9093,cdpm3.cloudeka.ai:9093',
  'properties.ssl.keystore.location' = '/opt/kafka-conf/cm-auto-host_keystore.jks',
  'connector' = 'kafka',
  'properties.request.timeout.ms' = '120000',
  'properties.ssl.truststore.location' = '/opt/kafka-conf/cm-auto-global_truststore.jks',
  'properties.transaction.timeout.ms' = '900000',
  'topic' = 'transaction.transaction.fraud_transaction_data',
  'properties.group.id' = 'fraud_transaction_customer_group',
  'properties.sasl.kerberos.service.name' = 'kafka'
);



#### Fraud Alerts DDL
DROP TABLE IF EXISTS `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_alerts`;

CREATE TABLE `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_alerts` (
  `transaction_id` STRING,
  `account_id` STRING,
  `amount` STRING,
  `fraud_type` STRING,
  `flagged_time` TIMESTAMP  -- ✅ No (3), no WITH TIME ZONE
) WITH (
  'connector' = 'kafka',
  'topic' = 'fraud_alerts',
  'format' = 'json',
  'properties.bootstrap.servers' = 'cdpm1.cloudeka.ai:9093,cdpm2.cloudeka.ai:9093,cdpm3.cloudeka.ai:9093',
  'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.plain.PlainLoginModule required username="cmluser" password="hwj5GpM8rVgy";',
  'properties.sasl.mechanism' = 'PLAIN',
  'properties.security.protocol' = 'SASL_SSL',
  'properties.group.id' = 'fraud-alerts-consumer-group',
  'scan.startup.mode' = 'latest-offset',
  'properties.sasl.kerberos.service.name' = 'kafka'
);