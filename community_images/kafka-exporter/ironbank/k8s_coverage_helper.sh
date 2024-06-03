#!/bin/bash

set -x
set -e

cd /opt/bitnami/kafka/

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

# Function to start the consumer and consume two messages
start_consumer() {
    echo "Starting consumer..."
    # Start the console consumer
    timeout 7 bin/kafka-console-consumer.sh --topic quickstart-events-rf --from-beginning --bootstrap-server localhost:9092 > output.txt || true

    # Wait for consumer to consume two messages
    sleep 7

    # Verify consumer output
    if [ "$(cat output.txt)" != "This is my first event
This is my second event" ]; then
        echo "Error: Consumer output does not match producer input."
        exit 1
    else
        echo "Consumer received the expected messages."
    fi

}

# Start the producer and produce messages
start_producer

# Start the consumer and consume messages
start_consumer

rm output.txt

exit 0