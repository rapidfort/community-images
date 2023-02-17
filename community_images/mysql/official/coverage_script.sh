#!/bin/bash

set -x
set -e

mysql --version
mysqladmin --version
mysqlcheck --version
mysqldump --version
mysqlimport --version
mysqlshow --version

mysqlpump --version
mysqlsh --version
mysql_ssl_rsa_setup --version
