#!/bin/bash

set -x
set -e

# The purpose of this script is to Query our service using DNS API through a client container(This doesn't run on the stubbed image)

# Available Scripts
ls /opt/scripts

# Installing dnsutils
apk update
apk add dnsutils -y

# Query our service using HTTP Api
curl http://localhost:8500/v1/catalog/service/web

# Checking for the healthy instances
curl 'http://localhost:8500/v1/health/service/web?passing'

# Query our service using DNS API on consul-node-1
dig consul-node1/8600 rails.web.service.consul SRV