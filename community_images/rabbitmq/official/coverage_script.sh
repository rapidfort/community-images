#!/bin/bash

echo "pip install pika
python3 /tmp/commands.py --rabbitmq-server=user --password=password" > /tmp/exec_commands.sh

chmod +x /tmp/exec_commands.sh

./../../tmp/exec_commands.sh