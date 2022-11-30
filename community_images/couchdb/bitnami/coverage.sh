#!/bin/bash

set -e
set -x

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

function test_couchdb () {
    CONTAINER_NAME=$1
    docker exec -i "${CONTAINER_NAME}" bash -c /opt/bitnami/scripts/host_coverage_script.sh

    # verify that CouchDB is available and installed correctly
    echo "verify that CouchDB is available and installed correctly"
    curl -X GET http://127.0.0.1:5984/ --user admin:couchdb --fail 2>&1 || echo "CouchDB didn't start properly"

    # list all the CouchDB databases
    echo "list all the CouchDB databases"
    curl -X GET http://127.0.0.1:5984/_all_dbs --user admin:couchdb --fail 2>&1 || echo "CouchDB didn't start properly"

    # create a CouchDB database
    echo "create a CouchDB database"
    curl -X PUT http://127.0.0.1:5984/reviews --user admin:couchdb --fail 2>&1 || echo "Failed to create CouchDB database"

    # try inserting into the CouchDB database
    echo "try inserting into the CouchDB database"
    out=$(curl -s -X PUT http://127.0.0.1:5984/reviews/01 -d '{"reviewer_name":"Ben", "stars":"4", "details":"Love the calzone!"}' --user admin:couchdb --fail 2>&1) || echo "Failed to insert data in CouchDB database"
    rev=$(echo "${out}" | jq -r '.rev')

    # fetch record
    echo "fetch a sample record from database"
    curl -X GET http://127.0.0.1:5984/reviews/01 --user admin:couchdb --fail 2>&1 || echo "Failed to get CouchDB database record"

    # update the record
    echo "update a sample record in database"
    out=$(curl -s -X PUT http://127.0.0.1:5984/reviews/01 -d '{"_id":"01", "stars":"5", "_rev":"'"$rev"'"}' --user admin:couchdb --fail 2>&1) || echo "Failed to update the record"
    rev=$(echo "${out}" | jq -r '.rev')

    # delete the db record
    echo "delete a sample record from database"
    curl -X DELETE http://127.0.0.1:5984/reviews/01?rev="${rev}" --user admin:couchdb --fail 2>&1 || echo "Failed to delete the record"

    # read the record again, it should be deleted
    echo "read the record again, it should throw error"
    curl -X GET http://127.0.0.1:5984/reviews/01 --user admin:couchdb --fail 2>&1 || echo "record got deleted"
}
