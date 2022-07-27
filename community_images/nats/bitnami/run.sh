#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh


INPUT_REGISTRY=docker.io
INPUT_ACCOUNT=bitnami
REPOSITORY=nats

if [ "$#" -ne 1 ]; then
    PUBLISH_IMAGE="no"
else
    PUBLISH_IMAGE=$1
fi

test()
{
    local IMAGE_REPOSITORY=$1
    local TAG=$2
    local NAMESPACE=$3
    local HELM_RELEASE="$REPOSITORY"-release
    echo "Testing $REPOSITORY"

    # upgrade helm
    helm repo update

    # Install helm
    with_backoff helm install "${HELM_RELEASE}" "${INPUT_ACCOUNT}"/"${REPOSITORY}" --namespace "${NAMESPACE}" --set image.tag="${TAG}" --set image.repository="${IMAGE_REPOSITORY}" -f "${SCRIPTPATH}"/overrides.yml
    report_pulls "${IMAGE_REPOSITORY}"

    # waiting for pod to be ready
    echo "waiting for pod to be ready"
    kubectl wait deployments "${HELM_RELEASE}" -n "${NAMESPACE}" --for=condition=Available=True --timeout=10m

    # get pod name
    POD_NAME=$(kubectl -n "${NAMESPACE}" get pods -l app.kubernetes.io/name="$REPOSITORY" -o jsonpath="{.items[0].metadata.name}")

    # copy common_commands.sh into container
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/../../common/tests/common_commands.sh "${POD_NAME}":/tmp/common_commands.sh

    # run command on cluster
    kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- /bin/bash -c "/tmp/common_commands.sh"

    NATS_USER=$(kubectl get secret --namespace "${NAMESPACE}" "${HELM_RELEASE}" -o jsonpath='{.data.*}' | base64 -d | grep -m 1 user | awk '{print $2}' | tr -d '"')
    NATS_PASS=$(kubectl get secret --namespace "${NAMESPACE}" "${HELM_RELEASE}" -o jsonpath='{.data.*}' | base64 -d | grep -m 1 password | awk '{print $2}' | tr -d '"')
    echo -e "Client credentials:\n\tUser: $NATS_USER\n\tPassword: $NATS_PASS"

    kubectl run nats-release-client --restart='Never' --env="NATS_USER=$NATS_USER" --env="NATS_PASS=$NATS_PASS" --image docker.io/bitnami/golang --namespace "${NAMESPACE}" --command -- sleep infinity
    # wait for nats client to come up
    kubectl wait pods nats-release-client -n "${NAMESPACE}" --for=condition=ready --timeout=10m
    echo "#!/bin/bash
    GO111MODULE=off go get github.com/nats-io/nats.go
    cd \"\$GOPATH\"/src/github.com/nats-io/nats.go/examples/nats-pub && go install && cd || exit
    cd \"\$GOPATH\"/src/github.com/nats-io/nats.go/examples/nats-echo && go install && cd || exit
    nats-echo -s nats://$NATS_USER:$NATS_PASS@${HELM_RELEASE}.${NAMESPACE}.svc.cluster.local:4222 SomeSubject &
    nats-pub -s nats://$NATS_USER:$NATS_PASS@${HELM_RELEASE}.${NAMESPACE}.svc.cluster.local:4222 -reply Hi SomeSubject 'Hi everyone'" > "$SCRIPTPATH"/commands.sh

    chmod +x "$SCRIPTPATH"/commands.sh
    POD_NAME="nats-release-client"
    kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/commands.sh "${POD_NAME}":/tmp/common_commands.sh

    kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- bash -c "/tmp/common_commands.sh"

    # delete the generated commands.sh
    rm "$SCRIPTPATH"/commands.sh

    # bring down helm install
    helm delete "${HELM_RELEASE}" --namespace "${NAMESPACE}"

    # delete the PVC associated
    kubectl -n "${NAMESPACE}" delete pvc --all

    # update image in docker-compose yml
    sed "s#@IMAGE#${IMAGE_REPOSITORY}:${TAG}#g" "${SCRIPTPATH}"/docker-compose.yml.base > "${SCRIPTPATH}"/docker-compose.yml

    # install docker container
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

declare -a BASE_TAG_ARRAY=("2.8.4-debian-11-r")

build_images "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${REPOSITORY}" test "${PUBLISH_IMAGE}" "${BASE_TAG_ARRAY[@]}"
