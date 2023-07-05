#!/bin/bash

PHASE="$1"

# this script keeps track of all things which need to be installed on github actions worker VM
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )"

sudo apt-get install -y curl

curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -

sudo apt-get install -y nodejs

sudo apt-get install -y libatk1.0-0 \
    libatk-bridge2.0-0 libcups2 libxkbcommon-x11-0 \
    libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
    libgbm1 libpango-1.0-0 libcairo2

cd "$SCRIPTPATH"/../report_shots || exit
npm install
node shots.js "${SCRIPTPATH}"/../image.lst "$PHASE"
