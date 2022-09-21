#!/bin/bash

set -x
set -e

# Available Scripts
ls /opt/bitnami/scripts

# Checking version
consul version -format=json

# Registering a test service via client
consul reload

# Query our service using HTTP Api
curl http://localhost:8500/vi/catalog/service/web

# Checking for the healthy instances
curl 'http://localhost:8500/v1/health/service/web?passing'

# Create client certs
consul tls ca create
consul tls cert create -client