## 🛡 Real-Time Fraud Detection System

This project implements a real-time fraud detection pipeline using Kafka, Flink, NiFi, and Iceberg. The system ingests transactions, applies fraud detection logic, and stores flagged alerts in a queryable data lake format.

---

### 📥 Ingestion Layer: Kafka

- **Source Topic:** `transaction.transaction.fraud_transaction_data`
- **Format:** JSON (`payload.after.*`)
- **Security:** SASL_SSL + Kerberos
- **Startup Mode:** `group-offsets`

---

### 🧠 Processing Layer: Apache Flink SQL

#### Flink Job Logic:
- **Input Table:** `fraud_transaction_flattened`
- **Output Table:** `fraud_alerts` (Kafka)

#### Fraud Rules:
1. **Account-Device Mismatch**: Same account on different devices within 5s
2. **Device Location Anomaly**: Same device in multiple locations within 30s
3. **Repeated High Spend**: Same account with >100k transactions within 10s

#### Output Fields:
- `transaction_id`, `account_id`, `amount`, `fraud_type`, `flagged_time`

---

### 📤 Output Layer: Kafka (`fraud_alerts` topic)

- **Format:** Flat JSON
- **Field of concern:** `flagged_time` uses `CURRENT_TIMESTAMP`

---

### 🔄 Integration Layer: Apache NiFi

#### Flow:
1. **ConsumeKafkaRecord_2_0** → reads from `fraud_alerts`
2. **ConvertRecord** → parses JSON using defined schema
3. **PutIceberg** → writes to Iceberg table

#### Schema Highlights:
- `flagged_time`: converted to `timestamp-millis` (Avro long)
- `amount`: stored as string, optionally upgradable to `decimal(32,2)`

---

### ❄ Iceberg Table

- **Catalog:** Hive (`thrift://cdpm2.cloudeka.ai:9083`)
- **Table:** `fraud_alerts.datamart.fraud_alerts`
- **Format:** Parquet
- **Storage:** HDFS (`/warehouse/tablespace/external/hive/datamart.db/fraud_alerts`)
- **Properties:**
  - `sink.parallelism = 1`
  - `sink.commit-policy = success-file`
  - `write.upsert.enabled = false`

---

### ✅ Notes

- NiFi handles schema conversion (timestamp string → millis)
- Flink and Spark access the same Iceberg table through Hive catalog
- Iceberg supports SQL-based analysis, time travel, and optimized storage

---

Feel free to extend this pipeline with dashboards, alerting, or model-based scoring in the future.