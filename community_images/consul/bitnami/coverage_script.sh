#!/bin/bash

set -x
set -e

ls

#Available Scripts
ls /opt/bitnami/scripts

#consul aclt token list
#consul acl boostrap
#consul agent -data-dir=tmp/consul
consul members

#Registering a test service
consul agent -config-dir=./consul.d

#Query our service using DNS api
dig @127.0.0.1 -p 8600 rails.web.service.consul SRV

#Query our service using HTTP Api
curl http://localhost:8500/vi/catalog/service/web

#Checking only the healthy instances
curl 'http://localhost:8500/v1/health/service/web?passing'

#Removing service
consul leave
rm -rf comsul.d 
consul reload