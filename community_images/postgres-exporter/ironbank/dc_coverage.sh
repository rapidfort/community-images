#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PG_CONTAINER="postgres"

# Get the container ID of the postgres-exporter container
PG_EXP_CONTAINER_ID=$(docker ps -qf "name=postgres-exporter")

if [ -z "$PG_EXP_CONTAINER_ID" ]; then
  echo "postgres-exporter container is not running."
  exit 1
fi

# Get the dynamically assigned port for postgres-exporter
PG_EXP_PORT=$(docker port "$PG_EXP_CONTAINER_ID" 9187 | head -n 1 | awk -F: '{print $2}')

if [ -z "$PG_EXP_PORT" ]; then
  echo "Failed to retrieve the port for postgres-exporter. Ensure the service is running."
  exit 1
fi

# Defining SQL queries to exercise CRUD operations in postgresql
SQL_QUERIES="
CREATE TABLE IF NOT EXISTS test_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    age INT
);

INSERT INTO test_table (name, age) VALUES ('Alice', 30);
INSERT INTO test_table (name, age) VALUES ('Bob', 25);

SELECT * FROM test_table;

UPDATE test_table SET age = 31 WHERE name = 'Alice';
DELETE FROM test_table WHERE name = 'Bob';
"

# Exec into the PostgreSQL container and execute the SQL queries
docker exec -i "${PG_CONTAINER}" psql -U postgres -d mydatabase <<EOF
$SQL_QUERIES
EOF

echo "SQL queries executed successfully."

# checking corresponding logs received in postgres-exporter
curl http://localhost:"$PG_EXP_PORT"/metrics
