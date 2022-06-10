#!/bin/bash

set -x
set -e

# Add common commands here which should be present in all hardened images

sleep 1
cp --version
mkdir --version
chmod --version
ls --version
mv --version
rm --version
ln --version
rmdir --version
chgrp --version
chown --version
touch --version
cat --version
grep --version
sed --version
tar --version
sort --version
sleep 5 # sleep for few seconds to let profiles sync
