#!/bin/bash

set -x
set -e
ls /opt/bitnami/scripts

#consul aclt token list
#consul acl boostrap
consul agent -data-dir=tmp/consul
