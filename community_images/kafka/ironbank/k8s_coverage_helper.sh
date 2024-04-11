#!/bin/bash

set -x
set -e

cd /opt/bitnami/kafka/

# # Quickstart coverage
# # CREATE A TOPIC TO STORE YOUR EVENTS
# bin/kafka-topics.sh --create --topic quickstart-events-rf --bootstrap-server localhost:9092

# # Function to start the producer and produce two messages
# start_producer() {
#     echo "Starting producer..."
#     # Start the console producer in the background
#     bin/kafka-console-producer.sh --topic quickstart-events-rf --bootstrap-server localhost:9092 << EOF
# This is my first event
# This is my second event
# EOF
# }

# # Function to start the consumer and consume two messages
# start_consumer() {
#     echo "Starting consumer..."
#     # Start the console consumer
#     timeout 5 bin/kafka-console-consumer.sh --topic quickstart-events-rf --from-beginning --bootstrap-server localhost:9092 > output.txt || true

#     # Wait for consumer to consume two messages
#     sleep 2

#     # Verify consumer output
#     if [ "$(cat output.txt)" != "This is my first event
# This is my second event" ]; then
#         echo "Error: Consumer output does not match producer input."
#         exit 1
#     else
#         echo "Consumer received the expected messages."
#     fi

# }

# # Start the producer and produce messages
# start_producer

# # Start the consumer and consume messages
# start_consumer

# rm output.txt


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

    # Sleep for a moment to allow topics to be created
    sleep 5

    # Start the Wordcount Application
    bin/kafka-run-class.sh org.apache.kafka.streams.examples.wordcount.WordCountDemo &
    wordcount_pid=$!  # Capture the PID of the Wordcount application

    # Sleep for a moment to allow Wordcount application to start
    sleep 15

    # Produce some data
    echo -e "all streams lead to kafka hello kafka streams join kafka summit" | \
        bin/kafka-console-producer.sh --broker-list localhost:9092 --topic streams-plaintext-input &

    producer_pid=$!  # Capture the PID of the producer

    # Sleep for a moment to allow messages to be processed
    sleep 5

    # Consume processed data
    timeout 5 bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 \
        --topic streams-wordcount-output \
        --from-beginning \
        --formatter kafka.tools.DefaultMessageFormatter \
        --property print.key=true \
        --property print.value=true \
        --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer \
        --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer > output.txt || true

    # Sleep for a moment to allow consumer to fetch data
    sleep 10

    # Clean up
    kill $wordcount_pid  # Stop the Wordcount application
    kill $producer_pid  # Stop the producer process
}

run_kafka_streams_demo

echo "Damn, all is perfect!"