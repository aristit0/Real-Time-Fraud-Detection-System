# Real-Time-Fraud-Detection-System

Use Case Overview:

Building a system to detect fraudulent financial transactions in real time. The system should:
	•	Ingest transactions as they happen
	•	Enrich with reference data (e.g., blacklist, geo data)
	•	Identify suspicious patterns (e.g., multiple withdrawals in seconds, location mismatch)
	•	Trigger alerts and store data for historical analysis

🧱 Architecture Overview:
[Database/Apps/ATM] → NiFi → Kafka → Flink + SQL Stream Builder → Kafka/HBase/Phoenix → Alerts/Hive
                                       ↘
                                 Real-time Rules

⚙️ Components and Responsibilities

1. Kafka (Stream Transport)
	•	Source Topics: transactions, user_profile, geo_blacklist
	•	Messages include:
	•	transaction_id, account_id, timestamp, amount, location, device_id, channel

⸻

2. Schema Registry
	•	Define schemas for each topic using Avro or JSON
	•	Ensures consistent serialization/deserialization between NiFi → Kafka → Flink

⸻

3. NiFi (Data Ingestion & Enrichment)
	•	Ingest from:
	•	REST APIs (mobile, web, ATM)
	•	RDBMS (CDC via Debezium, JDBC polling)
	•	Transform and enrich:
	•	Add geolocation, device reputation, account type
	•	Route to appropriate Kafka topic

💡 Example processors:
	•	ConvertRecord (JSON to Avro)
	•	UpdateRecord (enrich with NiFi LookupService)
	•	PublishKafkaRecord_2_6

⸻

4. Flink + SQL Stream Builder (Real-Time Fraud Logic)

Fraud detection examples:
	•	Velocity check: 3+ transactions within 10 seconds
	•	Geo anomaly: user logged in from Jakarta, then next ATM withdrawal from New York in 1 minute
	•	High value: Amount > defined threshold for this account type

Use SQL Stream Builder (SSB) for rule-based detection:
SELECT
  account_id,
  COUNT(*) AS txn_count,
  TUMBLE_START(proctime, INTERVAL '10' SECOND) as window_start
FROM
  transactions
GROUP BY
  TUMBLE(proctime, INTERVAL '10' SECOND), account_id
HAVING
  txn_count > 3

Or use pattern matching (CEP) for event sequences:
SELECT *
FROM PATTERN (
  A -> B -> C
  WHERE A.amount > 1000 AND B.amount > 1000 AND C.amount > 1000
  WITHIN INTERVAL '30' SECONDS
)

5. Phoenix + HBase (Real-Time Data Store)
	•	Store:
	•	User profile cache (for joins)
	•	Recent flagged events (for alert de-duplication)
	•	Fast lookup/update of flags, counters, risk scores

💡 Example:
	•	Table: fraud_flags
	•	Columns: account_id, last_flagged_time, fraud_score

6. Hive (Analytics & BI)
	•	Archive all events
	•	Build dashboards in Hue / Power BI / Looker
	•	Train ML models for advanced fraud detection (offline)

7. Optional: Alerting System
	•	Flink output → Kafka topic fraud_alerts
	•	NiFi or microservice subscribes and triggers:
	•	Email/SMS
	•	Case creation in CRM
	•	Risk engine updates

📂 Folder Structure (Sample)
fraud-detection/
├── nifi/
│   ├── templates/
│   └── lookups/
├── flink/
│   ├── sql/
│   └── cep/
├── schema-registry/
│   └── avro/
├── kafka/
│   └── topics.txt
├── hive/
│   └── table-definitions/
├── phoenix/
│   └── table-create.sql
