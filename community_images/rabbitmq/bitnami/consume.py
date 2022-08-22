"""The rabbitmq consumer."""
#!/usr/bin/env python
import getopt
import os
import sys

import pika  # pylint: disable=import-error

DEFAULT_RABBITMQ_USER = 'user'
DEFAULT_RABBITMQ_PASSWORD = 'bitnami'
DEFAULT_TOPIC_NAME = 'test'

server = 'localhost'  # pylint: disable=invalid-name
password = DEFAULT_RABBITMQ_PASSWORD  # pylint: disable=invalid-name
user = DEFAULT_RABBITMQ_USER  # pylint: disable=invalid-name
try:
    opts, args = getopt.getopt(sys.argv[1:], "s:p:u:", [
                               "rabbitmq-server=", "password=", "user="])
except getopt.GetoptError:
    print('python3 consume.py --rabbitmq-server <server> --password <password> --user <user>')
    sys.exit(2)
for opt, arg in opts:
    if opt in ("--rabbitmq-server", "--s"):
        server = arg
    elif opt in ("--password", "--p"):
        password = arg
    elif opt in ("--user", "--u"):
        user = arg


def main():
    """main function."""
    params = pika.URLParameters(f'amqp://{user}:{password}@{server}')
    connection = pika.BlockingConnection(params)
    channel = connection.channel()
    channel.queue_declare(queue=DEFAULT_TOPIC_NAME)

    method_frame, header_frame, body = channel.basic_get(
        queue=DEFAULT_TOPIC_NAME)  # pylint: disable=unused-variable
    if method_frame is None or method_frame.NAME == 'Basic.GetEmpty':
        print(" [x] Error, empty response ")
        connection.close()
    else:
        channel.basic_ack(delivery_tag=method_frame.delivery_tag)
        print(f" [x] Received {body}")
        connection.close()


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print('Interrupted')
        try:
            sys.exit(0)
        except SystemExit:
            os._exit(0)  # pylint: disable=protected-access
