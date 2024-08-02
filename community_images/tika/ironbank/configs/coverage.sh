#!/bin/bash

set -e 
set -x

# Define the directory containing the test assets
cd /opt/tika/configs

# Define acceptable HTTP status codes
ACCEPTABLE_CODES="200 204"

# Function to execute a curl command and check the HTTP status
function test_curl_command {
    local curl_command="$1"

    # Execute the provided curl command and capture the HTTP status code
    local http_status
    http_status=$(eval "${curl_command} -o /dev/null -s -w \"%{http_code}\"")

    # Check if http_status is empty
    if [[ -z ${http_status} ]]; then
        echo "Error: No HTTP status received for '${curl_command}'"
        return 1
    # Check if the HTTP status code is in the list of acceptable codes
    elif [[ ! ${ACCEPTABLE_CODES} =~ ${http_status} ]]; then
        echo "Error: Received HTTP status ${http_status} for '${curl_command}'"
        return 1
    else
        echo "Request completed successfully with HTTP status ${http_status}"
        return 0
    fi
}

# All available endpoints
test_curl_command "curl http://localhost:9998/"

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

# PUT Tika Resource (specifying /text handler type after /tika)
test_curl_command "curl -T ledgers.xlsx http://localhost:9998/tika/text --header \"Accept: application/json\""

# PUT Tika Resource (Skip Embedded Files/Attachments)
test_curl_command "curl -T lorem_ipsum.docx http://localhost:9998/tika/text --header \"X-Tika-Skip-Embedded: true\""

# PUT Tika Resource (Multipart Support)
test_curl_command "curl -F upload=@ledgers.xlsx http://localhost:9998/tika/form/text"

# Detector Resource (RTF)
test_curl_command "curl -X PUT --data-binary @sample_rtf.rtf http://localhost:9998/detect/stream"

# Detector Resource (CSV file without filename hint)
test_curl_command "curl -X PUT --upload-file zipcodes.csv http://localhost:9998/detect/stream"

# Detector Resource (CSV file with filename hint)
test_curl_command "curl -X PUT -H \"Content-Disposition: attachment; filename=zipcodes.csv\" --upload-file zipcodes.csv http://localhost:9998/detect/stream"

# Language Resource (putting a text file with french in it)
test_curl_command "curl -X PUT --data-binary @foo_fr.txt http://localhost:9998/language/stream"

# Language Resource (PUT a string with English)
test_curl_command "curl -X PUT --data \"This is English!\" http://localhost:9998/language/string"

# Recursive Metadata and Content Resource (with default XML format for "X-TIKA:content")
test_curl_command "curl -T lorem_ipsum.docx http://localhost:9998/rmeta"

# Recursive Metadata and Content Resource (setting format for "X-TIKA:content" to text, html and no content)
test_curl_command "curl -T lorem_ipsum.docx http://localhost:9998/rmeta/text"
test_curl_command "curl -T lorem_ipsum.docx http://localhost:9998/rmeta/html"
test_curl_command "curl -T lorem_ipsum.docx http://localhost:9998/rmeta/ignore"

# Recursive Metadata and Content Resource (Multipart Support)
test_curl_command "curl -F upload=@lorem_ipsum.docx http://localhost:9998/rmeta/form"

# Recursive Metadata and Content Resource (skip embedded files/attachments)
test_curl_command "curl -T lorem_ipsum.docx http://localhost:9998/rmeta --header \"X-Tika-Skip-Embedded: true\""

# Recursive Metadata and Content Resource (specifying maxEmbeddedResources)
test_curl_command "curl -T lorem_ipsum.docx --header \"maxEmbeddedResources: 0\" http://localhost:9998/rmeta"

# Recursive Metadata and Content Resource (specifying write limit per handler)
test_curl_command "curl -T lorem_ipsum.docx --header \"writeLimit: 1000\" http://localhost:9998/rmeta"

# Unpack Resource (PUT zip file and get back met file zip)
test_curl_command "curl -X PUT --data-binary @foo.zip http://localhost:9998/unpack --header \"Content-type: application/zip\""

# Unpack Resource (Unpack Resource)
test_curl_command "curl -T lorem_ipsum.docx -H \"Accept: application/x-tar\" http://localhost:9998/unpack"

# Unpack Resource (PUT doc file and get back the content and metadata)
test_curl_command "curl -T lorem_ipsum.docx http://localhost:9998/unpack/all"

# Unpack Resource (PUT zip file and get back met file zip and bump max attachment size from default 100MB to custom 1GB)
test_curl_command "curl -X PUT --data-binary @foo.zip http://localhost:9998/unpack --header \"Content-type: application/zip\" --header \"unpackMaxBytes:  1073741824\""

# Defined mime types
test_curl_command "curl http://localhost:9998/mime-types"

# Available Detectors
test_curl_command "curl http://localhost:9998/detectors"

# Available Parsers
test_curl_command "curl http://localhost:9998/parsers"

# List all the available parsers, along with what mimetypes they support
test_curl_command "curl http://localhost:9998/parsers/details"

# Transfer-Layer Compression (tell tika-server  to compress the output of the parse) 
test_curl_command "curl -T GeoSPARQL.pdf -H \"Accept-Encoding: gzip\" http://localhost:9998/rmeta"