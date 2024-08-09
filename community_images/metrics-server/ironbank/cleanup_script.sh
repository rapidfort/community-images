#!/bin/bash

set -x
set -e

# Script to cleanup php-apache 

kubectl delete deployment php-apache
kubectl delete service php-apache
kubectl delete hpa php-apache
echo "Cleanup process for php-apache completed"
