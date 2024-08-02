#!/bin/bash


# Define configuration file path and new database address
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )" || exit 1
config_file="${SCRIPTPATH}/osee.postgresql.json"
new_address="jdbc:postgresql://${POSTGRESQL_CONTAINER}:5432/osee"

# Update the OSEE.POSTGRES.JSON file with the new PostgreSQL Container Address
tmp_file=$(mktemp) 
jq --arg value "$new_address" '.config[0]."jdbc.service"[0]."jdbc.client.db.uri" = $value' "$config_file" > "$tmp_file" && mv "$tmp_file" "$config_file"

# Set appropriate permissions for the configuration file
chmod 777 "$config_file"

echo "Updated jdbc.client.db.uri to $new_address in $config_file"
