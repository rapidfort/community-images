#!/bin/bash

set -e
set -x

/opt/couchdb/bin/couchjs -V || echo "couchjs didn't run properly"

/opt/couchdb/bin/remsh -h || echo "couldn't run remsh"

/opt/couchdb/bin/couchdb --version || echo "couldn't get couchdb version"
