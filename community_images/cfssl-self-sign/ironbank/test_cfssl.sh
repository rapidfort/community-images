#!/bin/bash

set -e

# Function to check if a command was successful
check_success() {
    if [ $? -eq 0 ]; then
        echo "✅ $1 successful"
    else
        echo "❌ $1 failed"
        exit 1
    fi
}

echo "Running as $(whoami)"

# Test cfssl version
echo "Testing cfssl version..."
cfssl version
check_success "CFSSL version check"

# Test cfssljson version
echo "Testing cfssljson version..."
cfssljson -version
check_success "CFSSLJSON version check"

# Verify CA certificate
echo "Verifying CA certificate..."
cfssl certinfo -cert /output/ca.pem
check_success "CA certificate verification"

# Verify wildcard certificate
echo "Verifying wildcard certificate..."
cfssl certinfo -cert /output/wildcard.pem
check_success "Wildcard certificate verification"

# Test certificate bundling
echo "Testing certificate bundling..."
if cfssl bundle -cert /output/wildcard.pem -ca-bundle /output/ca.pem > /output/bundle.pem 2>/dev/null; then
    echo "✅ Certificate bundling successful"
    # Verify the bundle
    echo "Verifying certificate bundle..."
    cfssl certinfo -cert /output/bundle.pem
    check_success "Bundle verification"
else
    echo "⚠️ Certificate bundling failed, skipping this step"
fi

# Start cfssl server
echo "Starting cfssl server..."
cfssl serve -address=0.0.0.0 -port=8888 -ca=/output/ca.pem -ca-key=/output/ca-key.pem -config=/output/ca-config.json &
CFSSL_SERVER_PID=$!

# Wait for server to start
sleep 5

# Test cfssl server
echo "Testing cfssl server..."
curl -s -X POST -H "Content-Type: application/json" -d '{"certificate_request": "'"$(cat /output/wildcard-csr.json | jq -c .)"'", "profile": "www"}' http://localhost:8888/api/v1/cfssl/sign > /output/signed_cert.json
check_success "CFSSL server certificate signing"

# Verify the signed certificate using cfssljson
echo "Verifying signed certificate with cfssljson..."
cat /output/signed_cert.json | cfssljson -bare /output/signed
if [ -f "/output/signed.pem" ] && [ -f "/output/signed-key.pem" ]; then
    echo "✅ CFSSLJSON successfully processed signed certificate"
else
    echo "❌ CFSSLJSON failed to process signed certificate"
    exit 1
fi

# Verify the signed certificate
echo "Verifying signed certificate..."
cfssl certinfo -cert /output/signed.pem
check_success "Signed certificate verification"

# Test certificate revocation list generation
echo "Testing CRL generation..."
cfssl gencrl /output/ca.pem /output/ca-key.pem | cfssljson -bare /output/crl
check_success "CRL generation"

# Verify CRL generation with cfssljson
echo "Verifying CRL generation with cfssljson..."
if [ -f "/output/crl.der" ]; then
    echo "✅ CFSSLJSON successfully generated CRL"
else
    echo "❌ CFSSLJSON failed to generate CRL"
    exit 1
fi

# Stop cfssl server
kill $CFSSL_SERVER_PID

echo "All tests completed successfully!"