#!/bin/bash

set -e 
set -x

# Define the directory containing the test assets
cd /opt/tika/docker_coverage_assets

# Define acceptable HTTP status codes
ACCEPTABLE_CODES="200 204"

# Function to execute a curl command and check the HTTP status
function test_curl_command {
    local curl_command="$1"

    # Execute the provided curl command and capture the HTTP status code
    local http_status=$(eval "${curl_command} -o /dev/null -s -w \"%{http_code}\"")

    # Check if the HTTP status code is in the list of acceptable codes
    if [[ ! ${ACCEPTABLE_CODES} =~ ${http_status} ]]; then
        echo "Error: Received HTTP status ${http_status} for ${curl_command}"
        return 1
    else
        echo "Request completed successfully with HTTP status ${http_status}"
        return 0
    fi
}

test_curl_command "curl 127.0.0.1:9998"

# Metadata Resource 1
 test_curl_command "curl -X PUT --data-ascii @zipcodes.csv http://localhost:9998/meta --header 'Content-Type: text/csv'"

# Metadata Resource 2
test_curl_command "curl -T zipcodes.csv http://localhost:9998/meta"

# Metadata Resource 3 (Get specific metadata key's value)
test_curl_command "curl -T lorem_ipsum.docx http://localhost:9998/meta/Content-Type"

# Metadata Resource 4 (Multipart Support)
test_curl_command "curl -F upload=@zipcodes.csv http://localhost:9998/meta/form"

# GET Tika Resource
test_curl_command "curl -X GET http://localhost:9998/tika"

# PUT Tika Resource 
test_curl_command "curl -X PUT --data-binary @GeoSPARQL.pdf http://localhost:9998/tika --header \"Content-type: application/pdf\""
test_curl_command "curl -T ledgers.xlsx http://localhost:9998/tika"

# PUT Tika Resource (specifying /text handler type after /tika)
test_curl_command "curl -T ledgers.xlsx http://localhost:9998/tika/text --header \"Accept: application/json\""

# PUT Tika Resource (Skip Embedded Files/Attachments)
test_curl_command "curl -T test_recursive_embedded.docx http://localhost:9998/tika --header \"Accept: text/plain\" --header \"X-Tika-Skip-Embedded: true\""

# # PUT Tika Resource (Multipart Support)
test_curl_command "curl -F upload=@ledgers.xlsx http://localhost:9998/tika/form"

# Detector Resource (RTF)
test_curl_command "curl -X PUT --data-binary @sample_rtf.rtf http://localhost:9998/detect/stream"

# Detector Resource (CSV file without filename hint)
test_curl_command "curl -X PUT --upload-file zipcodes.csv http://localhost:9998/detect/stream"

# Detector Resource (CSV file with filename hint)
test_curl_command "curl -X PUT -H \"Content-Disposition: attachment; filename=zipcodes.csv\" --upload-file zipcodes.csv http://localhost:9998/detect/stream"

# Language Resource (putting a text file with french in it)
test_curl_command "curl -X PUT --data-binary @foo_fr.txt http://localhost:9998/language/stream"

# Language Resource (PUT a string with English)
test_curl_command "curl -X PUT --data "This is English!" http://localhost:9998/language/string"

# Recursive Metadata and Content Resource 
