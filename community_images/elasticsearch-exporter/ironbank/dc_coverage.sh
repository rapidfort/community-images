#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

ES_CONTAINER_NAME="elasticsearch"
ES_EXPORTER_CONTAINER_NAME="elasticsearch-exporter"

# fetching the dynamically assigned port for belasticsearch using container name
ES_PORT=$(docker port "$ES_CONTAINER_NAME" 9200 | head -n 1 | awk -F: '{print $2}')

if [ -z "$ES_PORT" ]; then
    echo "Failed to retrieve the port for elasticsearch. Ensure the service is running."
    exit 1
fi

# fetching the dynamically assigned port for belasticsearch-exporter using container name
ES_EXPORTER_PORT=$(docker port "$ES_EXPORTER_CONTAINER_NAME" 9114 | head -n 1 | awk -F: '{print $2}')

if [ -z "$ES_EXPORTER_PORT" ]; then
    echo "Failed to retrieve the port for elasticsearch-exporter. Ensure the service is running."
    exit 1
fi

# base url for elasticsearch
ES_BASE_URL="http://localhost:$ES_PORT"

# base url for elasticsearch-exporter
ES_EXPORTER_BASE_URL="http://localhost:$ES_EXPORTER_PORT"

# Exercising some functionalities in elasticsearch container to generate logs
# setting up a new index
curl -X PUT "${ES_BASE_URL}/my_index?pretty"

# Indexing a Sample Document
curl -X POST "${ES_BASE_URL}/my_index/_doc/1?pretty" -H 'Content-Type: application/json' -d'
{
  "user": "Kanav Phull",
  "birth_date": "2002-07-15T02:00:00",
  "message": "trying out Elasticsearch"
}
'

# Search for a Document with query
curl -X GET "${ES_BASE_URL}/my_index/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "message": "trying"
    }
  }
}
'

# Update the Document using ID
curl -X POST "${ES_BASE_URL}/my_index/_update/1?pretty" -H 'Content-Type: application/json' -d'
{
  "doc": {
    "message": "trying out Elasticsearch, updating document"
  }
}
'

# Delete the Document using ID
curl -X DELETE "${ES_BASE_URL}/my_index/_doc/1?pretty"

# Delete the index
curl -X DELETE "${ES_BASE_URL}/my_index?pretty"

# Fetching logs from the elasticsearch-exporter
curl "${ES_EXPORTER_BASE_URL}/metrics"

# CLI Coverage for elasticsearch-exporter
docker exec -i "$ES_EXPORTER_CONTAINER_NAME" /bin/bash -c "elasticsearch-exporter --help"
