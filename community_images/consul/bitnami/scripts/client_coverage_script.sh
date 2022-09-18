#!/bin/bash

set -x
set -e

ls

# Available Scripts
ls /opt/bitnami/scripts

# Registering a test service via client
consul reload

# Query our service using HTTP Api
curl http://localhost:8500/vi/catalog/service/web

# Checking for the healthy instances
curl 'http://localhost:8500/v1/health/service/web?passing'