#!/bin/bash

set -x

BASEDIR=$(pwd)

echo "Creating hardened image for redis"
cd ${BASEDIR}/bitnami/redis
./run.sh ci-dev 6.2.6-debian-10-r103

echo "Creating hardened image for redis-cluster"
cd ${BASEDIR}/bitnami/redis-cluster
./run.sh ci-dev 6.2.6-debian-10-r95

echo "Creating hardened image for postgresql"
cd ${BASEDIR}/bitnami/postgresql
./run.sh ci-dev 14.1.0-debian-10-r80

echo "Creating hardened image for yugabyte"
cd ${BASEDIR}/yugabytedb
./run.sh 2.8.1.1-b5

echo "Creating hardened image for huggingface/transformers-pytorch-cpu"
cd ${BASEDIR}/huggingface/transformers-pytorch-cpu
./run.sh 4.9.1

echo "Image generation completed"
