#!/bin/bash

set -x

BASEDIR=$(pwd)/community_images

echo "Creating hardened image for redis"
cd ${BASEDIR}/../scripts
LATEST_TAG=$(./dockertags bitnami/redis 6.2.6-debian-10-r)
cd ${BASEDIR}/redis/bitnami
./run.sh ${LATEST_TAG}

echo "Creating hardened image for redis-cluster"
cd ${BASEDIR}/../scripts
LATEST_TAG=$(./dockertags bitnami/redis-cluster 6.2.6-debian-10-r)
cd ${BASEDIR}/redis-cluster/bitnami
./run.sh ${LATEST_TAG}

echo "Creating hardened image for postgresql"
cd ${BASEDIR}/../scripts
LATEST_TAG=$(./dockertags bitnami/postgresql 14.1.0-debian-10-r)
cd ${BASEDIR}/postgresql/bitnami
./run.sh ${LATEST_TAG}

echo "Creating hardened image for yugabyte"
cd ${BASEDIR}/../scripts
LATEST_TAG=$(./dockertags yugabytedb/yugabyte 2.8.1.1-b)
cd ${BASEDIR}/yugabyte/yugabytedb
./run.sh ${LATEST_TAG}

echo "Creating hardened image for huggingface/transformers-pytorch-cpu"
cd ${BASEDIR}/../scripts
LATEST_TAG=$(./dockertags huggingface/transformers-pytorch-cpu 4.9.)
cd ${BASEDIR}/transformers-pytorch-cpu/huggingface
./run.sh ${LATEST_TAG}

echo "Image generation completed"
