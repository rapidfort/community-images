#!/bin/bash

set -e
set -x

rabbitmqctl version
rabbitmq-diagnostics help
rabbitmq-diagnostics status
rabbitmqctl add_user "a-user" "a-passw0rd"
rabbitmq-plugins list
rabbitmq-queues help
rabbitmq-upgrade help
rabbitmq-diagnostics cluster_status
rabbitmq-streams help
rabbitmqadmin help