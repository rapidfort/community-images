#!/bin/bash

set -x
set -e

MODULE_DIR="/etc/nginx/modules"

cd "$MODULE_DIR"
declare -a MODULE_ARRAY=( $( ls . ) )

for module in "${MODULE_ARRAY[@]}"
do
    echo "load_module modules/${module}.so;" | cat - /etc/nginx/conf/nginx.conf > /tmp/nginx.conf && \
        cp /tmp/nginx.conf /etc/nginx/conf/nginx.conf
done

nginx -s reload
