#!/bin/bash

# Create topics with different configurations
kafka-topics --create --zookeeper zk:2181 --replication-factor 3 --partitions 4 --topic replicated_topic
kafka-topics --create --zookeeper zk:2181 --config retention.ms=10000 --topic short-retention

# Produce messages with various properties
echo "Important message with key1" | kafka-console-producer --broker-list kafka:9092 --topic test --property key=key1
echo "Another message with timestamp" | kafka-console-producer --broker-list kafka:9092 --topic test --property timestamp=ms

# Consume messages from specific offsets and with different consumer groups
kafka-console-consumer --bootstrap-server kafka:9092 --topic test --from-offset 0 --group-id consumer_group_1
kafka-console-consumer --bootstrap-server kafka:9092 --topic test --offset 10 --group-id consumer_group_2

# Consumer group management (create, describe, delete)
kafka-consumer-groups --bootstrap-server kafka:9092 --group-id my-consumer-group --create
kafka-consumer-groups --bootstrap-server kafka-9092 --describe --group-id my-consumer-group
kafka-consumer-groups --bootstrap-server kafka:9092 --delete --group-id my-consumer-group

# SASL Authentication with different mechanisms (if configured)
# Assuming SASL PLAIN and SCRAM-SHA-256 are enabled
kafka-console-producer --broker-list kafka:9092 --topic test --security-protocol PLAIN --sasl-mechanisms PLAIN --sasl-username my_username --sasl-password my_password  -v
kafka-console-producer --broker-list kafka:9092 --topic test --security-protocol SASL_SSL --sasl-mechanisms SCRAM-SHA-256 --sasl-username my_username --sasl-password my_password  -v

# Monitor Kafka using JMX metrics (CPU, memory, etc.)
jmxterm -JmxServiceURL=service:jmx:rmi:///system:broker.9092/jmxrmi

# Admin commands (explore Kafka Tool documentation for more)
# https://docs.confluent.io/platform/current/kafka/tools/admintools.html
kafka-admin --bootstrap-server kafka:9092 --alter-config --entity-type topics --config retention.ms=60000 --topics short-retention  # Modify topic config
kafka-admin --bootstrap-server kafka:9092 --delete-topics deleted_topic  # Delete topic (uncomment)
kafka-admin --bootstrap-server kafka:9092 --list-brokers  # List brokers
kafka-admin --bootstrap-server kafka:9092 --describe-cluster  # Get cluster information
kafka-admin --bootstrap-server kafka:9092 --create-topics --topic auto_create_topic --partitions 2 --replication-factor 1 --configfile /path/to/custom.config  # Create topic with custom config file (replace path)

# Offset manipulation (commit offsets for different consumer groups)
kafka-consumer-groups --bootstrap-server kafka:9092 --group-id consumer_group_1 --offset --topic test --offsets beginning
kafka-consumer-groups --bootstrap-server kafka:9092 --group-id consumer_group_2 --offset --topic test --offsets current

# Advanced message production (batching, compression)
kafka-console-producer --broker-list kafka:9092 --topic test --batch-size 100
kafka-console-producer --broker-list kafka:9092 --topic test --producer-config compression.type=snappy

# Consume messages with different consumer configs
kafka-console-consumer --bootstrap-server kafka:9092 --topic test --enable-auto-commit --auto-commit-interval-ms 5000
kafka-console-consumer --bootstrap-server kafka:9092 --topic test --seek-to-beginning --consumer-config max.poll.records=1

# Consumer group coordination (offsets with different strategies)
kafka-consumer-groups --bootstrap-server kafka:9092 --group-id consumer_group_1 --offset --topic test --offsets earliest
kafka-consumer-groups --bootstrap-server kafka:9092 --group-id consumer_
