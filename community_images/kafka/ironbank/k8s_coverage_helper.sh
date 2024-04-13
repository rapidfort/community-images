#!/bin/bash

set -x
set -e

cd /opt/bitnami/kafka/

# Quickstart coverage
# CREATE A TOPIC TO STORE YOUR EVENTS
bin/kafka-topics.sh --create --topic quickstart-events-rf --bootstrap-server localhost:9092
# Quickstart coverage
# CREATE A TOPIC TO STORE YOUR EVENTS
bin/kafka-topics.sh --create --topic quickstart-events-rf --bootstrap-server localhost:9092

# Function to start the producer and produce two messages
start_producer() {
    echo "Starting producer..."
    # Start the console producer in the background
    bin/kafka-console-producer.sh --topic quickstart-events-rf --bootstrap-server localhost:9092 << EOF
This is my first event
This is my second event
EOF
}
# Function to start the producer and produce two messages
start_producer() {
    echo "Starting producer..."
    # Start the console producer in the background
    bin/kafka-console-producer.sh --topic quickstart-events-rf --bootstrap-server localhost:9092 << EOF
This is my first event
This is my second event
EOF
}

# Function to start the consumer and consume two messages
start_consumer() {
    echo "Starting consumer..."
    # Start the console consumer
    timeout 5 bin/kafka-console-consumer.sh --topic quickstart-events-rf --from-beginning --bootstrap-server localhost:9092 > output.txt || true
# Function to start the consumer and consume two messages
start_consumer() {
    echo "Starting consumer..."
    # Start the console consumer
    timeout 5 bin/kafka-console-consumer.sh --topic quickstart-events-rf --from-beginning --bootstrap-server localhost:9092 > output.txt || true

    # Wait for consumer to consume two messages
    sleep 2
    # Wait for consumer to consume two messages
    sleep 2

    # Verify consumer output
    if [ "$(cat output.txt)" != "This is my first event
This is my second event" ]; then
        echo "Error: Consumer output does not match producer input."
        exit 1
    else
        echo "Consumer received the expected messages."
    fi
    # Verify consumer output
    if [ "$(cat output.txt)" != "This is my first event
This is my second event" ]; then
        echo "Error: Consumer output does not match producer input."
        exit 1
    else
        echo "Consumer received the expected messages."
    fi

}
}

# Start the producer and produce messages
start_producer
# Start the producer and produce messages
start_producer

# Start the consumer and consume messages
start_consumer
# Start the consumer and consume messages
start_consumer

rm output.txt
rm output.txt


# PROCESS YOUR EVENTS WITH KAFKA STREAMS
function run_kafka_streams_demo() {
    # Create input and output topics
    bin/kafka-topics.sh --create \
        --bootstrap-server localhost:9092 \
        --replication-factor 1 \
        --partitions 1 \
        --topic streams-plaintext-input

    bin/kafka-topics.sh --create \
        --bootstrap-server localhost:9092 \
        --replication-factor 1 \
        --partitions 1 \
        --topic streams-wordcount-output \
        --config cleanup.policy=compact

    # Start the Wordcount Application
    timeout 40 bin/kafka-run-class.sh org.apache.kafka.streams.examples.wordcount.WordCountDemo || true &
    timeout 40 bin/kafka-run-class.sh org.apache.kafka.streams.examples.wordcount.WordCountDemo || true &

    # Sleep for a moment to allow Wordcount application to start
    sleep 10
    sleep 10

    # Produce some data
    timeout 10 echo -e "all streams lead to kafka hello kafka streams join kafka summit" | \
        bin/kafka-console-producer.sh --broker-list localhost:9092 --topic streams-plaintext-input || true
    timeout 10 echo -e "all streams lead to kafka hello kafka streams join kafka summit" | \
        bin/kafka-console-producer.sh --broker-list localhost:9092 --topic streams-plaintext-input || true

    # Consume processed data
    timeout 10 bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 \
    timeout 10 bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 \
        --topic streams-wordcount-output \
        --from-beginning \
        --formatter kafka.tools.DefaultMessageFormatter \
        --property print.key=true \
        --property print.value=true \
        --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer \
        --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer > output.txt || true

    # Verify Stream output
        if [ "$(cat output.txt)" != "all     1
streams 1
lead    1
to      1
kafka   1
hello   1
kafka   2
streams 2
join    1
kafka   3
summit  1" ]; then
            echo "Error: WordCount Stream output does not match expected results."
            exit 1
        else
            echo "Stream Output received the expected messages."
        fi
    # Verify Stream output
        if [ "$(cat output.txt)" != "all     1
streams 1
lead    1
to      1
kafka   1
hello   1
kafka   2
streams 2
join    1
kafka   3
summit  1" ]; then
            echo "Error: WordCount Stream output does not match expected results."
            exit 1
        else
            echo "Stream Output received the expected messages."
        fi
}

run_kafka_streams_demo
rm output.txt


# Coverage for and related to bin/kafka-topics.sh module
# Creating Topic with Config
bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic my-topic --partitions 1 \
  --replication-factor 1 --config max.message.bytes=64000 --config flush.messages=1

# Updating Config
bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name my-topic \
  --alter --add-config max.message.bytes=128000

# checking the configs
bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name my-topic --describe

# removing the config
bin/kafka-configs.sh --bootstrap-server localhost:9092  --entity-type topics --entity-name my-topic \
  --alter --delete-config max.message.bytes

# Modifying the topics
bin/kafka-topics.sh --bootstrap-server localhost:9092 --alter --topic my-topic --partitions 2


# Manually restoring leadership to restored replicas
bin/kafka-leader-election.sh --bootstrap-server localhost:9092 --election-type preferred --all-topic-partitions

# Listing all consumer groups across all topics
bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

# Coverage for consumer group created by quickstart coverage of wordcount stream
bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group streams-wordcount
bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group streams-wordcount --members
bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --delete --group streams-wordcount


# Expanding your cluster (we create 2 new topics in broker 0and move them entirely to broker 1 and 2)
expand_kafka_cluster() {

    # Create topic foo
    bin/kafka-topics.sh --create \
        --bootstrap-server localhost:9092 \
        --replication-factor 2 \
        --partitions 6 \
        --topic foo

    # Create topic bar
    bin/kafka-topics.sh --create \
        --bootstrap-server localhost:9092 \
        --replication-factor 2 \
        --partitions 6 \
        --topic bar

    # Generate JSON file for topics to move
    cat <<EOF > topics-to-move.json
{
  "topics": [
    {"topic": "foo"},
    {"topic": "bar"}
  ],
  "version": 1
}
EOF

    # Generate candidate reassignment plan
    bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 --topics-to-move-json-file topics-to-move.json --broker-list "1,2" --generate > candidate-reassignment.json

    # Parse the reassignment plan into expand-cluster-reassignment.json 
    proposed_config=$(grep -A1 'Proposed partition reassignment configuration' candidate-reassignment.json | tail -n 1)
    echo "$proposed_config" > expand-cluster-reassignment.json

    # Execute partition reassignment (setting throttle to 500 B/s)
    bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 --reassignment-json-file expand-cluster-reassignment.json --execute --throttle 500

    # increasing the throttle value (setting to 70 MB/s)
    bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 --reassignment-json-file expand-cluster-reassignment.json --additional --execute --throttle 700000000

    # Give some time to reassignments to occur
    sleep 5

    # Verify partition reassignment status
    bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 --reassignment-json-file expand-cluster-reassignment.json --verify
    # Can verify the output of status

    # cleaning up
    rm -f topics-to-move.json candidate-reassignment.json expand-cluster-reassignment.json 
}

expand_kafka_cluster


# Viewing throttle limit config
bin/kafka-configs.sh --describe --bootstrap-server localhost:9092 --entity-type brokers

# View list of throttled replicas
bin/kafka-configs.sh --describe --bootstrap-server localhost:9092 --entity-type topics

# Configure Default Quota for User
bin/kafka-configs.sh  --bootstrap-server localhost:9092 --alter --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' --entity-type users --entity-default

# Configure Default Quota for Client ID
bin/kafka-configs.sh  --bootstrap-server localhost:9092 --alter --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' --entity-type clients --entity-default

# Describing Quota for all users
bin/kafka-configs.sh  --bootstrap-server localhost:9092 --describe --entity-type users

# Describing Quota for every (user, client)
bin/kafka-configs.sh  --bootstrap-server localhost:9092 --describe --entity-type users --entity-type clients

bin/zookeeper-security-migration.sh --help

bin/connect-mirror-maker.sh --help

bin/kafka-acls.sh --help
