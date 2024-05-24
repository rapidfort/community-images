#!/bin/bash

# Show the current version of Auditbeat installed
auditbeat version

# Create a new keystore for storing secure settings, automatically approving without prompt
auditbeat keystore create

# Add an entry (ES_PWD) to the keystore with the value provided via stdin ("admin"), forcing the operation to overwrite any existing entry with the same key
echo "admin" | auditbeat keystore add ES_PWD --stdin --force

# List all the keys stored in the keystore
auditbeat keystore list

# Remove the specified entry (ES_PWD) from the keystore
auditbeat keystore remove ES_PWD

# Export the current configuration to standard output in YAML format
auditbeat export config

# Export the Elasticsearch index template for the specified Elasticsearch version (8.13.4)
auditbeat export template --es.version 8.13.4

# Export a Kibana dashboard with the specified ID to a JSON file in the specified folder, redirecting the output to dashboard.json
auditbeat export dashboard --id="a7b35890-8baa-11e8-9676-ef67484126fb" --folder=/usr/share/auditbeat > dashboard.json || echo 0

# Display help information for the export subcommands
auditbeat help export

# Start Auditbeat in the foreground, with logs output to the console (stderr)
auditbeat -e

# Start Auditbeat in the foreground, similar to `auditbeat -e`, with logs output to the console (stderr)
auditbeat run -e

# Set up the Kibana dashboards for Auditbeat
auditbeat setup --dashboards

# Set up the index management settings in Elasticsearch for Auditbeat
auditbeat setup --index-management

# Test the configuration file for syntax errors and other issues
auditbeat test config

# Export the Index Lifecycle Management (ILM) policy
auditbeat export ilm-policy

# Export the Kibana index pattern for Auditbeat
auditbeat export index-pattern

# Test the output configuration by connecting to the configured output (e.g., Elasticsearch) using the specified configuration file (auditbeat.yml)
auditbeat test output -c auditbeat.yml
