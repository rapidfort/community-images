#!/bin/bash

set -e
set -x

# Start Fluent Bit with the specified configuration file
/opt/bitnami/fluent-bit/bin/fluent-bit -c /tmp/fluent-bit.conf &

# Add a delay to allow Fluent Bit to run (you can adjust this as needed)
# Capture the PID of the last background process
FLUENT_BIT_PID=$!

# Add a delay to allow Fluent Bit to run (you can adjust this as needed)
sleep 5

# Your additional commands or logic can go here

# Stop Fluent Bit gracefully by sending a termination signal
kill -TERM $FLUENT_BIT_PID

# Optionally, wait for Fluent Bit to exit
wait $FLUENT_BIT_PID