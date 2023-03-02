#!/bin/bash

set -x
set -e

# add common commands here which should be present in all hardened images
# ref: https://dev.mysql.com/doc/refman/8.0/en/programs-client.html

mysql --version
mysqladmin --version
mysqlcheck --version
mysqldump --version
mysqlimport --version
# mysqlpump --version # not present on mariadb
mysqlshow --version
# mysqlslap --version # doesnt work on mariadb due to char set issue
mysqld_safe --help || mysqld --version
# mysqld_safe is deisgned such that it'll always give exit code status as 1
# mysqld_safe --syslog
mysqlbinlog --no-defaults --version