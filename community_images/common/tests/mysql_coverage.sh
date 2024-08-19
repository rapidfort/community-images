#!/bin/bash

set -x
set -e

# add common commands here which should be present in all hardened images
# ref: https://dev.mysql.com/doc/refman/8.0/en/programs-client.html
mysql --version
mysqladmin --version
mysqldump --version

#Below binaries may or may not be present in some versions 
mysqlimport --version || echo 0
mysqlcheck --version || echo 0
mysqlshow --version || echo 0

# mysqlpump --version # not present on mariadb
# mysqlslap --version # doesnt work on mariadb due to char set issue
mysqld_safe --help || mysqld --version
# mysqld_safe is deisgned such that it'll always give exit code status as 1
# mysqld_safe --syslog

# Excluding mariadb from running binaries that are not present in its
#   official version or gives errors.
mysql --version || mariadb --version || ( mysqlpump --version \
					&& mysql_ssl_rsa_setup --version \
					)
