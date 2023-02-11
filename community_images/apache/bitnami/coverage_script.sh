#!/bin/bash

set -x
set -e
ls /opt/bitnami/apache2/modules/
httpd -M
sed -i '/LoadModule /d' /opt/bitnami/apache2/conf/httpd.conf
cat /opt/bitnami/scripts/modules_list >> /opt/bitnami/apache2/conf/httpd.conf
#cat /opt/bitnami/apache2/conf/httpd.conf
/opt/bitnami/scripts/apache/reload.sh
/opt/bitnami/scripts/apache/status.sh

/lib/init/vars.sh

httpd -M
#Modules excluded: ["unixd_module" "pagespeed_module" "pagespeed_ap24_module" "mpm_worker_module" "mpm_event_module"]
