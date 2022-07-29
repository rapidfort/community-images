#!/usr/bin/env python
import pika, os
import sys, getopt

DEFAULT_RABBITMQ_USER='user'
DEFAULT_RABBITMQ_PASSWORD='bitnami'
DEFAULT_TOPIC_NAME='test'

server='localhost'
password=DEFAULT_RABBITMQ_PASSWORD
print(sys.argv)
try:
    opts, args = getopt.getopt(sys.argv[1:],"s:",["rabbitmq-server="])
except getopt.GetoptError:
    print('python3 consume.py --rabbitmq-server <server>')
    sys.exit(2)
for opt, arg in opts:
    if opt in ("--rabbitmq-server", "--s"):
        server = arg
    elif opt in ("--password", "--p"):
        password = arg

def main():
    params = pika.URLParameters(f'amqp://{DEFAULT_RABBITMQ_USER}:{DEFAULT_RABBITMQ_PASSWORD}@{server}')
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