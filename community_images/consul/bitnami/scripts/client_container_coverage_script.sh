#!/bin/bash

set -x
set -e

# The purpose of this script is to Query our service using DNS API through a client container(Doesn't run on the stubbed image)

# Available Scripts
ls /opt/bitnami/scripts

consul members

apt-get install dnsutils

dig @127.0.0.1 -p 8600 rails.web.service.consul SRV
