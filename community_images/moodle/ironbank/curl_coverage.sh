#!/bin/bash

set -ex

MOODLE_HOST=${1:=127.0.0.1}
MOODLE_PORT=${2:=8080}

# Get language select page
curl -X GET \
  -H "Host: ${MOODLE_HOST}:${MOODLE_PORT}"\
  "http://${MOODLE_HOST}:${MOODLE_PORT}/install.php"

# Get css
curl -X GET \
  -H "Host: ${MOODLE_HOST}:${MOODLE_PORT}" \
  "http://${MOODLE_HOST}:${MOODLE_PORT}/install/css.php"

# Get favicon
curl -X GET \
  -H "Host: ${MOODLE_HOST}:${MOODLE_PORT}" \
  "http://${MOODLE_HOST}:${MOODLE_PORT}/theme/clean/pix/favicon.ico" -o /dev/null

# Path confirmation page
curl -X POST \
    --data-raw "lang=en&stage=0&dbtype=&dbhost=${MOODLE_HOST}&dbuser=&dbpass=&dbname=moodle&prefix=mdl_&dbport=&dbsocket=&admin=admin&dataroot=%2Fvar%2Fwww%2Fmoodledata&lang=en&next=Next+%C2%BB" \
    "http://${MOODLE_HOST}:${MOODLE_PORT}/install.php" 

# Get database driver page
curl -X POST \
    --data-raw "lang=en&stage=2&dbtype=&dbhost=${MOODLE_HOST}&dbuser=&dbpass=&dbname=moodle&prefix=mdl_&dbport=&dbsocket=&admin=admin&dataroot=%2Fvar%2Fwww%2Fmoodledata&dataroot=%2Fvar%2Fwww%2Fmoodledata&next=Next+%C2%BB" \
    "http://${MOODLE_HOST}:${MOODLE_PORT}/install.php"

# Get database details page
curl -X POST \
    --data-raw "lang=en&stage=4&dbtype=&dbhost=${MOODLE_HOST}&dbuser=&dbpass=&dbname=moodle&prefix=mdl_&dbport=&dbsocket=&admin=admin&dataroot=%2Fvar%2Fwww%2Fmoodledata&dbtype=pgsql&next=Next+%C2%BB" \
    "http://${MOODLE_HOST}:${MOODLE_PORT}/install.php"

