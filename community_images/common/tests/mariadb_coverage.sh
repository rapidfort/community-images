#!/bin/bash

set -x
set -e

# Update commands for MariaDB hardened images
# Ref: https://mariadb.com/kb/en/library/client-programs/

mariadb --version
mariadb-admin --version
mariadb-check --version
mariadb-dump --version
mariadb-import --version
# mariadb-pump --version # The equivalent for mysqlpump may not exist or be necessary in MariaDB depending on the version
mariadb-show --version
mariadbd-safe --help || mariadbd --version
# mysqld_safe is designed such that it'll always give exit code status as 1
# mysqld_safe --syslog

# Excluding commands not present in MariaDB or adjusted for specific MariaDB usage
mariadb --version || ( mariadb-pump --version \
                    && mariadb-ssl-rsa-setup --version \
                    )

# Note: Some commands like mariadb-pump or mariadb-ssl-rsa-setup might not exist in MariaDB.
# Adjust the script by removing or commenting out these lines depending on the specific MariaDB version you're working with.