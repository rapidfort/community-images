#!/bin/bash

set -x
set -e

# The purpose of this script is to Query our service using DNS API through a client container(This doesn't run on the stubbed image)

# Available Scripts
ls /opt/bitnami/scripts
consul reload

# Consul Catalg
# List all datacenters:
consul catalog datacenters
# List all nodes and services
consul catalog nodes
consul catalog services

# Consul keygen
consul keygen

# Consul Maint
consul maint