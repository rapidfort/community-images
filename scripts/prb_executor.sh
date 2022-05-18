#!/usr/bin/parallel

set -x
set -e

ci_list=("mariadb/bitnami" "mongodb/bitnami" "mysql/bitnami" "postgresql/bitnami" "redis/bitnami" "redis-cluster/bitnami")

for i in "${ci_list[@]}"; do
    sem -j10 ./community_images/"${i}"/run.sh ";" echo done
done
sem --wait
