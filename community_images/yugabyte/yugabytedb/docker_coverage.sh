#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker coverage = $JSON"

SCRIPTPATH=$(jq -r '.image_script_dir' < "$JSON_PARAMS")
NETWORK_NAME=$(jq -r '.network_name' < "$JSON_PARAMS")
YB_CTR_NAME=$(jq -r '.container_details.yugabyte.name' < "$JSON_PARAMS")

# copy test.psql into container
docker cp "${SCRIPTPATH}"/../../common/tests/test.psql "${YB_CTR_NAME}":/tmp/test.psql

# run script
docker exec -i "${YB_CTR_NAME}" \
    -- /bin/bash -c "ysqlsh -h localhost -p 5433  --echo-queries -f /tmp/test.sql"
