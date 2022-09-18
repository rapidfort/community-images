#!/bin/bash

set -x
set -e

ls

# Available Scripts
ls /opt/bitnami/scripts

# Display the congiguration of the server
# cat /opt/bitnami/consul/consul.json

# consul aclt token list
# consul acl boostrap
consul members

# Registering a test service
consul services register /consul.d/sample_service.json
consul reload
sleep 10

# #Query our service using DNS API
# dig @127.0.0.1 -p 8600 rails.web.service.consul SRV

# Query our service using HTTP Api
curl http://localhost:8500/vi/catalog/service/web

# Checking for the healthy instances
curl 'http://localhost:8500/v1/health/service/web?passing'

# Removing service
consul services deregister /consul.d/sample_service.json
consul reload