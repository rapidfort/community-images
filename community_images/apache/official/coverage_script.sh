#!/bin/bash

set -x
set -e
ls modules/
httpd -M
ls
sed -i '/LoadModule /d' conf/httpd.conf
cat modules_list >> conf/httpd.conf
apachectl configtest
apachectl -k graceful
httpd -M
#Modules excluded: ["unixd_module" "pagespeed_module" "pagespeed_ap24_module" "mpm_worker_module" "mpm_event_module"]
