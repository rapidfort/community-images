#!/bin/bash

set -x
set -e

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

# Query our service using HTTP Api
curl http://localhost:8500/vi/catalog/service/web

# Checking for the healthy instances
curl 'http://localhost:8500/v1/health/service/web?passing'

# Removing service
consul services deregister /consul.d/sample_service.json

# Using consul debug
consul reload
consul debug -interval=15s -duration=1m

# Consul connect
consul connect proxy

# Consul kv
consul kv put redis/config/connections 5
consul kv get -detailed redis/config/connections
consul kv delete redis/config/connections

# Consul Operator Raft
consul operator raft list-peers

# Consul keygen
consul keygen

# Consul Maint
consul maint

# Consul Catalg
# List all datacenters:
consul catalog datacenters
# List all nodes and services
consul catalog nodes
consul catalog services