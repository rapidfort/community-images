#!/bin/bash

set -x
set -e

# add common commands here which should be present in all hardened images
# ref: https://www.mongodb.com/docs/database-tools/

mongodump --version
mongorestore --version
bsondump --version
mongoimport --version
mongoexport --version
mongostat --version
mongotop --version
mongofiles --version
mongo --version