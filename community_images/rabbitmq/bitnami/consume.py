#!/usr/bin/env python
import pika, sys, os

DEFAULT_RABBITMQ_USER='user'
DEFAULT_RABBITMQ_PASSWORD='bitnami'
DEFAULT_TOPIC_NAME='test'

def main():
    params = pika.URLParameters(f'amqp://{DEFAULT_RABBITMQ_USER}:{DEFAULT_RABBITMQ_PASSWORD}@localhost')
    connection = pika.BlockingConnection(params)
    channel = connection.channel()
    channel.queue_declare(queue=DEFAULT_TOPIC_NAME)

    method_frame, header_frame, body = channel.basic_get(queue=DEFAULT_TOPIC_NAME)
    if method_frame is None or method_frame.NAME == 'Basic.GetEmpty':
        print(" [x] Error, empty response ")
        connection.close()
    else:
        channel.basic_ack(delivery_tag=method_frame.delivery_tag)
        print(" [x] Received %r" % body)
        connection.close()

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print('Interrupted')
        try:
            sys.exit(0)
        except SystemExit:
            os._exit(0)