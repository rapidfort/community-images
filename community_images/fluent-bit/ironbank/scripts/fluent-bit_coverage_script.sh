#!/bin/bash

set -e
set -x

# Start Fluent Bit with the specified configuration file
/fluent-bit/bin/fluent-bit -c /fluent-bit/etc/fluent-bit.conf &


# Capture the PID of the last background process
FLUENT_BIT_PID=$!

sleep 5

# Stop Fluent Bit gracefully by sending a termination signal
kill -TERM $FLUENT_BIT_PID

# Optionally, wait for Fluent Bit to exit
wait $FLUENT_BIT_PID