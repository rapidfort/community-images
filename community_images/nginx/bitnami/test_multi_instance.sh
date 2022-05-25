#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

export IPADDR=127.0.0.1
export PORTNUM=443
export ERROR_RESULT=0
export SCHEME="https://"
export HOST=${SCHEME}${IPADDR}:${PORTNUM}
export NUM=1
export FIND_ME="1st"
function multii_check
{
  rm -f foo
  touch foo
  export RETRIES=32
  export SUCCESS=0
  while [ ${RETRIES} -gt 0 ] ; do
    export RETRIES=$(( RETRIES - 1 ))
    echo "fetching 1.html ..."
    curl ${HOST}/multi/${NUM}.html  --insecure > foo
    if grep "${FIND_ME}" foo ; then
      echo "found it!"
      export SUCCESS=1
      export RETRIES=0
    else
      echo "didnt find it, sleeping, retrying (${RETRIES})..."
      sleep 2
    fi
  done
  if [ "$SUCCESS" = "1" ] ; then
    echo "check success."
  else
    echo "check failed."
    export ERROR_RESULT=1
  fi
}
HELM_RELEASE=multi-nginx
helm upgrade --install "${HELM_RELEASE}" "${SCRIPTPATH}"/multi-nginx --set replicaCount=3 --set image.repository=rapidfort/nginx --set image.tag=latest

export NUM=1
export FIND_ME="1st"
multii_check
export NUM=2
export FIND_ME="2nd"
multii_check
export NUM=3
export FIND_ME="3rd"
multii_check

helm uninstall multi-nginx

if [ "$ERROR_RESULT" = "0" ] ; then
  echo "success."
  exit 0
else
  echo "failed."
  exit 1
fi
