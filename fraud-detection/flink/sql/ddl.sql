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

CREATE TABLE `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_transaction_flattened` (
  `payload` ROW<`after` ROW<`transaction_id` VARCHAR(2147483647), `account_id` VARCHAR(2147483647), `amount` VARCHAR(2147483647), `transaction_type` VARCHAR(2147483647), `location` VARCHAR(2147483647), `device_id` VARCHAR(2147483647), `timestamp` BIGINT>>
) WITH (
  'properties.ssl.truststore.password' = 'Admin123',
  'properties.auto.offset.reset' = 'earliest',
  'properties.ssl.keystore.password' = 'Admin123',
  'format' = 'json',
  'properties.security.protocol' = 'SASL_SSL',
  'scan.startup.mode' = 'group-offsets',
  'properties.bootstrap.servers' = 'cdpm1.cloudeka.ai:9093,cdpm2.cloudeka.ai:9093,cdpm3.cloudeka.ai:9093',
  'properties.ssl.keystore.location' = '/opt/kafka-conf/cm-auto-host_keystore.jks',
  'connector' = 'kafka',
  'properties.request.timeout.ms' = '120000',
  'properties.ssl.truststore.location' = '/opt/kafka-conf/cm-auto-global_truststore.jks',
  'properties.transaction.timeout.ms' = '900000',
  'topic' = 'transaction.transaction.fraud_transaction_data',
  'properties.group.id' = 'fraud_transaction_customer_group',
  'properties.sasl.kerberos.service.name' = 'kafka'
)





#### kafka sink
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


CREATE TABLE `ssb`.`Real-Time-Fraud-Detection-System`.`fraud_alerts` (
  `transaction_id` VARCHAR(2147483647),
  `account_id` VARCHAR(2147483647),
  `amount` VARCHAR(2147483647),
  `fraud_type` VARCHAR(2147483647),
  `flagged_time` TIMESTAMP(6)
) WITH (
  'properties.bootstrap.servers' = 'cdpm1.cloudeka.ai:9093,cdpm2.cloudeka.ai:9093,cdpm3.cloudeka.ai:9093',
  'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.plain.PlainLoginModule required username="cmluser" password="hwj5GpM8rVgy";',
  'connector' = 'kafka',
  'properties.sasl.mechanism' = 'PLAIN',
  'format' = 'json',
  'properties.security.protocol' = 'SASL_SSL',
  'topic' = 'fraud_alerts',
  'properties.group.id' = 'fraud-alerts-consumer-group',
  'scan.startup.mode' = 'earliest-offset',
  'properties.sasl.kerberos.service.name' = 'kafka'
)




#iceberg sink

CREATE TABLE `fraud_alerts` (
    transaction_id STRING,
    account_id STRING,
    amount STRING,
    fraud_type STRING,
    flagged_time TIMESTAMP
) WITH (
  'connector' = 'iceberg',
  'catalog-name' = 'hive',
  'catalog-type' = 'hive',
  'catalog-database' = 'datamart',
  'catalog-table' = 'fraud_alerts',
  'engine.hive.enabled' = 'true',
  'ssb-hive-catalog' = 'ssb_hive_catalog'
);





result
CREATE EXTERNAL TABLE datamart.fraud_alerts
 ( transaction_id STRING NULL, account_id STRING NULL, amount STRING NULL, fraud_type STRING NULL, flagged_time TIMESTAMP NULL )
  STORED AS ICEBERG LOCATION 'hdfs://cloudeka-hdfs/warehouse/tablespace/external/hive/datamart.db/fraud_alerts'
  TBLPROPERTIES ('catalog-database'='datamart', 'catalog-name'='fraud_alerts', 'catalog-table'='fraud_alerts', 
  'catalog-type'='hive', 'connector'='iceberg', 'engine.hive.enabled'='true', 'properties.group.id'='fraud-alerts-iceberg',
   'scan.startup.mode'='earliest-offset', 'sink.commit-policy'='success-file', 'sink.parallelism'='1', 'table_type'='ICEBERG', 'write.upsert.enabled'='false')


/etc/hadoop/conf/hdfs-site.xml,
/etc/hadoop/conf/mapred-site.xml,
/etc/hadoop/conf/ssl-client.xml,
/etc/hadoop/conf/core-site.xml,
/etc/hadoop/conf/yarn-site.xml,
/etc/hadoop/conf/ozone-site.xml

/opt/kafka-conf/cm-auto-host_keystore.jks


/opt/kafka-conf/cm-auto-global_truststore.jks