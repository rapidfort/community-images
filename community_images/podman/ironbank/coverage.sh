#!/bin/bash

set -e
set -x

# Pull Ubuntu image
podman pull docker.io/library/ubuntu:latest
# list images
podman images
# Run Ubuntu container and exit
(
    podman run -i docker.io/library/ubuntu:latest /bin/bash <<EOF
exit
EOF
) || echo 0
# Pull Nginx image
podman pull docker.io/library/nginx:latest
# Run Nginx container in detached mode
CONT_ID=$(podman run -d docker.io/library/nginx) || echo 0
# Exec into Nginx container and exit
(
    podman exec -i "$CONT_ID" /bin/bash <<EOF
exit
EOF
) || echo 0

# Stop and restart the Nginx container
podman stop "$CONT_ID" || echo 0
podman restart "$CONT_ID" || echo 0

# Podman info
podman info
# Podman pod operations
podman pod create new_pod

pod_id=$(podman pod ps -q)

podman pod stop "$pod_id"

podman pod restart "$pod_id" || echo 0

podman pod exists new_pod

# podman pod inspect $

podman pod logs new_pod

podman pod stop "$pod_id"

podman pod rm "$pod_id"

# Podman login and logout
podman login -u "test" -p "test123"
podman logout
# Create Redis container
podman create docker.io/library/redis:latest
# Podman mount
podman mount
# Create Fedora container and events
now=$(date --iso-8601=seconds)
podman create fedora
podman events --since "$now" --stream=false --no-trunc=false
# Search for 'yq' image
podman search yq
# Podman info with debug log level
podman info --log-level=debug
# podman help
podman help
podman unshare ls || echo 0
# podman stop $CONT_ID
# podman rm $CONT_ID
podman compose -f /tmp/node.yml up -d || echo 0
# List all volumes
podman volume ls
podman image ls
# Display history of changes in the specified image
podman history docker.io/library/nginx:latest
# Automatically update
podman auto-update
# Build an image using the specified Dockerfile and tag it as 'myimage'
podman build -t myimage -f Dockerfile .
# List all networks managed by Podman
podman network ls
# Tag the local image 
podman tag myimage docker.io/username/repository:tag
# testing push
podman push docker.io/username/repository:tag || echo 0
# removing
podman rmi myimage
# podman cp $CONT_ID:/etc/hostname ./hostname
# secrets
podman secret ls
podman system service
# System prune
podman system prune <<EOF
y
EOF