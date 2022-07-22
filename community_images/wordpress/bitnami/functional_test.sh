#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

HELM_RELEASE=rf-wordpress
NAMESPACE=$(get_namespace_string "${HELM_RELEASE}")
REPOSITORY=wordpress
IMAGE_REPOSITORY="$RAPIDFORT_ACCOUNT"/"$REPOSITORY"

k8s_test()
{
    # setup namespace
    setup_namespace "${NAMESPACE}"

    # install helm
    with_backoff helm install "${HELM_RELEASE}" bitnami/"$REPOSITORY" --set image.repository="$IMAGE_REPOSITORY" --set image.tag=latest --namespace "${NAMESPACE}"
    report_pulls "${IMAGE_REPOSITORY}"

    # wait for deployments
    kubectl wait deployments "${HELM_RELEASE}" -n "${NAMESPACE}" --for=condition=Available=true --timeout=10m

    # get the ip address of wordpress service
    WORDPRESS_IP=$(kubectl get nodes --namespace "${NAMESPACE}" -o jsonpath="{.items[0].status.addresses[0].address}")
    ports=$(kubectl get svc --namespace "${NAMESPACE}" -o go-template='{{range .items}}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}{{end}}')
    WORDPRESS_PORT=$(echo "$ports" | head -n 1)

    echo "wordpress IP is $WORDPRESS_IP"
    echo "wordpress port is $WORDPRESS_PORT"

    CHROME_POD="python-chromedriver"
    # delete the directory if present already
    rm -rf "${SCRIPTPATH}"/docker-python-chromedriver
    git clone https://github.com/joyzoursky/docker-python-chromedriver.git
    cd docker-python-chromedriver
    kubectl run "${CHROME_POD}" --restart='Never' --image joyzoursky/"${CHROME_POD}":latest --namespace "${NAMESPACE}" --command -- sleep infinity

    #docker run -w /usr/workspace -v "$(pwd)":/usr/workspace joyzoursky/"${CHROME_POD}":latest --namespace "${NAMESPACE}" --command -- sleep infinity

    kubectl wait pods "${CHROME_POD}" -n "${NAMESPACE}" --for=condition=ready --timeout=10m
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/docker-python-chromedriver "${CHROME_POD}":/usr/workspace

    echo "#!/bin/bash
    cd /usr/workspace
    pip install pytest
    pip install selenium
    pytest -s /tmp/wordpress_selenium_test.py --ip_address $WORDPRESS_IP --port $WORDPRESS_PORT" > "$SCRIPTPATH"/commands.sh
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/conftest.py "${CHROME_POD}":/tmp/conftest.py
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/wordpress_selenium_test.py "${CHROME_POD}":/tmp/wordpress_selenium_test.py
    chmod +x "$SCRIPTPATH"/commands.sh
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/commands.sh "${CHROME_POD}":/tmp/common_commands.sh

    kubectl -n "${NAMESPACE}" exec -i "${CHROME_POD}" -- bash -c "/tmp/common_commands.sh"
    # delete the generated commands.sh
    rm "$SCRIPTPATH"/commands.sh

    # delete the cloned directory
    rm -rf "${SCRIPTPATH}"/docker-python-chromedriver

    # log pods
    kubectl -n "${NAMESPACE}" get pods
    kubectl -n "${NAMESPACE}" get svc

    # delete cluster
    helm delete "${HELM_RELEASE}" --namespace "${NAMESPACE}"

    # delete pvc
    kubectl -n "${NAMESPACE}" delete pvc --all

    # clean up namespace
    cleanup_namespace "${NAMESPACE}"
}

docker_test()
{
    # create network
    docker network create -d bridge "${NAMESPACE}"

    docker run -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=yes \
     -e MARIADB_PASSWORD=password -e MARIADB_USER=bn_wordpress \
      -e MARIADB_DATABASE=bitnami_wordpress --network="${NAMESPACE}" \
       --name wordpressdb -d mariadb:latest

    # create docker container
    docker run --rm -d --network="${NAMESPACE}" \
        --name "${NAMESPACE}" -e WORDPRESS_DATABASE_HOST=wordpressdb \
         -e WORDPRESS_DATABASE_USER=bn_wordpress -e WORDPRESS_DATABASE_PASSWORD=password \
          -e WORDPRESS_DATABASE_NAME=bitnami_wordpress -e WORDPRESS_DATABASE_PORT_NUMBER=3306 \
           -e ALLOW_EMPTY_PASSWORD=yes "$IMAGE_REPOSITORY":latest
    report_pulls "${IMAGE_REPOSITORY}"

    # sleep for few seconds
    sleep 30

    # clean up docker container
    docker kill "${NAMESPACE}"

    # clean up the mariadb container
    docker kill wordpressdb

    # delete network
    docker network rm "${NAMESPACE}"
}

docker_compose_test()
{
    # update image in docker-compose yml
    sed "s#@IMAGE#$IMAGE_REPOSITORY#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install postgresql container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" up -d
    report_pulls "${IMAGE_REPOSITORY}"

    # sleep for 30 sec
    sleep 30

    # logs for tracking
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" logs

    # kill docker-compose setup container
    docker-compose -f "${SCRIPTPATH}"/docker-compose.yml -p "${NAMESPACE}" down

    # clean up docker file
    rm -rf "${SCRIPTPATH}"/docker-compose.yml
}

main()
{
    k8s_test
    #docker_test
    #docker_compose_test
}

main
