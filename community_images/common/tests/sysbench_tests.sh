
run_sys_bench_test()
{
    MYSQL_HOST=$1
    MYSQL_ROOT_PASSWORD=$2
    DOCKER_NETWORK=$3
    USE_MYSQL_NATIVE_PASSWORD_PLUGIN=$4

    # create schema
    docker run --rm -i --network=$DOCKER_NETWORK --name mysql-client rapidfort/mysql:latest \
        -- mysql -h ${MYSQL_HOST} -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE SCHEMA sbtest;"

    # create user
    CREATE_USER_STR=
    if [[ "${USE_MYSQL_NATIVE_PASSWORD_PLUGIN}" = "yes" ]]; then
        CREATE_USER_STR="CREATE USER sbtest@'%' IDENTIFIED WITH mysql_native_password BY 'password';"
    else
        CREATE_USER_STR="CREATE USER sbtest@'%' IDENTIFIED BY 'password';"
    fi

    docker run --rm -i --network=$DOCKER_NETWORK --name mysql-client rapidfort/mysql:latest \
        -- mysql -h ${MYSQL_HOST} -uroot -p"$MYSQL_ROOT_PASSWORD" -e ${CREATE_USER_STR}

    # grant privelege
    docker run --rm -i --network=$DOCKER_NETWORK --name mysql-client rapidfort/mysql:latest \
        -- mysql -h ${MYSQL_HOST} -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON sbtest.* to sbtest@'%';"

    # run sys bench prepare
    docker run --rm \
        --rm=true \
        --name=sb-prepare \
        --network=$DOCKER_NETWORK \
        severalnines/sysbench \
        sysbench \
        --db-driver=mysql \
        --oltp-table-size=100000 \
        --oltp-tables-count=24 \
        --threads=1 \
        --mysql-host=${MYSQL_HOST} \
        --mysql-port=3306 \
        --mysql-user=sbtest \
        --mysql-password=password \
        /usr/share/sysbench/tests/include/oltp_legacy/parallel_prepare.lua \
        run

    # run sys bench test
    docker run --rm \
        --name=sb-run \
        --network=$DOCKER_NETWORK \
        severalnines/sysbench \
        sysbench \
        --db-driver=mysql \
        --report-interval=2 \
        --mysql-table-engine=innodb \
        --oltp-table-size=100000 \
        --oltp-tables-count=24 \
        --threads=64 \
        --time=30 \
        --mysql-host=${MYSQL_HOST} \
        --mysql-port=3306 \
        --mysql-user=sbtest \
        --mysql-password=password \
        /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
        run
}