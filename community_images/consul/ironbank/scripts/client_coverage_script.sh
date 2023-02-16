#!/bin/bash

set -x
set -e

# Available Scripts
ls /opt/scripts

# Checking version
consul version -format=json

# Create client certs
consul tls ca create
consul tls cert create -client

# Using consul debug
consul debug -interval=15s -duration=1m