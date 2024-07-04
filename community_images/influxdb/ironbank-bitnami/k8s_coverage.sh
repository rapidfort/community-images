#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
RELEASE_NAME=$(jq -r '.release_name' < "$JSON_PARAMS")

# get pod name
POD_NAME="${RELEASE_NAME}"

# get influxdb token
INFLUXDB_TOKEN="mytokenislongtoo"

echo -e "#datatype measurement,tag,double,dateTime:RFC3339\nm,host,used_percent,time\nmem,host1,64.23,2020-01-01T00:00:00Z\nmem,host2,72.01,2020-01-01T00:00:00Z\nmem,host1,62.61,2020-01-01T00:00:10Z\nmem,host2,72.98,2020-01-01T00:00:10Z\nmem,host1,63.40,2020-01-01T00:00:20Z\nmem,host2,73.77,2020-01-01T00:00:20Z"
echo -e "from(bucket: \"primary\")\n    |> range(start: -10y)"

# copy tests into container
kubectl exec -t "${POD_NAME}" -n "${NAMESPACE}" -- bash -c 'echo -e "from(bucket: \"primary\")\n    |> range(start: -10y)" > /tmp/query.flux'
kubectl exec -t "${POD_NAME}" -n "${NAMESPACE}" -- bash -c 'echo -e "#datatype measurement,tag,double,dateTime:RFC3339\nm,host,used_percent,time\nmem,host1,64.23,2020-01-01T00:00:00Z\nmem,host2,72.01,2020-01-01T00:00:00Z\nmem,host1,62.61,2020-01-01T00:00:10Z\nmem,host2,72.98,2020-01-01T00:00:10Z\nmem,host1,63.40,2020-01-01T00:00:20Z\nmem,host2,73.77,2020-01-01T00:00:20Z" > /tmp/example.csv'

sleep 20

# write data to db
kubectl -n "${NAMESPACE}" exec -it "${POD_NAME}" -- /bin/bash -c "influx write -t $INFLUXDB_TOKEN -b primary --org-id primary -f /tmp/example.csv"

sleep 10

# run query on db
kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- influx query -t "$INFLUXDB_TOKEN" --org primary -f /tmp/query.flux

