#!/usr/bin/env python3
import pika

DEFAULT_RABBITMQ_USER='user'
DEFAULT_RABBITMQ_PASSWORD='bitnami'
DEFAULT_TOPIC_NAME='test'

params = pika.URLParameters(f'amqp://{DEFAULT_RABBITMQ_USER}:{DEFAULT_RABBITMQ_PASSWORD}@localhost')
connection = pika.BlockingConnection(params)
channel = connection.channel()

channel.queue_declare(queue=DEFAULT_TOPIC_NAME)

message='This is a test message!'
channel.basic_publish(exchange='', routing_key=DEFAULT_TOPIC_NAME, body=message)
print(f" [x] Sent '{message}'")
connection.close()