#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

function test_azure_sql() {
    NAMESPACE=$1
    ODBC_CONTAINER_NAME="python_odbc_container"
    docker run --name "${ODBC_CONTAINER_NAME}" --net "${NAMESPACE}" -d python

    echo "#!/bin/bash
    # installation instructions as per https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15&tabs=debian18-install%2Calpine17-install%2Cdebian8-install%2Credhat7-13-install%2Crhel7-offline#microsoft-odbc-driver-17-for-sql-server
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list
    apt-get update
    # install the MS ODBC driver
    ACCEPT_EULA=Y apt-get install -y msodbcsql18
    apt-get install -y unixodbc-dev
    # install python odbc binding
    pip3 install pyodbc" > "$SCRIPTPATH"/setup_odbc_container.sh
    chmod +x "$SCRIPTPATH"/setup_odbc_container.sh
    docker cp "${SCRIPTPATH}"/setup_odbc_container.sh "${ODBC_CONTAINER_NAME}":/tmp/setup_odbc_container.sh
    docker exec -i "${ODBC_CONTAINER_NAME}" bash -c /tmp/setup_odbc_container.sh
    docker cp "${SCRIPTPATH}"/test_azure_sql.py "${ODBC_CONTAINER_NAME}":/tmp/test_azure_sql.py
    docker exec -i "${ODBC_CONTAINER_NAME}" python /tmp/test_azure_sql.py
}