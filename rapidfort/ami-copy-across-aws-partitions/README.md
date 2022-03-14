# I.
### Source AWS Partition setup
```
#. Create S3 bucket on source AWS partition e.g. s3://rapidfort-transit
#. Assign aws-policy.json & generate AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY
#. Update .env file e.g.

AWS_REGION_COMMERCIAL=us-east-1
AWS_ACCESS_KEY_ID_COMMERCIAL=AKI******************
AWS_SECRET_ACCESS_KEY_COMMERCIAL=M******************
S3_BUCKET_COMMERCIAL=rapidfort-transit
```

# II.
### Target AWS Partition setup
```
#. Create S3 bucket on target AWS partition e.g. s3://rapidfort-transit-gov
#. Assign aws-gov-policy.json & generate AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY
#. Update .env file e.g.

AWS_REGION_GOV=us-gov-east-1
AWS_ACCESS_KEY_ID_GOV=AK******************
AWS_SECRET_ACCESS_KEY_GOV=G******************
S3_BUCKET_GOV=rapidfort-transit-gov
```