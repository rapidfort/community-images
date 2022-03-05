#!/bin/bash

set -x

BASEDIR=$(pwd)/community_images

echo "Creating hardened image for redis"
cd ${BASEDIR}/redis/bitnami
./run.sh ci-dev 6.2.6-debian-10-r103

echo "Creating hardened image for redis-cluster"
cd ${BASEDIR}/redis-cluster/bitnami
./run.sh ci-dev 6.2.6-debian-10-r95

echo "Creating hardened image for postgresql"
cd ${BASEDIR}/postgresql/bitnami
./run.sh ci-dev 14.1.0-debian-10-r80

echo "Creating hardened image for yugabyte"
cd ${BASEDIR}/yugabytedb/yugabyte
./run.sh 2.8.1.1-b5

echo "Creating hardened image for huggingface/transformers-pytorch-cpu"
cd ${BASEDIR}/transformers-pytorch-cpu/huggingface
./run.sh 4.9.1

echo "Image generation completed"
