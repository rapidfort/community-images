#!/bin/bash

set -x
set -e

HOST=$(kubectl get svc --namespace kong-t4g02uka0u rf-kong-kong-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
PORT=$(kubectl get svc --namespace kong-t4g02uka0u rf-kong-kong-proxy -o jsonpath='{.spec.ports[0].port}')
export PROXY_IP=${HOST}:${PORT}
curl $PROXY_IP

