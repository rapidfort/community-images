#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

# get pod name
TOMCAT_SERVER=localhost

kubectl -n "${NAMESPACE}" exec "${RELEASE_NAME}" \
	-- curl "https://tomcat.apache.org/tomcat-10.0-doc/appdev/sample/sample.war" --output "webapps/sample.war"

kubectl -n "${NAMESPACE}" exec "${RELEASE_NAME}" \
  -- bash -c 'echo -e "\n\n\n\n\n\nyes\n" | keytool -genkey -alias localhost-rsa -keyalg RSA -keystore conf/localhost-rsa.jks -storepass changeit -validity 3650 -keypass changeit'

kubectl -n "${NAMESPACE}" exec -i "${RELEASE_NAME}" \
  -- bash -c 'cat > conf/server.xml' < "${SCRIPTPATH}/server.xml"

kubectl -n "${NAMESPACE}" exec "${RELEASE_NAME}" \
	-- catalina.sh run &
CATALINA_PID=$!

sleep 20

PORT=18443
kubectl port-forward -n ${NAMESPACE} ${RELEASE_NAME} ${PORT}:8443 &
PORT_FORWARD_PID=$!

sleep 10

# Smaple app main page
curl "https://${TOMCAT_SERVER}:${PORT}/sample/" \
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7" \
  -H "Accept-Language: en-GB,en;q=0.9" \
  -H "Connection: keep-alive" \
  -H "Cookie: JSESSIONID=B8871DFEAE4F9B5F9FCDB1EFA9710C89" \
  -H "Upgrade-Insecure-Requests: 1" \
  -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36" \
  --insecure -k

# Sample servlet
curl "https://${TOMCAT_SERVER}:${PORT}/sample/hello" \
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7" \
  -H "Accept-Language: en-GB,en;q=0.9" \
  -H "Cache-Control: max-age=0" \
  -H "Connection: keep-alive" \
  -H "Cookie: JSESSIONID=B8871DFEAE4F9B5F9FCDB1EFA9710C89" \
  -H "Referer: https://${TOMCAT_SERVER}:${PORT}/sample/" \
  -H "Upgrade-Insecure-Requests: 1" \
  -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36" \
  --insecure -k

# Sample JSP
curl "https://${TOMCAT_SERVER}:${PORT}/sample/hello.jsp" \
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7" \
  -H "Accept-Language: en-GB,en;q=0.9" \
  -H "Cache-Control: max-age=0" \
  -H "Connection: keep-alive" \
  -H "Cookie: JSESSIONID=B8871DFEAE4F9B5F9FCDB1EFA9710C89" \
  -H "Upgrade-Insecure-Requests: 1" \
  -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36" \
  --insecure -k

# Get file
curl "https://${TOMCAT_SERVER}:${PORT}/sample/images/tomcat.gif" \
  -H "Referer: https://${TOMCAT_SERVER}:${PORT}/sample/hello.jsp" \
  -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36" \
  --output /dev/null -k

kill -s 15 ${PORT_FORWARD_PID} || true
kill -s 15 ${CATALINA_PID} || true
