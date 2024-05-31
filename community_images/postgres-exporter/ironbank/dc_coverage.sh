#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

PG_CONTAINER="postgres"

# Define the SQL queries
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

# Now lets check the logs received in postgres-exporter
curl http://localhost:9187/metrics
