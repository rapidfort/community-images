#!/usr/bin/env python3
import pika
import sys, getopt

DEFAULT_RABBITMQ_USER='user'
DEFAULT_RABBITMQ_PASSWORD='bitnami'
DEFAULT_TOPIC_NAME='test'

server='localhost'
password=DEFAULT_RABBITMQ_PASSWORD
user=DEFAULT_RABBITMQ_USER
print(sys.argv)
try:
    opts, args = getopt.getopt(sys.argv[1:],"s:p:u:",["rabbitmq-server=", "password=", "user="])
except getopt.GetoptError:
    print('python3 publish.py --rabbitmq-server <server> --password <password> --user <user>')
    sys.exit(2)
for opt, arg in opts:
    if opt in ("--rabbitmq-server", "--s"):
        server = arg
    elif opt in ("--password", "--p"):
        password = arg
    elif opt in ("--user", "--u"):
        user = arg

params = pika.URLParameters(f'amqp://{user}:{password}@{server}')
connection = pika.BlockingConnection(params)
channel = connection.channel()

channel.queue_declare(queue=DEFAULT_TOPIC_NAME)

message='This is a test message!'
channel.basic_publish(exchange='', routing_key=DEFAULT_TOPIC_NAME, body=message)
print(f" [x] Sent '{message}'")
connection.close()