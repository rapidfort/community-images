#!/bin/bash

set -x
set -e
ls /opt/bitnami/apache2/modules/


httpd -M
sed -i 's/roundrobin/leastconn/g' /bitnami/haproxy/conf/haproxy.cfg
# reload
sed -i 's/leastconn/source/g' /bitnami/haproxy/conf/haproxy.cfg
cat /opt/bitnami/scripts/modules_list >> /opt/bitnami/apache2/conf/httpd.conf
#cat /opt/bitnami/apache2/conf/httpd.conf
/opt/bitnami/scripts/apache/reload.sh
/opt/bitnami/scripts/apache/status.sh
httpd -M
