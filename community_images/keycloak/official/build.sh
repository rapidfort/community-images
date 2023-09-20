#!/bin/bash -ex

MAJOR=1
MINOR=1
REVISION=${MAJOR}.${MINOR}.`git rev-list --count HEAD`
if [ -f version ]; then
    VERSION=`cat version`
    REVISION=$(echo $VERSION|tr -d '\n')
fi

docker-compose -f keycloak-postgres.yml down

pushd spi/rapidfort-signup
    mvn package -DVERSION=$REVISION
popd

rm -f spi/deployments/*.jar
cp spi/rapidfort-signup/target/rapidfort-signup-${REVISION}.jar spi/deployments/rapidfort-signup-${REVISION}.jar

docker-compose -f keycloak-postgres.yml up