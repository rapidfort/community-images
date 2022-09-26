#!/bin/bash

set -x
set -e

# Available Scripts
ls /opt/bitnami/scripts

# General commands
consul members | tee -a members
SERVERS=$(grep -w "server" -c members)
CLIENTS=$(grep -w "client" -c members)
# Checking the members in the cluster
echo "Number of Servers Active = $SERVERS"
echo "Number of Clients Active = $CLIENTS"
rm members
consul info

# Consul snapshot
consul snapshot save backup.snap
consul snapshot inspect backup.snap

# Registering a test service(This will be deregistered in the main dc_coverage itselfS)
consul services register /consul.d/sample_service.json
consul reload
sleep 10

# Query our service using HTTP Api
curl http://localhost:8500/v1/catalog/service/web

# Checking for the healthy instances
curl http://localhost:8500/v1/health/service/web?passing

# Consul kv
consul kv put redis/config/connections 5
consul kv get -detailed redis/config/connections | tee -a file
# To check the number of connections (Should be 5)
grep "Value" file
rm file
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