#!/bin/bash

set -x
set -e

# The purpose of this script is to Query our service using DNS API through a client container(This doesn't run on the stubbed image)

# Available Scripts
ls /opt/bitnami/scripts
consul reload

# Consul Monitor
# consul monitor -log-json

# Consul Catalg
# List all datacenters:
consul catalog datacenters
# List all nodes and services
consul catalog nodes
consul catalog services

# Consul Snapshot
consul snapshot save backup.snap

# Consul ACLs
# Bootstrap Consul's ACLs:
consul acl bootstrap
# Create a sample policy:
consul acl policy create -name "acl-replication" -description "Token capable of replicating ACL policies" -rules 'acl = "read"'
# Create a token list:
consul acl token create -description "Agent Policy Replication - my-agent" -policy-name "acl-replication"
# List all ACL tokens
consul acl token list

# Consul keygen
consul keygen

# Consul License
consul license reset

# Consul Maint
consul maint

# Consul validate
consul validate /opt/bitnami/consul/

# Consul watch
consul watch -type=nodes /usr/bin/my-nodes-handler.sh