#!/bin/bash

set -e
set -x

# Get template from gitlab-workhorse proxy
curl http://localhost:8181

# find the contents of file1.txt depending on ARCHIVE_PATH
gitlab-zip-cat

# required GL_IMAGE_WIDTH env var
gitlab-resize-image || true

# extract metadata from the archive
gitlab-zip-metadata test.zip > /dev/null

# metadata from stripped jpg image
exiftool test_image.jpg

# templating test
gomplate -f template.tpl

echo "All tests completed successfully!"
