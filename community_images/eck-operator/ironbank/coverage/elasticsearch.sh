#!/bin/bash

set -x
set -e

NAMESPACE=$1

if [ -z "$NAMESPACE" ]; then
  echo "NAMESPACE is not set for coverage of Elasticsearch. Exiting."
  exit 1
fi

# Get the Password for the user "elastic"
PASSWORD=$(kubectl get secret elasticsearch-es-elastic-user -n "${NAMESPACE}" -o json | jq -r .data.elastic | base64 -d)

# Forward the host port 9200 to elastic http service port 9200 in k8s cluster
kubectl port-forward service/elasticsearch-es-http 9200:9200 -n "${NAMESPACE}" &

# Get the PID of the background elasticsearch process
PORT_FORWARD_PID=$!

# Sleep for 5 seconds
sleep 5

# Base URL for the elasticsearch server
ES_BASE_URL="https://localhost:9200"

# Exercising some functionalities in elasticsearch to generate logs
# Get the details regarding the Elasticsearch node
curl "${ES_BASE_URL}" -u elastic:"${PASSWORD}" -k

# Setting up a new index with specific settings and mappings
curl -X PUT ""${ES_BASE_URL}/"my_index?pretty" -u elastic:"${PASSWORD}" -k -H 'Content-Type: application/json' -d' 
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1
  },
  "mappings": {
    "properties": {
      "user": { "type": "text" },
      "birth_date": { "type": "date" },
      "message": { "type": "text" }
    }
  }
}
'

# Indexing multiple documents using bulk API
curl -X POST ""${ES_BASE_URL}/"_bulk?pretty" -u elastic:"${PASSWORD}" -k -H 'Content-Type: application/x-ndjson' -d' 
{ "index" : { "_index" : "my_index", "_id" : "1" } }
{ "user": "Mridul Verma", "birth_date": "2001-09-17T00:04:00", "message": "Testing Elasticsearch" }
{ "index" : { "_index" : "my_index", "_id" : "2" } }
{ "user": "Another User", "birth_date": "1990-01-01T00:00:00", "message": "Another test message" }
'

# Refresh the index to make the documents searchable
curl -X POST ""${ES_BASE_URL}/"my_index/_refresh?pretty" -u elastic:"${PASSWORD}" -k

# Search for documents with a match query
curl -X GET ""${ES_BASE_URL}/"my_index/_search?pretty" -u elastic:"${PASSWORD}" -k -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "message": "Testing"
    }
  }
}
'

# Perform an aggregation on the indexed data
curl -X GET ""${ES_BASE_URL}/"my_index/_search?pretty" -u elastic:"${PASSWORD}" -k -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "birth_years": {
      "date_histogram": {
        "field": "birth_date",
        "calendar_interval": "year"
      }
    }
  }
}
'

# Update the Document using ID
curl -X POST ""${ES_BASE_URL}/"my_index/_update/1?pretty" -u elastic:"${PASSWORD}" -k -H 'Content-Type: application/json' -d'
{
  "doc": {
    "message": "Testing Elasticsearch, updating document"
  }
}
'

# Delete the Document using ID
curl -X DELETE ""${ES_BASE_URL}/"my_index/_doc/1?pretty" -u elastic:"${PASSWORD}" -k

# Delete the index
curl -X DELETE ""${ES_BASE_URL}/"my_index?pretty" -u elastic:"${PASSWORD}" -k

# Create an index template
curl -X PUT ""${ES_BASE_URL}/"_index_template/my_template?pretty" -u elastic:"${PASSWORD}" -k -H 'Content-Type: application/json' -d'
{
  "index_patterns": ["template_index*"],
  "template": {
    "settings": {
      "number_of_shards": 1
    },
    "mappings": {
      "properties": {
        "user": { "type": "keyword" }
      }
    }
  }
}
'

# Create an index using the template
curl -X PUT ""${ES_BASE_URL}/"template_index_1?pretty" -u elastic:"${PASSWORD}" -k

# Index a document into the template-based index
curl -X POST ""${ES_BASE_URL}/"template_index_1/_doc?pretty" -u elastic:"${PASSWORD}" -k -H 'Content-Type: application/json' -d'
{
  "user": "Template User"
}
'

# Get the document from the template-based index
curl -X GET ""${ES_BASE_URL}/"template_index_1/_doc/1?pretty" -u elastic:"${PASSWORD}" -k

# Delete the template-based index
curl -X DELETE ""${ES_BASE_URL}/"template_index_1?pretty" -u elastic:"${PASSWORD}" -k

# Delete the index template
curl -X DELETE ""${ES_BASE_URL}/"_index_template/my_template?pretty" -u elastic:"${PASSWORD}" -k

# Kill the exposed host port
kill $PORT_FORWARD_PID
