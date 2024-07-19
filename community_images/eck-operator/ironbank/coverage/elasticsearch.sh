#!/bin/bash

set -x
set -e

NAMESPACE=$1

if [ -z "$NAMESPACE" ]; then
  echo "NAMESPACE is not set for coverage of Elasticsearch. Exiting."
  exit 1
fi

# Get the Password for the user "elastic"
PASSWORD=$(kubectl get secret elasticsearch-es-elastic-user -n ${NAMESPACE} -o json | jq -r .data.elastic | base64 -d)

# Forward the host port 9200 to elastic http service port 9200 in k8s cluster
kubectl port-forward service/elasticsearch-es-http 9200:9200 -n ${NAMESPACE} &
kubectl port-forward service/elasticsearch-es-http 9200:9200 -n eck-1 &
# 2227658
# Get the PID of the background elasticsearch process
PORT_FORWARD_PID=$!

# Sleep for 5 seconds
sleep 5

# Base URL for the elasticsearch server
ES_BASE_URL="https://localhost:9200"

# Exercising some functionalities in elasticsearch to generate logs
# Get the details regarding the Elasticsearch node
curl ${ES_BASE_URL} -u elastic:${PASSWORD} -k

# Setting up a new index
curl -X PUT "${ES_BASE_URL}/my_index?pretty" -u elastic:${PASSWORD} -k

# Indexing a Sample Document
curl -X POST "${ES_BASE_URL}/my_index/_doc/1?pretty" -H 'Content-Type: application/json' -u elastic:${PASSWORD} -k -d' 
{
  "user": "Mridul Verma",
  "birth_date": "2001-09-17T00:04:00",
  "message": "Testing Elasticsearch"
}
'

# Search for a Document with query
curl -X GET "${ES_BASE_URL}/my_index/_search?pretty" -H 'Content-Type: application/json' -u elastic:${PASSWORD} -k -d' 
{
  "query": {
    "match": {
      "message": "Testing"
    }
  }
}
'

# Update the Document using ID
curl -X POST "${ES_BASE_URL}/my_index/_update/1?pretty" -H 'Content-Type: application/json' -u elastic:${PASSWORD} -k -d' 
{
  "doc": {
    "message": "Testing Elasticsearch, updating document"
  }
}
'

# Delete the Document using ID
curl -X DELETE "${ES_BASE_URL}/my_index/_doc/1?pretty" -u elastic:${PASSWORD} -k

# Delete the index
curl -X DELETE "${ES_BASE_URL}/my_index?pretty" -u elastic:${PASSWORD} -k

# Kill the exposed host port
kill $PORT_FORWARD_PID

# for apm_server

curl -k -X PUT "https://localhost:9200/_template/metrics-apm-template" -u elastic:OH33aX9cgi94XSb1R6Da11g8 -H 'Content-Type: application/json' -d '
{
  "index_patterns": ["metrics-apm-*"],
  "settings": {
    "number_of_shards": 1
  },
  "mappings": {
    "properties": {
      "service": {
        "properties": {
          "name": { "type": "keyword" }
        }
      },
      "transaction": {
        "properties": {
          "duration": { "type": "double" }
        }
      },
      "timestamp": { "type": "date" }
    }
  }
}
'

curl -k -X PUT "https://localhost:9200/_template/logs-apm-template" -u elastic:OH33aX9cgi94XSb1R6Da11g8 -H 'Content-Type: application/json' -d '
{
  "index_patterns": ["logs-apm-*"],
  "settings": {
    "number_of_shards": 1
  },
  "mappings": {
    "properties": {
      "service": {
        "properties": {
          "name": { "type": "keyword" }
        }
      },
      "message": { "type": "text" },
      "timestamp": { "type": "date" }
    }
  }
}
'

curl -k -X GET "https://localhost:9200/_cat/templates?v" -u elastic:OH33aX9cgi94XSb1R6Da11g8

curl -k -X PUT "https://localhost:9200/_security/role_mapping/eck-1-apm-server-apm-kb-user-mapping" -u elastic:TtnsFV34594l8Doh7X6R9V8x -H 'Content-Type: application/json' -d '
{
  "roles": ["superuser", "kibana_admin", "kibana_user", "apm_user"],
  "enabled": true,
  "rules": { "field": { "username": "eck-1-apm-server-apm-kb-user" } }
}'

curl -k -X GET "https://localhost:9200/_security/role_mapping/eck-1-apm-server-apm-kb-user-mapping" -u elastic:TtnsFV34594l8Doh7X6R9V8x