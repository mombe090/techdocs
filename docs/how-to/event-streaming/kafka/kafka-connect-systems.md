# Integrating External Systems with Kafka Connect

## Overview

Learn how to use **Kafka Connect** to build data integration pipelines between Apache Kafka and external systems without writing custom code. This guide covers connector setup, configuration, Single Message Transforms (SMTs), and best practices for building production-ready data pipelines.

!!! info "What You'll Learn" - Understand Kafka Connect architecture - Configure source and sink connectors - Apply transformations with SMTs - Deploy and monitor connectors - Choose between self-managed and cloud-managed options

## Prerequisites

- Docker and Docker Compose installed
- Basic understanding of [Kafka topics and partitions](../../../tutorials/event-streaming/kafka/kafka-getting-started.md)
- Target system credentials (database, API, etc.)

---

## Quick Start: Run Kafka Connect with Docker Compose

Use this Docker Compose configuration to run Kafka with **KRaft** and **Kafka Connect** in distributed mode:

```yaml title="docker-compose.yml" linenums="1"
version: "3.8"

services:
  kafka:
    image: confluentinc/cp-kafka:latest # (1)!
    container_name: kafka-kraft
    ports:
      - "9092:9092"
    environment:
      # KRaft settings
      KAFKA_NODE_ID: 1
      KAFKA_PROCESS_ROLES: broker,controller
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092 # (2)!
      KAFKA_CONTROLLER_LISTENER_NAMES: CONTROLLER
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
      KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka:9093
      CLUSTER_ID: MkU3OEVBNTcwNTJENDM2Qk
      KAFKA_LOG_DIRS: /var/lib/kafka/data

      # Disable Confluent metrics (optional for minimal setup)
      KAFKA_CONFLUENT_SUPPORT_METRICS_ENABLE: "false" # (3)!
    volumes:
      - kafka-data:/var/lib/kafka/data
    healthcheck:
      test: ["CMD-SHELL", "kafka-broker-api-versions --bootstrap-server localhost:9092"]
      interval: 10s
      timeout: 5s
      retries: 5

  kafka-connect:
    image: confluentinc/cp-kafka-connect:latest # (4)!
    container_name: kafka-connect
    depends_on:
      kafka:
        condition: service_healthy
    ports:
      - "8083:8083" # (5)!
    environment:
      # Connect cluster settings
      CONNECT_BOOTSTRAP_SERVERS: kafka:9092 # (6)!
      CONNECT_REST_ADVERTISED_HOST_NAME: kafka-connect
      CONNECT_REST_PORT: 8083
      CONNECT_GROUP_ID: kafka-connect-cluster # (7)!

      # Topic configuration
      CONNECT_CONFIG_STORAGE_TOPIC: _connect-configs # (8)!
      CONNECT_OFFSET_STORAGE_TOPIC: _connect-offsets
      CONNECT_STATUS_STORAGE_TOPIC: _connect-status
      CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR: 1 # (9)!
      CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR: 1
      CONNECT_STATUS_STORAGE_REPLICATION_FACTOR: 1

      # Converter configuration
      CONNECT_KEY_CONVERTER: org.apache.kafka.connect.json.JsonConverter # (10)!
      CONNECT_VALUE_CONVERTER: org.apache.kafka.connect.json.JsonConverter
      CONNECT_KEY_CONVERTER_SCHEMAS_ENABLE: "false"
      CONNECT_VALUE_CONVERTER_SCHEMAS_ENABLE: "false"

      # Plugin path for connectors
      CONNECT_PLUGIN_PATH: /usr/share/java,/usr/share/confluent-hub-components # (11)!

      # Logging
      CONNECT_LOG4J_ROOT_LOGLEVEL: INFO
    volumes:
      - connect-plugins:/usr/share/confluent-hub-components
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8083/ || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  kafka-data:
    driver: local
  connect-plugins:
    driver: local
```

1. Confluent Platform Kafka image (includes KRaft mode)
2. Use service name `kafka` for internal communication between containers
3. Disable Confluent Support metrics collection for minimal local setup
4. Confluent Platform image includes many pre-installed connectors
5. Kafka Connect REST API port for managing connectors
6. Bootstrap servers pointing to Kafka service
7. Unique group ID for this Connect cluster
8. Internal topics for storing connector configs, offsets, and status
9. Replication factor 1 for development (use 3+ in production)
10. JSON converter for message serialization (can use Avro with Schema Registry)
11. Plugin path where connector JARs are loaded from

### Start Kafka Connect

```bash
# Start services
docker-compose up -d

# Wait for services to be ready
docker-compose ps

# Verify Kafka Connect is running
curl http://localhost:8083/

# List installed connectors
curl http://localhost:8083/connector-plugins | jq

# Stop services
docker-compose down
```

!!! tip "Install Additional Connectors"

````bash # Install connector from Confluent Hub (example: Elasticsearch Sink)
docker exec kafka-connect confluent-hub install \
 confluentinc/kafka-connect-elasticsearch:latest --no-prompt

    # Restart Connect to load new connector
    docker-compose restart kafka-connect
    ```

!!! warning "Production Considerations"
This is a minimal setup for development. For production: - Run multiple Connect workers (3+) for high availability - Set replication factor to 3 for internal topics - Enable SSL/SASL for secure communication - Use Avro with Schema Registry for data serialization - Monitor connector health and lag

## What is Kafka Connect?

!!! note "Kafka Connect Definition"
**Kafka Connect** is Kafka's integration framework for streaming data between Kafka and external systems. It provides:

    - **Plug-and-play connectors** for popular systems
    - **Declarative configuration** (JSON-based)
    - **Automatic scaling and fault tolerance**
    - **No custom code required** for most use cases

```mermaid
graph LR
    subgraph "External Systems"
    DB[(PostgreSQL<br/>Database)]
    SALES[Salesforce<br/>API]
    FILES[S3<br/>Bucket]
    end

    subgraph "Kafka Connect Cluster"
    SC1[Source<br/>Connector]
    SC2[Source<br/>Connector]
    SINK1[Sink<br/>Connector]
    end

    subgraph "Kafka Cluster"
    T1[Topic: orders]
    T2[Topic: customers]
    T3[Topic: analytics]
    end

    subgraph "Destination Systems"
    ES[(Elasticsearch)]
    DW[(Snowflake<br/>Data Warehouse)]
    end

    DB -->|Read changes| SC1
    SALES -->|Pull data| SC2
    SC1 -->|Produce| T1
    SC2 -->|Produce| T2
    T1 -->|Consume| SINK1
    T3 -->|Consume| SINK1
    SINK1 -->|Write| ES
    SINK1 -->|Write| DW

````

### Connector Types

<div class="grid cards" markdown>

- :material-import:{ .lg .middle } **Source Connectors**

  ***

  **Purpose:** Import data INTO Kafka

  **Examples:**
  - Database CDC (Debezium)
  - File sources (S3, HDFS)
  - Message queues (RabbitMQ)
  - APIs (Salesforce, REST)

  **Output:** Kafka topics

- :material-export:{ .lg .middle } **Sink Connectors**

  ***

  **Purpose:** Export data FROM Kafka

  **Examples:**
  - Databases (PostgreSQL, MySQL)
  - Search engines (Elasticsearch)
  - Data warehouses (Snowflake)
  - Object storage (S3, GCS)

  **Input:** Kafka topics

</div>

---

## Step 1: Set Up Kafka Connect

### Deployment Modes

Kafka Connect can run in two modes:

=== "Standalone Mode"

    !!! warning "Development Only"
        Standalone mode runs a single worker process. Use only for development and testing.

    ```bash title="Start standalone worker" linenums="1"
    # Edit config file
    vi config/connect-standalone.properties  # (1)!

    # Start worker with connector config
    bin/connect-standalone.sh \
        config/connect-standalone.properties \
        config/connector-config.json  # (2)!
    ```

    1. Worker configuration: bootstrap servers, key/value converters
    2. Connector configuration file (JSON)

=== "Distributed Mode (Production)"

    !!! success "Recommended for Production"
        Distributed mode runs a cluster of workers with automatic load balancing and fault tolerance.

    ```bash title="Start distributed worker" linenums="1"
    # Edit worker config
    vi config/connect-distributed.properties  # (1)!

    # Start each worker node
    bin/connect-distributed.sh \
        config/connect-distributed.properties  # (2)!

    # Workers form a cluster automatically
    # Deploy connectors via REST API  # (3)!
    ```

    1. Cluster configuration: group.id, offset storage topics
    2. Start on multiple machines for HA
    3. Use REST API (port 8083 by default) to manage connectors

### Worker Configuration

=== "Standalone Worker"

    ```properties title="connect-standalone.properties" linenums="1"
    bootstrap.servers=localhost:9092  # (1)!

    key.converter=org.apache.kafka.connect.json.JsonConverter  # (2)!
    value.converter=org.apache.kafka.connect.json.JsonConverter  # (3)!
    key.converter.schemas.enable=true
    value.converter.schemas.enable=true

    offset.storage.file.filename=/tmp/connect.offsets  # (4)!
    offset.flush.interval.ms=10000
    ```

    1. Kafka cluster address
    2. How to serialize keys (JSON, Avro, String)
    3. How to serialize values
    4. File-based offset storage (standalone only)

=== "Distributed Worker"

    ```properties title="connect-distributed.properties" linenums="1"
    bootstrap.servers=localhost:9092

    group.id=connect-cluster  # (1)!

    key.converter=org.apache.kafka.connect.json.JsonConverter
    value.converter=org.apache.kafka.connect.json.JsonConverter

    # Internal topics for coordination
    config.storage.topic=connect-configs  # (2)!
    config.storage.replication.factor=3

    offset.storage.topic=connect-offsets  # (3)!
    offset.storage.replication.factor=3

    status.storage.topic=connect-status  # (4)!
    status.storage.replication.factor=3

    # REST API
    rest.port=8083  # (5)!
    ```

    1. Unique cluster identifier - workers with same ID form a cluster
    2. Stores connector configurations
    3. Tracks source connector positions
    4. Stores connector and task statuses
    5. REST API endpoint for connector management

---

## Step 2: Configure Source Connectors

Source connectors bring data FROM external systems INTO Kafka.

### Example: PostgreSQL CDC with Debezium

!!! tip "Change Data Capture (CDC)"
CDC connectors capture database changes (inserts, updates, deletes) and stream them to Kafka in real-time.

```json title="postgres-source-connector.json" linenums="1"
{
  "name": "postgres-source", // (1)!
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector", // (2)!
    "tasks.max": "1", // (3)!

    "database.hostname": "localhost", // (4)!
    "database.port": "5432",
    "database.user": "postgres",
    "database.password": "secret",
    "database.dbname": "orders_db", // (5)!

    "database.server.name": "orders", // (6)!
    "table.include.list": "public.orders,public.customers", // (7)!

    "plugin.name": "pgoutput", // (8)!
    "publication.autocreate.mode": "filtered",

    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",

    "transforms": "route", // (9)!
    "transforms.route.type": "org.apache.kafka.connect.transforms.RegexRouter",
    "transforms.route.regex": "([^.]+)\\.([^.]+)\\.([^.]+)",
    "transforms.route.replacement": "$3"
  }
}
```

1. Unique connector name within the cluster
2. Fully qualified connector class name
3. Number of parallel tasks (scale based on tables/partitions)
4. Database connection details
5. Database name to capture changes from
6. Logical name used in topic naming
7. Whitelist specific tables (comma-separated)
8. PostgreSQL logical decoding plugin
9. Apply transformations (see SMTs section)

### Deploy the Connector

=== "REST API (Distributed)"

    ```bash
    # Create connector
    curl -X POST http://localhost:8083/connectors \  # (1)!
      -H "Content-Type: application/json" \
      -d @postgres-source-connector.json

    # Check status
    curl http://localhost:8083/connectors/postgres-source/status  # (2)!

    # List all connectors
    curl http://localhost:8083/connectors  # (3)!
    ```

    1. POST connector config to REST API
    2. Verify connector is RUNNING
    3. See all deployed connectors

=== "CLI (Standalone)"

    ```bash
    bin/connect-standalone.sh \
        config/connect-standalone.properties \
        postgres-source-connector.json  # (1)!
    ```

    1. Pass connector config as command-line argument

### Common Source Connectors

!!! info "Popular Source Connectors"
| Connector | Use Case | Data Format |
|-----------|----------|-------------|
| **Debezium (PostgreSQL, MySQL)** | Database CDC | JSON, Avro |
| **JDBC Source** | Poll database tables | JSON, Avro |
| **S3 Source** | Read files from S3 | CSV, JSON, Avro |
| **Salesforce** | Pull CRM data | JSON |
| **MongoDB** | Capture change streams | JSON, BSON |
| **Syslog** | Collect log events | String, JSON |

---

## Step 3: Configure Sink Connectors

Sink connectors send data FROM Kafka TO external systems.

### Example: Elasticsearch Sink

```json title="elasticsearch-sink-connector.json" linenums="1"
{
  "name": "elasticsearch-sink",
  "config": {
    "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector", // (1)!
    "tasks.max": "2", // (2)!

    "topics": "orders,customers", // (3)!

    "connection.url": "http://localhost:9200", // (4)!
    "connection.username": "elastic",
    "connection.password": "changeme",

    "type.name": "_doc", // (5)!
    "key.ignore": "false", // (6)!
    "schema.ignore": "false",

    "behavior.on.null.values": "delete", // (7)!
    "behavior.on.malformed.documents": "warn",

    "transforms": "unwrap", // (8)!
    "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
    "transforms.unwrap.drop.tombstones": "false"
  }
}
```

1. Elasticsearch sink connector class
2. Parallelize across partitions
3. Comma-separated list of topics to consume
4. Elasticsearch cluster connection
5. Document type (deprecated in ES 7+, use "\_doc")
6. Use Kafka message key as document ID
7. Delete ES document on null value (tombstone)
8. Unwrap Debezium CDC envelope

### Example: JDBC Sink (PostgreSQL)

```json title="jdbc-sink-connector.json" linenums="1"
{
  "name": "jdbc-sink",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
    "tasks.max": "1",

    "topics": "orders",

    "connection.url": "jdbc:postgresql://localhost:5432/analytics", // (1)!
    "connection.user": "analytics_user",
    "connection.password": "secret",

    "insert.mode": "upsert", // (2)!
    "pk.mode": "record_key", // (3)!
    "pk.fields": "order_id", // (4)!

    "table.name.format": "orders_from_kafka", // (5)!
    "auto.create": "true", // (6)!
    "auto.evolve": "true" // (7)!
  }
}
```

1. JDBC connection string
2. Insert mode: insert, upsert, or update
3. Primary key mode: record_key, record_value, or kafka
4. Fields to use as primary key
5. Target table name pattern
6. Auto-create table if doesn't exist
7. Auto-add columns when schema changes

### Common Sink Connectors

!!! info "Popular Sink Connectors"
| Connector | Use Case | Features |
|-----------|----------|----------|
| **Elasticsearch** | Search & analytics | Full-text search, real-time indexing |
| **JDBC Sink** | Relational databases | Upsert support, auto-create tables |
| **S3 Sink** | Data lake storage | Partitioning, compression, formats |
| **Snowflake** | Cloud data warehouse | Batch loading, schema evolution |
| **BigQuery** | Google analytics | Streaming inserts, partitioning |
| **MongoDB Sink** | Document database | Upsert, change stream compatibility |

---

## Step 4: Apply Single Message Transforms (SMTs)

!!! tip "Lightweight Transformations"
SMTs perform simple, stateless transformations on messages as they flow through connectors.

    **Use SMTs for:**

    - Adding/removing fields
    - Renaming fields
    - Filtering messages
    - Masking sensitive data
    - Routing to different topics

    **Don't use SMTs for:**

    - Stateful operations (aggregations, joins)
    - Complex business logic
    - Multi-message transformations

### Common SMT Examples

#### 1. Add Field (Context Enrichment)

```json
{
  "transforms": "addSource",
  "transforms.addSource.type": "org.apache.kafka.connect.transforms.InsertField$Value", // (1)!
  "transforms.addSource.static.field": "source_system", // (2)!
  "transforms.addSource.static.value": "production_db" // (3)!
}
```

1. SMT class for adding fields to value
2. Field name to add
3. Static value to set

**Result:**

```json
// Before
{"order_id": 123, "amount": 99.99}

// After
{"order_id": 123, "amount": 99.99, "source_system": "production_db"}
```

#### 2. Mask Sensitive Data

```json
{
  "transforms": "maskPII",
  "transforms.maskPII.type": "org.apache.kafka.connect.transforms.MaskField$Value",
  "transforms.maskPII.fields": "credit_card,ssn", // (1)!
  "transforms.maskPII.replacement": "****" // (2)!
}
```

1. Fields to mask
2. Replacement value

#### 3. Filter Messages

```json
{
  "transforms": "filter",
  "transforms.filter.type": "io.confluent.connect.transforms.Filter$Value", // (1)!
  "transforms.filter.filter.condition": "$.status == 'CANCELLED'", // (2)!
  "transforms.filter.filter.type": "exclude" // (3)!
}
```

1. Filter transform (requires Confluent license or custom SMT)
2. JSONPath condition
3. Exclude or include matching messages

#### 4. Rename Fields

```json
{
  "transforms": "rename",
  "transforms.rename.type": "org.apache.kafka.connect.transforms.ReplaceField$Value",
  "transforms.rename.renames": "old_name:new_name,user_id:customer_id" // (1)!
}
```

1. Comma-separated field mappings

#### 5. Route to Different Topics

```json
{
  "transforms": "route",
  "transforms.route.type": "org.apache.kafka.connect.transforms.RegexRouter",
  "transforms.route.regex": "(.*)orders(.*)", // (1)!
  "transforms.route.replacement": "$1orders_v2$2" // (2)!
}
```

1. Regex pattern to match topic name
2. Replacement pattern

### Chain Multiple Transforms

```json
{
  "transforms": "unwrap,addTimestamp,maskPII", // (1)!

  "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
  "transforms.unwrap.drop.tombstones": "false",

  "transforms.addTimestamp.type": "org.apache.kafka.connect.transforms.InsertField$Value",
  "transforms.addTimestamp.timestamp.field": "ingestion_time",

  "transforms.maskPII.type": "org.apache.kafka.connect.transforms.MaskField$Value",
  "transforms.maskPII.fields": "ssn,credit_card"
}
```

1. Applied in order: unwrap → add timestamp → mask PII

---

## Step 5: Monitor and Manage Connectors

### Connector Lifecycle

=== "Create"

    ```bash
    curl -X POST http://localhost:8083/connectors \
      -H "Content-Type: application/json" \
      -d @connector-config.json
    ```

=== "Status"

    ```bash
    curl http://localhost:8083/connectors/my-connector/status

    # Response:
    {
      "name": "my-connector",
      "connector": {
        "state": "RUNNING",  // (1)!
        "worker_id": "connect-worker-1:8083"
      },
      "tasks": [
        {
          "id": 0,
          "state": "RUNNING",  // (2)!
          "worker_id": "connect-worker-1:8083"
        }
      ]
    }
    ```

    1. Connector state: RUNNING, PAUSED, FAILED
    2. Task state - each task processes subset of data

=== "Pause/Resume"

    ```bash
    # Pause connector
    curl -X PUT http://localhost:8083/connectors/my-connector/pause  // (1)!

    # Resume connector
    curl -X PUT http://localhost:8083/connectors/my-connector/resume  // (2)!
    ```

    1. Stop processing without deleting configuration
    2. Restart from last committed offset

=== "Restart"

    ```bash
    # Restart connector
    curl -X POST http://localhost:8083/connectors/my-connector/restart

    # Restart specific task
    curl -X POST http://localhost:8083/connectors/my-connector/tasks/0/restart
    ```

=== "Update"

    ```bash
    # Update configuration
    curl -X PUT http://localhost:8083/connectors/my-connector/config \
      -H "Content-Type: application/json" \
      -d @updated-config.json  // (1)!
    ```

    1. Connector restarts automatically with new config

=== "Delete"

    ```bash
    curl -X DELETE http://localhost:8083/connectors/my-connector  // (1)!
    ```

    1. Removes connector and stops all tasks

### Monitoring Metrics

!!! info "Key Metrics to Monitor"
| Metric | Description | Action on Alert |
|--------|-------------|----------------|
| **Connector state** | RUNNING, PAUSED, FAILED | Restart if FAILED |
| **Task state** | Individual task status | Check logs, restart task |
| **Records processed** | Throughput rate | Scale tasks if slow |
| **Error count** | Failed message count | Check error logs, fix config |
| **Offset lag** | Source connector lag | Increase parallelism |

### Common Issues

??? bug "Troubleshooting Connectors"
**1. Connector Fails to Start**

````bash # Check logs
tail -f logs/connect.log

    # Common causes:
    # - Missing connector plugin
    # - Invalid configuration
    # - Network connectivity
    ```

    **2. Slow Performance**
    ```json
    {
      "tasks.max": "4"  // Increase parallelism
    }
    ```

    **3. Schema Evolution Errors**
    ```json
    {
      "value.converter.schemas.enable": "false",  // Disable schemas
      "auto.evolve": "true"  // Auto-adapt to schema changes
    }
    ```

    **4. Offset Corruption**
    ```bash
    # Reset offsets (consumer group)
    kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
      --group connect-my-connector \
      --reset-offsets --to-earliest --execute --all-topics
    ```

---

## Connector Ecosystem

### Confluent Hub

!!! tip "Connector Repository"
[Confluent Hub](https://www.confluent.io/hub/) provides 100+ certified connectors.

    **Install connectors:**
    ```bash
    # Install Confluent Hub CLI
    confluent-hub install confluentinc/kafka-connect-jdbc:10.7.4  // (1)!

    # List installed
    confluent-hub list
    ```

    1. Installs connector and dependencies

### Self-Managed vs Cloud-Managed

<div class="grid cards" markdown>

- :material-server:{ .lg .middle } **Self-Managed**

  ***

  **Pros:**
  - Full control over infrastructure
  - No vendor lock-in
  - Custom connectors

  **Cons:**
  - Operational overhead
  - Manual scaling
  - Security management

  **Use when:** Running on-premises or need custom connectors

- :material-cloud:{ .lg .middle } **Cloud-Managed (Confluent Cloud)**

  ***

  **Pros:**
  - Zero operational overhead
  - Auto-scaling
  - 80+ managed connectors

  **Cons:**
  - Vendor-specific
  - Limited customization

  **Use when:** Prefer managed services, standard connectors

</div>

---

## Best Practices

!!! success "Production Deployment Checklist"
**Configuration:**

    - [x] Use distributed mode for production
    - [x] Set replication factor ≥ 3 for internal topics
    - [x] Enable authentication and encryption
    - [x] Configure appropriate `tasks.max` for parallelism

    **Monitoring:**

    - [x] Monitor connector and task states
    - [x] Track throughput and lag metrics
    - [x] Set up alerts for FAILED state
    - [x] Log errors to centralized system

    **Data Quality:**

    - [x] Enable schema validation (Schema Registry)
    - [x] Use SMTs for data quality checks
    - [x] Handle schema evolution gracefully
    - [x] Test with sample data first

    **Performance:**

    - [x] Tune `batch.size` and `linger.ms`
    - [x] Adjust `tasks.max` based on load
    - [x] Use compression for large messages
    - [x] Monitor consumer lag

### SMT Best Practices

!!! warning "When NOT to Use SMTs"
SMTs are stateless and single-record. **Don't use SMTs for:**

    - Aggregations (use Kafka Streams/Flink)
    - Joins (use stream processing)
    - Complex business logic
    - Enrichment requiring external lookups

    **Instead:** Stream data to Kafka first, then process with dedicated stream processing.

---

## Complete Example: End-to-End Pipeline

Here's a complete data pipeline from PostgreSQL to Elasticsearch:

```bash title="deploy-pipeline.sh" linenums="1"
#!/bin/bash

# 1. Deploy PostgreSQL source connector
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "postgres-orders-source",
    "config": {
      "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
      "tasks.max": "1",
      "database.hostname": "postgres.example.com",
      "database.port": "5432",
      "database.user": "kafka_connect",
      "database.password": "${file:/secrets/db-password.txt:password}",
      "database.dbname": "production",
      "database.server.name": "orders_db",
      "table.include.list": "public.orders",
      "plugin.name": "pgoutput",

      "transforms": "unwrap,addSource",
      "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
      "transforms.addSource.type": "org.apache.kafka.connect.transforms.InsertField$Value",
      "transforms.addSource.static.field": "source",
      "transforms.addSource.static.value": "production_postgres"
    }
  }'

# 2. Deploy Elasticsearch sink connector
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "elasticsearch-orders-sink",
    "config": {
      "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
      "tasks.max": "2",
      "topics": "orders",
      "connection.url": "https://elasticsearch.example.com:9200",
      "connection.username": "kafka_connect",
      "connection.password": "${file:/secrets/es-password.txt:password}",
      "type.name": "_doc",
      "key.ignore": "false",
      "behavior.on.null.values": "delete"
    }
  }'

# 3. Check status
echo "Waiting for connectors to start..."
sleep 5

curl http://localhost:8083/connectors/postgres-orders-source/status
curl http://localhost:8083/connectors/elasticsearch-orders-sink/status
````

---

## What's Next?

!!! tip "Continue Learning" - [:fontawesome-solid-diagram-project: **Use Schema Registry**](kafka-use-schema-registry.md) - Manage schemas for data quality - [:fontawesome-solid-stream: **Process Streams**](kafka-stream-processing.md) - Transform data with Flink or Kafka Streams - [:fontawesome-solid-paper-plane: **Produce Messages**](kafka-produce-messages.md) - Write custom producers - [:fontawesome-solid-download: **Consume Messages**](kafka-consume-messages.md) - Write custom consumers

## Additional Resources

- [Kafka Connect Documentation](https://kafka.apache.org/documentation/#connect)
- [Kafka Connect 101 Course](https://developer.confluent.io/learn-kafka/kafka-connect/intro/)
- [Confluent Hub - Connector Repository](https://www.confluent.io/hub/)
- [Debezium CDC Connectors](https://debezium.io/documentation/)
- [Single Message Transforms Reference](https://kafka.apache.org/documentation/#connect_transforms)

---

!!! info "Hands-On Practice"
Try the interactive [Kafka Connect exercise](https://developer.confluent.io/courses/apache-kafka/exercise-kafka-connect/) from Confluent to practice deploying connectors.
