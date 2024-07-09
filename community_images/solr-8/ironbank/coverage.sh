#!/bin/bash

set -e  
set -x  

#############
## Solr Standalone Mode Operations
#############

# Display Solr version
solr -version

# Start Solr server
solr start -p 8984 | echo 0 
sleep 4

# Restart Solr server
solr restart -p 8984 | echo 0 
sleep 4

# Check Solr status
solr status

# Create a new Core
# A core is a collection of index data and a configuration directory
solr create_core -c new_core

# Create a Core using Create Command
solr create -c new_core2 

# Delete cores
solr delete -c new_core
solr delete -c new_core2

# Assert Solr configuration
solr assert -C http://localhost:8983/solr

# Stop Solr server
solr stop -p 8984

#############
## Solr SolrCloud Mode Operations
## Distributed mode of Solr where multiple Solr servers are connected to a ZooKeeper ensemble
#############

# Start Solr in SolrCloud mode
solr start -cloud -p 8984 -z zookeeper:2181 | echo 0
sleep 10

# Create a new collection in SolrCloud
# A collection is a group of distributed cores
solr create_collection -p 8984 -c new_collection -shards 2 -replicationFactor 2

# Create a collection using Create Command in SolrCloud
solr create -p 8984 -c new_collection2 -shards 2 -replicationFactor 2

# Perform healthcheck on a collection
solr healthcheck -c new_collection -z zookeeper:2181

# Delete collections
solr delete -p 8984 -c new_collection
solr delete -p 8984 -c new_collection2

#############
## Miscellaneous Commands
#############

# Display help information
solr -help

# Perform operations affecting ZooKeeper. These operations are for SolrCloud mode only
solr zk ls / -z zookeeper:2181

# Manage Solr configuration files
solr create -c mycollection -p 8984
solr config -c mycollection -p 8984 -action set-user-property -property update.autoCreateFields -value false

# Export data from a Solr collection to a file
solr export mycollection -query "*:*" -out /tmp/mycollection.json -url http://localhost:8984/solr/mycollection

# Manage Solr packages
solr package list-installed

# Manage Solr autoscaling policies
solr autoscaling -stats -zkHost zookeeper:2181

# Access Solr API endpoints
solr api -get "http://localhost:8984/solr/mycollection/select?q=*:*"
# Access Solr SQL API endpoint using curl
curl "http://localhost:8984/solr/mycollection/sql?stmt=select+*+from+mycollection+limit+100"

# Manage Solr authorization settings
solr auth enable -credentials user:pass -z zookeeper:2181

# Stop all Solr instances
solr stop -all
