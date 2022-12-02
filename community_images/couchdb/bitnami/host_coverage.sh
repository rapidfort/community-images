#!/bin/bash

set -e
set -x

couchjs -V || echo "couchjs didn't run properly"

remsh -h || echo "couldn't run remsh"

couchdb --version || echo "couldn't get couchdb version"

