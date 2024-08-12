#!/bin/bash

set -e
set -x

# Test cfssl and cfssljson versions
cfssl version
cfssljson -version

# Verify CA certificate
cfssl certinfo -cert /output/ca.pem

# Verify wildcard certificate
cfssl certinfo -cert /output/wildcard.pem

# Test certificate bundling
cfssl bundle -cert /output/wildcard.pem -ca-bundle /output/ca.pem > /output/bundle.json

# Extract the PEM bundle from the JSON output and save it
awk -F'"' '/"bundle"/ {gsub(/\\n/,"\n"); print $4}' /output/bundle.json > /output/bundle.pem

# Verify the bundle
cfssl certinfo -cert /output/bundle.pem

# Start cfssl server
cfssl serve -address=0.0.0.0 -port=8888 -ca=/output/ca.pem -ca-key=/output/ca-key.pem -config=/output/ca-config.json &
CFSSL_SERVER_PID=$!

# Ensure server is stopped on exit
trap 'kill "$CFSSL_SERVER_PID"' EXIT

# Wait for server to start
sleep 5

# Test cfssl server
curl -s -X POST -H "Content-Type: application/json" -d @/output/wildcard-csr.json http://localhost:8888/api/v1/cfssl/sign > /output/signed_cert.json

# Extract the certificate and key from the signed_cert.json
cfssljson -f /output/signed_cert.json -bare /output/signed

# Create a file with a sample revoked serial number
echo "1234" > /output/revoked_serials.txt

# Test certificate revocation list generation
cfssl gencrl /output/revoked_serials.txt /output/ca.pem /output/ca-key.pem 86400 > /output/crl.der

# Verify CRL generation
test -f "/output/crl.der"

echo "All tests completed successfully!"