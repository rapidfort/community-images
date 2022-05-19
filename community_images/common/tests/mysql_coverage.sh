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
mysqlpump --version
mysqlshow --version
mysqlslap --version
