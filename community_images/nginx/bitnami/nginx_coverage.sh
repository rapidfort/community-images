#!/bin/bash

set -x # display all commands
set +e # we dont want to error out

apt-get update
apt-get install -y git
git clone https://github.com/nginx/nginx-tests
cd nginx-tests/
TEST_NGINX_BINARY=$(which nginx) TEST_NGINX_MODULES=/opt/bitnami/nginx/modules/ prove .
