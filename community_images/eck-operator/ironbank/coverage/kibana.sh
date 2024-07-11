#!/bin/bash

# Set variables
NAMESPACE=eck-operator
ELASTICSEARCH_NAME=elasticsearch
KIBANA_NAME=kibana
KIBANA_PORT=5601

# Create the namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Port forward Kibana service to localhost
kubectl port-forward service/${KIBANA_NAME}-kb-http ${KIBANA_PORT}:${KIBANA_PORT} -n $NAMESPACE &
KIBANA_PORT_FORWARD_PID=$!

# Ensure port-forwarding process is killed on script exit
trap "kill $KIBANA_PORT_FORWARD_PID" EXIT

# Wait for port forwarding to start
sleep 5

echo "Kibana is available at http://localhost:${KIBANA_PORT}"

# Get the Elasticsearch password
ELASTIC_PASSWORD=$(kubectl get secret ${ELASTICSEARCH_NAME}-es-elastic-user -o=jsonpath='{.data.elastic}' -n $NAMESPACE | base64 --decode)

# Print the Elasticsearch password
echo "Elasticsearch password for user 'elastic': $ELASTIC_PASSWORD"

# Test connection to Kibana
echo "Testing connection to Kibana..."
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -u elastic:$ELASTIC_PASSWORD http://localhost:${KIBANA_PORT})
if [ "$STATUS_CODE" -eq 200 ]; then
  echo "Kibana is up and running."
else
  echo "Failed to connect to Kibana."
  exit 1
fi

# Test connection to Elasticsearch through Kibana
echo "Checking Kibana connection to Elasticsearch..."
KIBANA_STATUS=$(curl -s -u elastic:$ELASTIC_PASSWORD -X GET "http://localhost:${KIBANA_PORT}/api/status" | jq .status.overall.state)
if [ "$KIBANA_STATUS" == "\"green\"" ] || [ "$KIBANA_STATUS" == "\"yellow\"" ]; then
  echo "Kibana is successfully connected to Elasticsearch."
else
  echo "Kibana is not connected to Elasticsearch properly."
  exit 1
fi

# Ingest sample data into Elasticsearch
echo "Ingesting sample data into Elasticsearch..."
curl -s -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -X POST "http://localhost:9200/my_index/_doc/1" -d '
{
  "user": "test_user",
  "message": "Testing Kibana",
  "timestamp": "'"$(date --utc +%Y-%m-%dT%H:%M:%SZ)"'"
}'

# Create index pattern in Kibana
echo "Creating index pattern in Kibana..."
curl -s -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -X POST "http://localhost:${KIBANA_PORT}/api/saved_objects/index-pattern/my_index_pattern" -d '
{
  "attributes": {
    "title": "my_index*",
    "timeFieldName": "timestamp"
  }
}'

# Create a sample dashboard
echo "Creating a sample dashboard in Kibana..."
DASHBOARD_ID=$(curl -s -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -X POST "http://localhost:${KIBANA_PORT}/api/saved_objects/dashboard" -d '
{
  "attributes": {
    "title": "Sample Dashboard"
  }
}' | jq -r '.id')

# Add visualization to the dashboard
echo "Adding visualization to the dashboard..."
curl -s -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -X POST "http://localhost:${KIBANA_PORT}/api/kibana/dashboards/import" -d '
{
  "objects": [
    {
      "type": "visualization",
      "id": "sample-visualization",
      "attributes": {
        "title": "Sample Visualization",
        "visState": "{\"title\":\"Sample Visualization\",\"type\":\"line\",\"params\":{\"type\":\"histogram\",\"grid\":{\"categoryLines\":false,\"valueAxis\":\"left\"},\"categoryAxes\":[{\"id\":\"CategoryAxis-1\",\"type\":\"category\",\"position\":\"bottom\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\"},\"labels\":{\"show\":true,\"filter\":false}},\"id\":\"CategoryAxis-2\",\"type\":\"category\",\"position\":\"left\",\"show\":false,\"style\":{},\"scale\":{\"type\":\"linear\"},\"labels\":{\"show\":false,\"filter\":false}},\"id\":\"CategoryAxis-3\",\"type\":\"category\",\"position\":\"right\",\"show\":false,\"style\":{},\"scale\":{\"type\":\"linear\"},\"labels\":{\"show\":false,\"filter\":false}}],\"valueAxes\":[{\"id\":\"ValueAxis-1\",\"type\":\"value\",\"position\":\"left\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\"},\"labels\":{\"show\":true},\"title\":{\"text\":\"Count\"}}],\"type\":\"line\",\"mode\":\"stacked\",\"orientation\":\"horizontal\"},\"title\":\"Sample Visualization\",\"data\":{\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}}}}"
      }
    }
  ],
  "version": "7.17.0"
}'

# Add visualization to the dashboard
curl -s -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -X POST "http://localhost:${KIBANA_PORT}/api/kibana/dashboards/add_panel" -d '
{
  "dashboardId": "'$DASHBOARD_ID'",
  "panel": {
    "type": "visualization",
    "id": "sample-visualization",
    "size_x": 6,
    "size_y": 3,
    "col": 1,
    "row": 1
  }
}'

echo "Kibana advanced testing completed successfully."