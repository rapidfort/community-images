#!/bin/bash

set -x

BASEDIR=$(pwd)/community_images

echo "Creating hardened image for redis"
cd ${BASEDIR}/redis/bitnami
./run.sh

echo "Creating hardened image for redis-cluster"
cd ${BASEDIR}/redis-cluster/bitnami
./run.sh

echo "Creating hardened image for postgresql"
cd ${BASEDIR}/postgresql/bitnami
./run.sh

echo "Creating hardened image for yugabyte"
cd ${BASEDIR}/yugabyte/yugabytedb
./run.sh

echo "Creating hardened image for huggingface/transformers-pytorch-cpu"
cd ${BASEDIR}/transformers-pytorch-cpu/huggingface
./run.sh

echo "Image generation completed"
