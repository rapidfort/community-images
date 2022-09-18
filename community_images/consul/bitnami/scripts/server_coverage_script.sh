#!/bin/bash

set -x
set -e

ls

# Available Scripts
ls /opt/bitnami/scripts

# consul acl token list
# consul acl boostrap
consul members
consul info

# Registering a test service
consul services register /consul.d/sample_service.json
consul reload
sleep 10

# Display the congiguration of the server
cat /opt/bitnami/consul/consul.json

# Query our service using HTTP Api
curl http://localhost:8500/vi/catalog/service/web

# Checking for the healthy instances
curl 'http://localhost:8500/v1/health/service/web?passing'

# Removing service
consul services deregister /consul.d/sample_service.json
consul reload