#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"

# PROJECT_NAME=$(jq -r '.project_name' < "$JSON_PARAMS")

#######################
## SERVICES & ROUTES ##
#######################
# Add a new service
curl -i -s -X POST http://localhost:8001/services \
  --data name=example_service \
  --data url='http://mockbin.org'
# Get services
curl -i -X GET --url http://localhost:8001/services

# Get example_service
curl -X GET http://localhost:8001/services/example_service

# Update a service
curl --request PATCH \
  --url localhost:8001/services/example_service \
  --data retries=6

# Create a route to the service
curl -i -X POST http://localhost:8001/services/example_service/routes \
  --data 'paths[]=/mock' \
  --data name=example_route
# Get the route
curl -X GET http://localhost:8001/services/example_service/routes/example_route
# Update route
curl --request PATCH \
  --url localhost:8001/services/example_service/routes/example_route \
  --data tags="tutorial"
# List routes
curl http://localhost:8001/routes

# Access application via the Kong Route on data plane (8000)
curl -X GET http://localhost:8000/mock
# Use Mockbib echo request
curl -X GET http://localhost:8000/mock/requests

## END SERVICES & ROUTES ##

###################
## RATE LIMITING ##
###################
# Enable rate limiting plugin
curl -i -X POST http://localhost:8001/plugins \
  --data name=rate-limiting \
  --data config.minute=5 \
  --data config.policy=local

# Validate  rate limiting
for _ in {1..6}; do curl -i localhost:8000/mock/request; echo; sleep 1; done

# Service level rate limiting
curl -X POST http://localhost:8001/services/example_service/plugins \
   --data "name=rate-limiting" \
   --data config.minute=4 \
   --data config.policy=local
# Route level rate limiting
curl -X POST http://localhost:8001/routes/example_route/plugins \
   --data "name=rate-limiting" \
   --data config.minute=3 \
   --data config.policy=local
# Consumer level rate limiting
curl -X POST http://localhost:8001/consumers/ \
  --data username=ddooley
curl -X POST http://localhost:8001/plugins \
   --data "name=rate-limiting" \
   --data "consumer.username=ddooley" \
   --data "config.second=2"

for _ in {1..3}; do curl -i http://localhost:8000/mock/request --data "consumer.username=ddooley"; echo; sleep 1; done

## END RATE LIMITING ##


###################
## PROXY CACHING ##
###################
# Enable proxy caching
curl -i -X POST http://localhost:8001/plugins \
  --data "name=proxy-cache" \
  --data "config.request_method=GET" \
  --data "config.response_code=200" \
  --data "config.content_type=application/json; charset=utf-8" \
  --data "config.cache_ttl=30" \
  --data "config.strategy=memory"

# Get a cache MISS, then a HIT
curl -i -X GET http://localhost:8000/mock/requests
curl -i -X GET http://localhost:8000/mock/requests

# Service level caching
curl -X POST http://localhost:8001/services/example_service/plugins \
   --data "name=proxy-cache" \
   --data "config.request_method=GET" \
   --data "config.response_code=200" \
   --data "config.content_type=application/json; charset=utf-8" \
   --data "config.cache_ttl=30" \
   --data "config.strategy=memory"

# Route level caching
curl -X POST http://localhost:8001/routes/example_route/plugins \
   --data "name=proxy-cache" \
   --data "config.request_method=GET" \
   --data "config.response_code=200" \
   --data "config.content_type=application/json; charset=utf-8" \
   --data "config.cache_ttl=30" \
   --data "config.strategy=memory"
   
# Consumer level caching
curl -X POST http://localhost:8001/consumers/ \
  --data username=vgupta

curl -X POST http://localhost:8001/consumers/vgupta/plugins \
   --data "name=proxy-cache" \
   --data "config.request_method=GET" \
   --data "config.response_code=200" \
   --data "config.content_type=application/json; charset=utf-8" \
   --data "config.cache_ttl=30" \
   --data "config.strategy=memory"
curl -i -X GET http://localhost:8000/mock/requests --data "consumer.username=vgupta"
curl -i -X GET http://localhost:8000/mock/requests --data "consumer.username=vgupta"

## END PROXY CACHING ##

##############
## KEY AUTH ##
##############
# Key Auth via Consumer
curl -i -X POST http://localhost:8001/consumers/ \
  --data username=ashish
curl -i -X POST http://localhost:8001/consumers/ashish/key-auth \
  --data key=top-secret-key
# Enable key authentication
curl -X POST http://localhost:8001/plugins/ \
    --data "name=key-auth"  \
    --data "config.key_names=apikey"
# Send an unauthenticated request
curl -i http://localhost:8000/mock/request
# Send wrong key
curl -i http://localhost:8000/mock/request \
  -H 'apikey:bad-key'
# Send valid key
curl -i http://localhost:8000/mock/request \
  -H 'apikey:top-secret-key'
# Service based key authentication
curl -X POST http://localhost:8001/services/example_service/plugins \
     --data name=key-auth
# Route based key authentication
curl -X POST http://localhost:8001/routes/example_route/plugins \
    --data name=key-auth
## END KEY AUTH ##

####################
## LOAD BALANCING ##
####################
# Create an upstream and targets
curl -X POST http://localhost:8001/upstreams \
  --data name=example_upstream
curl -X POST http://localhost:8001/upstreams/example_upstream/targets \
  --data target='mockbin.org:80'
curl -X POST http://localhost:8001/upstreams/example_upstream/targets \
  --data target='httpbin.org:80'
# Update the service to point to upstream
curl -X PATCH http://localhost:8001/services/example_service \
  --data host='example_upstream'
#Validate by hitting the route
curl -i http://localhost:8000/mock/request \
  -H 'apikey:top-secret-key'
## END LOAD BALANCING ##

