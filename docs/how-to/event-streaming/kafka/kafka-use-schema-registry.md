# Use Kafka Schema Registry

Learn how to manage data schemas, ensure compatibility, and serialize data efficiently with Kafka Schema Registry.

---

## What You'll Learn

By the end of this guide, you'll be able to:

- ✅ Understand why schema management is critical for data integrity
- ✅ Set up and configure Kafka Schema Registry
- ✅ Register and evolve schemas with compatibility rules
- ✅ Serialize and deserialize data using Avro, Protobuf, and JSON Schema
- ✅ Integrate Schema Registry with producers and consumers
- ✅ Handle schema evolution in production systems

**Prerequisites:**

- Docker and Docker Compose installed
- Basic understanding of producers and consumers
- Familiarity with data serialization formats

**Estimated Time:** 30 minutes

---

## Quick Start: Run Kafka with Schema Registry

Use this Docker Compose configuration to run Kafka with **KRaft** and **Schema Registry**:

```yaml title="docker-compose.yml" linenums="1"
version: "3.8"

services:
  kafka:
    image: confluentinc/cp-kafka:latest # (1)!
    container_name: kafka-kraft
    ports:
      - "9092:9092"
    environment:
      KAFKA_NODE_ID: 1
      KAFKA_PROCESS_ROLES: broker,controller
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
      KAFKA_CONTROLLER_LISTENER_NAMES: CONTROLLER
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
      KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka:9093
      CLUSTER_ID: MkU3OEVBNTcwNTJENDM2Qk
      KAFKA_LOG_DIRS: /var/lib/kafka/data
    volumes:
      - kafka-data:/var/lib/kafka/data
    healthcheck:
      test: ["CMD-SHELL", "kafka-broker-api-versions --bootstrap-server localhost:9092"]
      interval: 10s
      timeout: 5s
      retries: 5

  schema-registry:
    image: confluentinc/cp-schema-registry:latest # (1)!
    container_name: schema-registry
    depends_on:
      kafka:
        condition: service_healthy
    ports:
      - "8081:8081" # (2)!
    environment:
      SCHEMA_REGISTRY_HOST_NAME: schema-registry # (3)!
      SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS: kafka:9092 # (4)!
      SCHEMA_REGISTRY_LISTENERS: http://0.0.0.0:8081 # (5)!
      SCHEMA_REGISTRY_KAFKASTORE_TOPIC: _schemas # (6)!
      SCHEMA_REGISTRY_KAFKASTORE_TOPIC_REPLICATION_FACTOR: 1 # (7)!
      SCHEMA_REGISTRY_SCHEMA_REGISTRY_INTER_INSTANCE_PROTOCOL: http
      SCHEMA_REGISTRY_LOG4J_ROOT_LOGLEVEL: INFO
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8081/ || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  kafka-data:
    driver: local
```

1. Confluent Schema Registry image - compatible with Apache Kafka
2. Schema Registry REST API port
3. Hostname for service discovery
4. Kafka bootstrap servers for storing schemas
5. REST API endpoint for schema operations
6. Internal Kafka topic for storing schemas (created automatically)
7. Replication factor 1 for development (use 3+ in production)

### Start Services

```bash
# Start Kafka and Schema Registry
docker-compose up -d

# Wait for services to be ready
docker-compose ps

# Verify Schema Registry is running
curl http://localhost:8081/

# Check subjects (should be empty initially)
curl http://localhost:8081/subjects

# Stop services
docker-compose down
```

!!! tip "Test Schema Registration"

````bash # Register a simple Avro schema
curl -X POST http://localhost:8081/subjects/test-value/versions \
 -H "Content-Type: application/vnd.schemaregistry.v1+json" \
 -d '{
"schema": "{\"type\":\"record\",\"name\":\"Test\",\"fields\":[{\"name\":\"id\",\"type\":\"string\"}]}"
}'

    # List subjects (should show "test-value")
    curl http://localhost:8081/subjects
    ```

!!! warning "Production Considerations"
For production deployments: - Run multiple Schema Registry instances (3+) for high availability - Set replication factor to 3 for `_schemas` topic - Enable authentication (basic auth or mutual TLS) - Use HTTPS for Schema Registry REST API - Monitor Schema Registry availability and latency

---

## What is Schema Registry?

**Schema Registry** is a centralized repository for managing and validating data schemas. It ensures that producers and consumers agree on the structure of messages, preventing data corruption and enabling safe schema evolution.

!!! info "Why Use Schema Registry?"
Without Schema Registry, incompatible schema changes can break consumers. Schema Registry enforces **compatibility rules** that prevent breaking changes from being deployed.

```mermaid
graph LR
    A[Producer] -->|1. Register Schema| B[Schema Registry]
    B -->|2. Return Schema ID| A
    A -->|3. Send Message<br/>with Schema ID| C[Kafka Topic]
    D[Consumer] -->|4. Fetch Message| C
    D -->|5. Get Schema by ID| B
    B -->|6. Return Schema| D
    D -->|7. Deserialize| D

````

!!! tip "Schema Registry Benefits" - **Data Integrity:** Prevents incompatible data from entering topics - **Schema Evolution:** Supports adding/removing fields without breaking consumers - **Bandwidth Savings:** Messages only contain a small schema ID instead of full schema - **Compatibility Enforcement:** Multiple compatibility modes (backward, forward, full)

---

## Step 1: Set Up Schema Registry

### Installation

=== ":simple-docker: Docker Compose"

    ```yaml title="docker-compose.yml" linenums="1" hl_lines="12-21"
    services:
      zookeeper:
        image: confluentinc/cp-zookeeper:latest
        environment:
          ZOOKEEPER_CLIENT_PORT: 2181

      kafka:
        image: confluentinc/cp-kafka:latest
        depends_on: [zookeeper]
        # ... kafka configuration

      schema-registry:  # (1)!
        image: confluentinc/cp-schema-registry:latest
        depends_on: [kafka]
        ports:
          - "8081:8081"  # (2)!
        environment:
          SCHEMA_REGISTRY_HOST_NAME: schema-registry  # (3)!
          SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS: kafka:9092  # (4)!
          SCHEMA_REGISTRY_LISTENERS: http://0.0.0.0:8081  # (5)!
    ```

    1. Schema Registry service - stores schemas in internal Kafka topic `_schemas`
    2. Default Schema Registry REST API port
    3. Hostname for Schema Registry service discovery
    4. Connect to Kafka cluster to store schemas
    5. REST API endpoint for schema operations

    ```bash
    docker-compose up -d schema-registry
    ```

=== ":simple-linux: Manual Installation"

    ```bash
    # Download Confluent Platform
    wget https://packages.confluent.io/archive/7.5/confluent-7.5.0.tar.gz  # (1)!
    tar -xzf confluent-7.5.0.tar.gz
    cd confluent-7.5.0

    # Configure Schema Registry
    cat <<EOF > etc/schema-registry/schema-registry.properties
    listeners=http://0.0.0.0:8081  # (2)!
    kafkastore.bootstrap.servers=localhost:9092  # (3)!
    kafkastore.topic=_schemas  # (4)!
    debug=false
    EOF

    # Start Schema Registry
    bin/schema-registry-start etc/schema-registry/schema-registry.properties
    ```

    1. Download Confluent Platform which includes Schema Registry
    2. REST API endpoint - accessible at `http://localhost:8081`
    3. Kafka cluster connection for storing schemas
    4. Internal topic for schema storage (created automatically)

### Verify Installation

```bash
# Check Schema Registry health
curl http://localhost:8081/  # (1)!

# List subjects (should be empty initially)
curl http://localhost:8081/subjects  # (2)!
```

1. Should return `{}` if Schema Registry is running
2. Returns list of registered schema subjects (topics + key/value suffix)

!!! success "Schema Registry is Ready"
If both commands succeed, Schema Registry is running and ready to manage schemas.

---

## Step 2: Choose a Serialization Format

Schema Registry supports three serialization formats. Choose based on your use case:

<div class="grid cards" markdown>

- **:simple-apache: Avro**

  ***

  **Best For:** General-purpose data serialization

  **Pros:**
  - Compact binary format
  - Rich data types (unions, maps, arrays)
  - Mature ecosystem

  **Cons:**
  - Requires code generation (optional)
  - Less human-readable

- **:material-buffer: Protobuf**

  ***

  **Best For:** High-performance microservices

  **Pros:**
  - Fastest serialization/deserialization
  - Backward and forward compatible by design
  - Strong typing with code generation

  **Cons:**
  - Requires `.proto` files
  - Limited dynamic schema support

- **:simple-json: JSON Schema**

  ***

  **Best For:** Human-readable data, APIs

  **Pros:**
  - Human-readable format
  - No code generation required
  - Easy debugging

  **Cons:**
  - Larger message size
  - Slower parsing
  - Less compact than Avro/Protobuf

</div>

!!! tip "Most Common Choice"
**Avro** is the most popular format for Kafka because it balances compactness, flexibility, and schema evolution. This guide focuses on Avro, with examples for Protobuf and JSON Schema.

---

## Step 3: Register a Schema

### Define an Avro Schema

Create a schema for an `Order` event:

```json title="order-schema.avsc"
{
  "type": "record",
  "name": "Order",
  "namespace": "com.example.orders",
  "fields": [
    { "name": "order_id", "type": "string" }, // (1)!
    { "name": "customer_id", "type": "string" },
    { "name": "amount", "type": "double" },
    { "name": "timestamp", "type": "long" } // (2)!
  ]
}
```

1. Unique order identifier - required field
2. Unix timestamp in milliseconds - required field

### Register the Schema

=== ":simple-curl: REST API"

    ```bash
    curl -X POST http://localhost:8081/subjects/orders-value/versions \  # (1)!
      -H "Content-Type: application/vnd.schemaregistry.v1+json" \  # (2)!
      -d '{
        "schema": "{\"type\":\"record\",\"name\":\"Order\",\"namespace\":\"com.example.orders\",\"fields\":[{\"name\":\"order_id\",\"type\":\"string\"},{\"name\":\"customer_id\",\"type\":\"string\"},{\"name\":\"amount\",\"type\":\"double\"},{\"name\":\"timestamp\",\"type\":\"long\"}]}"  # (3)!
      }'
    ```

    1. Subject name: `<topic>-<key|value>` - here `orders-value` for message values
    2. Required content type for Schema Registry API
    3. Schema definition as JSON-encoded string (note escaped quotes)

    **Response:**
    ```json
    {"id": 1}  // (1)!
    ```

    1. Schema ID - used to reference this schema in messages

=== ":simple-python: Python"

    ```python
    from confluent_kafka.schema_registry import SchemaRegistryClient
    from confluent_kafka.schema_registry.avro import AvroSerializer

    # Configure Schema Registry client
    sr_client = SchemaRegistryClient({
        'url': 'http://localhost:8081'  # (1)!
    })

    # Define Avro schema
    avro_schema = """
    {
      "type": "record",
      "name": "Order",
      "namespace": "com.example.orders",
      "fields": [
        {"name": "order_id", "type": "string"},
        {"name": "customer_id", "type": "string"},
        {"name": "amount", "type": "double"},
        {"name": "timestamp", "type": "long"}
      ]
    }
    """

    # Register schema
    schema_id = sr_client.register_schema(  # (2)!
        subject_name='orders-value',
        schema=Schema(avro_schema, schema_type='AVRO')
    )

    print(f"Schema registered with ID: {schema_id}")
    ```

    1. Schema Registry endpoint - adjust for your deployment
    2. Returns schema ID which is cached for future lookups

### Verify Registration

```bash
# List all subjects
curl http://localhost:8081/subjects

# Get latest schema for subject
curl http://localhost:8081/subjects/orders-value/versions/latest  # (1)!

# Get schema by ID
curl http://localhost:8081/schemas/ids/1  # (2)!
```

1. Returns latest version of schema for `orders-value` subject
2. Returns schema definition for schema ID 1

---

## Step 4: Produce Messages with Schema

### Using Avro Serializer

=== ":simple-python: Python"

    ```python title="producer_with_schema.py" linenums="1" hl_lines="12-15 22-27"
    from confluent_kafka import SerializingProducer
    from confluent_kafka.schema_registry import SchemaRegistryClient
    from confluent_kafka.schema_registry.avro import AvroSerializer
    import time

    # Schema Registry client
    sr_client = SchemaRegistryClient({'url': 'http://localhost:8081'})

    # Avro schema (same as registered)
    avro_schema_str = """..."""  # (1)!

    # Create Avro serializer
    avro_serializer = AvroSerializer(  # (2)!
        schema_registry_client=sr_client,
        schema_str=avro_schema_str
    )

    # Configure producer with Avro serializer
    producer = SerializingProducer({
        'bootstrap.servers': 'localhost:9092',
        'key.serializer': StringSerializer('utf_8'),
        'value.serializer': avro_serializer  # (3)!
    })

    # Create order message (Python dict)
    order = {  # (4)!
        'order_id': 'ORD-12345',
        'customer_id': 'CUST-67890',
        'amount': 99.99,
        'timestamp': int(time.time() * 1000)
    }

    # Send message (schema validation happens automatically)
    producer.produce(  # (5)!
        topic='orders',
        key='ORD-12345',
        value=order,  # (6)!
        on_delivery=lambda err, msg: print(f"Delivered: {msg.topic()}[{msg.partition()}]")
    )

    producer.flush()
    ```

    1. Full Avro schema definition (same as registered in Schema Registry)
    2. Avro serializer - automatically looks up schema ID from Schema Registry
    3. Assign Avro serializer to value serializer (key can use String)
    4. Python dictionary matching Avro schema structure
    5. Producer automatically serializes value using Avro schema
    6. Message sent as: `[magic_byte][schema_id][avro_binary_data]`

=== ":simple-openjdk: Java"

    ```java title="OrderProducer.java" linenums="1"
    import io.confluent.kafka.serializers.KafkaAvroSerializer;
    import org.apache.kafka.clients.producer.*;
    import org.apache.avro.generic.GenericRecord;
    import org.apache.avro.generic.GenericData;

    Properties props = new Properties();
    props.put("bootstrap.servers", "localhost:9092");
    props.put("key.serializer", StringSerializer.class);
    props.put("value.serializer", KafkaAvroSerializer.class);  // (1)!
    props.put("schema.registry.url", "http://localhost:8081");  // (2)!

    KafkaProducer<String, GenericRecord> producer = new KafkaProducer<>(props);

    // Create Avro GenericRecord
    GenericRecord order = new GenericData.Record(schema);  // (3)!
    order.put("order_id", "ORD-12345");
    order.put("customer_id", "CUST-67890");
    order.put("amount", 99.99);
    order.put("timestamp", System.currentTimeMillis());

    // Send message
    producer.send(new ProducerRecord<>("orders", "ORD-12345", order));  // (4)!
    producer.close();
    ```

    1. Confluent's Kafka Avro Serializer - handles schema registry integration
    2. Schema Registry URL for schema lookup and registration
    3. GenericRecord represents Avro data without code generation
    4. Serializer automatically fetches schema ID and serializes to binary

!!! warning "Schema Validation at Produce Time"
If the message doesn't match the schema, the producer will throw a **SerializationException** before sending to Kafka. This prevents invalid data from entering the pipeline.

---

## Step 5: Consume Messages with Schema

=== ":simple-python: Python"

    ```python title="consumer_with_schema.py" linenums="1" hl_lines="9-12 19-20"
    from confluent_kafka import DeserializingConsumer
    from confluent_kafka.schema_registry import SchemaRegistryClient
    from confluent_kafka.schema_registry.avro import AvroDeserializer

    # Schema Registry client
    sr_client = SchemaRegistryClient({'url': 'http://localhost:8081'})

    # Avro deserializer (schema fetched automatically by ID)
    avro_deserializer = AvroDeserializer(  # (1)!
        schema_registry_client=sr_client,
        schema_str=avro_schema_str  # (2)!
    )

    # Configure consumer
    consumer = DeserializingConsumer({
        'bootstrap.servers': 'localhost:9092',
        'group.id': 'order-processor',
        'auto.offset.reset': 'earliest',
        'key.deserializer': StringDeserializer('utf_8'),
        'value.deserializer': avro_deserializer  # (3)!
    })

    consumer.subscribe(['orders'])

    while True:
        msg = consumer.poll(1.0)
        if msg is None:
            continue

        # Value is automatically deserialized to Python dict
        order = msg.value()  # (4)!
        print(f"Order: {order['order_id']}, Amount: ${order['amount']}")
    ```

    1. Avro deserializer - reads schema ID from message and fetches schema
    2. Optional: provide schema for validation (deserializer can fetch from registry)
    3. Assign Avro deserializer to value deserializer
    4. Message automatically deserialized to Python dictionary

=== ":simple-openjdk: Java"

    ```java title="OrderConsumer.java"
    import io.confluent.kafka.serializers.KafkaAvroDeserializer;
    import org.apache.kafka.clients.consumer.*;
    import org.apache.avro.generic.GenericRecord;

    Properties props = new Properties();
    props.put("bootstrap.servers", "localhost:9092");
    props.put("group.id", "order-processor");
    props.put("key.deserializer", StringDeserializer.class);
    props.put("value.deserializer", KafkaAvroDeserializer.class);  // (1)!
    props.put("schema.registry.url", "http://localhost:8081");

    KafkaConsumer<String, GenericRecord> consumer = new KafkaConsumer<>(props);
    consumer.subscribe(Collections.singletonList("orders"));

    while (true) {
        ConsumerRecords<String, GenericRecord> records = consumer.poll(Duration.ofMillis(1000));
        for (ConsumerRecord<String, GenericRecord> record : records) {
            GenericRecord order = record.value();  // (2)!
            System.out.println("Order: " + order.get("order_id"));
        }
    }
    ```

    1. Kafka Avro Deserializer - automatically fetches schema from registry
    2. Value automatically deserialized to Avro GenericRecord

---

## Step 6: Schema Evolution

### Compatibility Modes

Schema Registry supports four compatibility modes:

| Mode         | Description                          | Allowed Changes                    |
| ------------ | ------------------------------------ | ---------------------------------- |
| **BACKWARD** | New schema can read old data         | Delete fields, add optional fields |
| **FORWARD**  | Old schema can read new data         | Add fields, delete optional fields |
| **FULL**     | Both backward and forward compatible | Add/delete optional fields only    |
| **NONE**     | No compatibility checks              | Any change allowed (⚠️ dangerous)  |

!!! tip "Default Compatibility Mode"
Schema Registry uses **BACKWARD** compatibility by default, which is the most common choice. Consumers can upgrade independently without breaking.

### Configure Compatibility Mode

```bash
# Set compatibility mode for subject
curl -X PUT http://localhost:8081/config/orders-value \  # (1)!
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d '{"compatibility": "BACKWARD"}'  # (2)!

# Set global default compatibility
curl -X PUT http://localhost:8081/config \  # (3)!
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d '{"compatibility": "FULL"}'
```

1. Set compatibility mode for specific subject
2. Compatibility mode: BACKWARD, FORWARD, FULL, or NONE
3. Set default compatibility mode for all new subjects

### Evolve the Schema (Add Optional Field)

Let's add a `status` field to the `Order` schema:

```json title="order-schema-v2.avsc" hl_lines="9"
{
  "type": "record",
  "name": "Order",
  "namespace": "com.example.orders",
  "fields": [
    { "name": "order_id", "type": "string" },
    { "name": "customer_id", "type": "string" },
    { "name": "amount", "type": "double" },
    { "name": "timestamp", "type": "long" },
    { "name": "status", "type": "string", "default": "PENDING" } // (1)!
  ]
}
```

1. New optional field with default value - backward compatible

```bash
# Register new version
curl -X POST http://localhost:8081/subjects/orders-value/versions \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d '{"schema": "{...}"}'  # (1)!

# Response: {"id": 2}  # (2)!
```

1. New schema with added `status` field
2. New schema ID assigned - old consumers can still read new messages

!!! success "Schema Evolution in Action" - **Old consumers** (using schema v1) can read new messages - they ignore the `status` field - **New producers** (using schema v2) can write with `status` field - **No downtime required** - gradual migration possible

### Breaking Changes (Incompatible)

```json title="order-schema-v3-INVALID.avsc" hl_lines="6"
{
  "type": "record",
  "name": "Order",
  "namespace": "com.example.orders",
  "fields": [
    { "name": "order_id", "type": "int" }, // (1)!
    { "name": "customer_id", "type": "string" },
    { "name": "amount", "type": "double" }
  ]
}
```

1. Changed `order_id` type from `string` to `int` - **BREAKING CHANGE**

```bash
# Try to register incompatible schema
curl -X POST http://localhost:8081/subjects/orders-value/versions \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d '{"schema": "{...}"}'

# Response: HTTP 409 Conflict  # (1)!
# {
#   "error_code": 409,
#   "message": "Schema being registered is incompatible with an earlier schema"
# }
```

1. Schema Registry **rejects** incompatible schemas - prevents breaking consumers

---

## Step 7: Using Protobuf and JSON Schema

### Protobuf Example

=== "Define Schema (.proto)"

    ```protobuf title="order.proto"
    syntax = "proto3";

    package com.example.orders;

    message Order {
      string order_id = 1;     // (1)!
      string customer_id = 2;
      double amount = 3;
      int64 timestamp = 4;
    }
    ```

    1. Field numbers must never change - used for backward compatibility

=== "Register Schema"

    ```bash
    curl -X POST http://localhost:8081/subjects/orders-proto-value/versions \
      -H "Content-Type: application/vnd.schemaregistry.v1+json" \
      -d '{
        "schemaType": "PROTOBUF",  # (1)!
        "schema": "syntax = \"proto3\"; package com.example.orders; message Order { string order_id = 1; string customer_id = 2; double amount = 3; int64 timestamp = 4; }"
      }'
    ```

    1. Specify `PROTOBUF` schema type (default is AVRO)

=== "Producer (Python)"

    ```python
    from confluent_kafka.schema_registry.protobuf import ProtobufSerializer

    protobuf_serializer = ProtobufSerializer(  # (1)!
        msg_type=Order,  # (2)!
        schema_registry_client=sr_client
    )

    producer = SerializingProducer({
        'bootstrap.servers': 'localhost:9092',
        'value.serializer': protobuf_serializer
    })
    ```

    1. Protobuf serializer - similar to Avro serializer
    2. Generated Protobuf class from `.proto` file

### JSON Schema Example

=== "Define Schema"

    ```json title="order-json-schema.json"
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "type": "object",
      "properties": {
        "order_id": {"type": "string"},  // (1)!
        "customer_id": {"type": "string"},
        "amount": {"type": "number"},
        "timestamp": {"type": "integer"}
      },
      "required": ["order_id", "customer_id", "amount", "timestamp"]  // (2)!
    }
    ```

    1. JSON Schema type definitions - standard JSON Schema format
    2. Required fields - enforced at serialization time

=== "Producer (Python)"

    ```python
    from confluent_kafka.schema_registry.json_schema import JSONSerializer

    json_serializer = JSONSerializer(
        schema_str=json_schema_str,
        schema_registry_client=sr_client
    )

    producer = SerializingProducer({
        'bootstrap.servers': 'localhost:9092',
        'value.serializer': json_serializer  # (1)!
    })

    # Send JSON message
    order = {  # (2)!
        'order_id': 'ORD-12345',
        'customer_id': 'CUST-67890',
        'amount': 99.99,
        'timestamp': 1702834567000
    }

    producer.produce('orders', value=order)
    ```

    1. JSON Schema serializer - validates against JSON Schema
    2. Plain Python dictionary - serialized to JSON with schema validation

---

## Best Practices

<div class="grid cards" markdown>

- **:material-check-circle: DO**

  ***
  - Use **BACKWARD** or **FULL** compatibility for production
  - Add default values to new fields for backward compatibility
  - Test schema evolution in staging before production
  - Version schemas semantically (v1, v2, etc.)
  - Use Avro for general-purpose data serialization

- **:material-close-circle: DON'T**

  ***
  - Change field types without creating a new topic
  - Use `NONE` compatibility mode in production
  - Remove required fields without migration plan
  - Deploy breaking schema changes without coordination
  - Hardcode schema IDs in application code

</div>

### Production Checklist

- [x] Schema Registry deployed with HA (multiple replicas)
- [x] Compatibility mode configured (`BACKWARD` or `FULL`)
- [x] Schema validation enabled in producers
- [x] Monitoring for schema registry availability
- [x] Schema versioning strategy documented
- [x] Rollback plan for schema changes
- [x] Security: SSL + authentication enabled (see [Schema Registry Security](https://docs.confluent.io/platform/current/schema-registry/security/index.html))

---

## Troubleshooting

??? bug "Error: `Schema being registered is incompatible`"
**Cause:** New schema violates compatibility rules

    **Solution:**
    1. Check compatibility mode: `curl http://localhost:8081/config/orders-value`
    2. Review schema changes - ensure backward compatibility
    3. Add default values to new fields
    4. If breaking change is required:
        - Create a new topic with new schema
        - Migrate consumers gradually
        - Use Kafka Streams for data transformation

??? bug "Error: `Subject not found`"
**Cause:** Schema not registered for topic

    **Solution:**
    ```bash
    # List all subjects
    curl http://localhost:8081/subjects

    # Check if subject exists
    curl http://localhost:8081/subjects/orders-value/versions
    ```

    Register schema manually using REST API or producer with `auto.register.schemas=true`

??? bug "Error: `Failed to deserialize Avro message`"
**Cause:** Message written without schema or corrupted

    **Solution:**
    1. Verify schema ID in message header: first 5 bytes should be `[0x00][schema_id]`
    2. Check Schema Registry availability
    3. Ensure producer used Avro serializer correctly
    4. Check for schema ID mismatch (old cached schema)

---

## Complete Example: Order Service with Schema Evolution

```python title="order_service_with_schema.py" linenums="1"
from confluent_kafka import SerializingProducer, DeserializingConsumer
from confluent_kafka.schema_registry import SchemaRegistryClient, Schema
from confluent_kafka.schema_registry.avro import AvroSerializer, AvroDeserializer
from confluent_kafka.serialization import StringSerializer, StringDeserializer
import time

# Schema Registry client
sr_config = {'url': 'http://localhost:8081'}
sr_client = SchemaRegistryClient(sr_config)

# Define Avro schema (v2 with status field)
order_schema_str = """
{
  "type": "record",
  "name": "Order",
  "namespace": "com.example.orders",
  "fields": [
    {"name": "order_id", "type": "string"},
    {"name": "customer_id", "type": "string"},
    {"name": "amount", "type": "double"},
    {"name": "timestamp", "type": "long"},
    {"name": "status", "type": "string", "default": "PENDING"}
  ]
}
"""

# Producer configuration with Avro serializer
avro_serializer = AvroSerializer(sr_client, order_schema_str)

producer_config = {
    'bootstrap.servers': 'localhost:9092',
    'key.serializer': StringSerializer('utf_8'),
    'value.serializer': avro_serializer
}

producer = SerializingProducer(producer_config)

# Produce order with schema
order = {
    'order_id': 'ORD-99999',
    'customer_id': 'CUST-11111',
    'amount': 199.99,
    'timestamp': int(time.time() * 1000),
    'status': 'CONFIRMED'  # New field in v2
}

producer.produce(
    topic='orders',
    key=order['order_id'],
    value=order,
    on_delivery=lambda err, msg: print(f"Order delivered: {msg.key()}")
)

producer.flush()
print(f"Order {order['order_id']} sent with schema validation")

# Consumer configuration with Avro deserializer
avro_deserializer = AvroDeserializer(sr_client, order_schema_str)

consumer_config = {
    'bootstrap.servers': 'localhost:9092',
    'group.id': 'order-processor-v2',
    'auto.offset.reset': 'earliest',
    'key.deserializer': StringDeserializer('utf_8'),
    'value.deserializer': avro_deserializer
}

consumer = DeserializingConsumer(consumer_config)
consumer.subscribe(['orders'])

# Process orders (handles both v1 and v2 schemas)
print("Processing orders...")
try:
    while True:
        msg = consumer.poll(1.0)
        if msg is None:
            continue

        order = msg.value()
        status = order.get('status', 'UNKNOWN')  # Handle v1 (no status field)

        print(f"Order {order['order_id']}: ${order['amount']:.2f} - Status: {status}")

except KeyboardInterrupt:
    pass
finally:
    consumer.close()
```

---

## What's Next?

Now that you understand schema management, explore:

- **[Stream Processing](kafka-stream-processing.md)** - Transform data with Kafka Streams and Flink
- **[Kafka Connect](kafka-connect-systems.md)** - Use Schema Registry with source/sink connectors
- **[Produce Messages](kafka-produce-messages.md)** - Optimize producer configuration

---

## Additional Resources

### Official Documentation

- [Confluent Schema Registry Documentation](https://docs.confluent.io/platform/current/schema-registry/index.html)
- [Schema Registry REST API Reference](https://docs.confluent.io/platform/current/schema-registry/develop/api.html)
- [Schema Registry Configuration Options](https://docs.confluent.io/platform/current/schema-registry/installation/config.html)

### Schema Formats

- [Apache Avro Specification](https://avro.apache.org/docs/current/spec.html)
- [Protocol Buffers Documentation](https://protobuf.dev/)
- [JSON Schema Specification](https://json-schema.org/)

### Tutorials & Best Practices

- [Schema Registry Tutorial](https://developer.confluent.io/learn-kafka/schema-registry/get-started/) - Free Confluent course
- [Schema Evolution Best Practices](https://docs.confluent.io/platform/current/schema-registry/avro.html#schema-evolution)
- [Serialization and Schema Registry Guide](https://www.confluent.io/blog/kafka-schemas-serialization-evolution/)
- [Schema Validation Patterns](https://www.confluent.io/blog/schema-registry-kafka-stream-processing-yes-virginia-you-really-need-one/)

### Advanced Topics

- [Schema Registry Security](https://docs.confluent.io/platform/current/schema-registry/security/index.html)
- [Multi-Datacenter Schema Registry](https://docs.confluent.io/platform/current/schema-registry/multidc.html)
- [Schema Linking and Migration](https://docs.confluent.io/cloud/current/sr/schema-linking.html)

---

!!! info "Course Attribution"
This guide is based on content from Confluent Schema Registry documentation, Apache Avro specification, and industry best practices.
