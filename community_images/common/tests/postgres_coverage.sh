#!/bin/bash

set -x
set -e

# add common commands here which should be present in all hardened images

clusterdb --version
createdb --version
createuser --version
dropdb --version
dropuser --version
if command -v ecpg --version &> /dev/null
then
    ecpg --version
fi
if command -v pg_amcheck --version &> /dev/null
then
    pg_amcheck --version
fi
pg_basebackup --version
pgbench --version
pg_config --version
pg_dump --version
pg_dumpall --version
pg_isready --version
pg_receivewal --version
pg_recvlogical --version
pg_restore --version
if command -v pg_verifybackup --version &> /dev/null
then
    pg_verifybackup --version
fi
psql --version
reindexdb --version
vacuumdb --version
