#!/bin/bash

set -e
set -x

couchjs -V

remsh --version

couchdb --version