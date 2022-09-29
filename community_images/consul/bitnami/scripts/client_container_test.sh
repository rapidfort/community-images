#!/bin/bash

set -x
set -e

# The purpose of this script is to Query our service using DNS API through a client container(This doesn't run on the stubbed image)

# Available Scripts
ls /opt/bitnami/scripts

# Installing dnsutils
apt-get update
apt-get install dnsutils -y

# Query our service using DNS API on consul-node-1
dig consul-node1/8600 rails.web.service.consul SRV