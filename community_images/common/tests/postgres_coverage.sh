#!/bin/bash

set -x
set -e

# add common commands here which should be present in all hardened images

clusterdb --version
createdb --version
createuser --version
dropdb --version
dropuser --version
ecpg --version
pg_amcheck --version
pg_basebackup --version
pgbench --version
pg_config --version
pg_dump --version
pg_dumpall --version
pg_isready --version
pg_receivewal --version
pg_recvlogical --version
pg_restore --version
pg_verifybackup --version
psql --version
reindexdb --version
vacuumdb --version
