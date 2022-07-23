#!/bin/bash

set -x
set -e

sed -i 's/#LoadModule /LoadModule /' /opt/bitnami/apache2/conf/httpd.conf
sed -i 's/#LoadModule /LoadModule /' /opt/bitnami/apache/conf/httpd.conf

/opt/bitnami/scripts/apache/restart.sh
/opt/bitnami/scripts/apache/reload.sh
/opt/bitnami/scripts/apache/status.sh
