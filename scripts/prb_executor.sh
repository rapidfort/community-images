#!/bin/bash

set -x
set -e

ci_list = (mariadb/bitnami mongodb/bitnami mysql/bitnami postgresql/bitnami redis/bitnami redis-cluster/bitnami)

for i in "${ci_list[@]}"
do
   echo "${i}"
done
