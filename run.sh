#!/bin/bash

set -x

echo "Creating hardened image for redis"
cd bitnami/redis
./run.sh ci-dev 6.2.6-debian-10-r103

echo "Creating hardened image for redis-cluster"
cd ../redis-cluster
./run.sh ci-dev 6.2.6-debian-10-r95

echo "Image generation completed"