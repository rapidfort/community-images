#!/bin/bash

# Display the version of Velero installed
velero version

# Create a schedule named "schedule1" to run daily at 2 AM, storing backups in the "default" location, including only the "default" namespace, with a time-to-live (TTL) of 72 hours
velero schedule create schedule1 --schedule="0 2 * * *" --storage-location=default --include-namespaces=default --ttl=72h

# Delete the schedule named "schedule1" and confirm the deletion
velero schedule delete schedule1 --confirm

# Create a backup named "backup1" including only the "default" namespace, storing it in the "default" storage location, with a TTL of 72 hours
velero backup create backup1 --include-namespaces default --storage-location default --ttl 72h

# Display the current backup storage locations configured in Velero
velero backup-location get

# Create a backup named "backup2" with the default settings (all namespaces included, default storage location, no TTL specified)
velero backup create backup2

# Display the current backup repositories configured in Velero
velero repo get

# Output shell completion code for bash
velero completion bash

# Create a volume snapshot location named "vsl" using AWS as the provider and setting the region to "us-east-2"
velero snapshot-location create vsl --provider aws --config region=us-east-2

# Create a backup storage location named "bsl" using AWS as the provider, specifying the bucket "velero-migration-demo", setting the region to "us-east-2", and making it read-only
velero backup-location create bsl --provider aws --bucket velero-migration-demo --config region=us-east-2 --access-mode=ReadOnly

# Create a restore from the backup named "backup1"
velero restore create restore1 --from-backup backup1

velero restore delete restore1 --confirm

# Install Velero with specific settings: using node agent, enabling privileged node agent, using AWS as the provider, specifying the bucket "bucket1", not providing a secret, and using the AWS plugin
velero install --use-node-agent --privileged-node-agent --provider aws --bucket bucket1 --no-secret --plugins velero/velero-plugin-for-aws

# Describe the details of the backup named "backup1"
velero describe backup backup1
