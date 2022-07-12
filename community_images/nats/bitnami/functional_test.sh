#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/helpers.sh

HELM_RELEASE=rf-nats
NAMESPACE=$(get_namespace_string "${HELM_RELEASE}")
REPOSITORY=nats
IMAGE_REPOSITORY=ankitrapidfort/"$REPOSITORY"

k8s_test()
{
    # setup namespace
    setup_namespace "${NAMESPACE}"

    # install helm
    with_backoff helm install "${HELM_RELEASE}" bitnami/"$REPOSITORY" --set image.repository="$IMAGE_REPOSITORY" --set image.tag=latest --namespace "${NAMESPACE}"
    report_pulls "${IMAGE_REPOSITORY}"

    # wait for pods
    kubectl wait pods "${HELM_RELEASE}"-0 -n "${NAMESPACE}" --for=condition=ready --timeout=10m


#NATS can be accessed via port 4222 on the following DNS name from within your cluster:

#   nats-release.nats-fe65cb5835.svc.cluster.local

#To get the authentication credentials, run:

NATS_USER=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath='{.data.*}' | base64 -d | grep -m 1 user | awk '{print $2}' | tr -d '"')
NATS_PASS=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath='{.data.*}' | base64 -d | grep -m 1 password | awk '{print $2}' | tr -d '"')
echo -e "Client credentials:\n\tUser: $NATS_USER\n\tPassword: $NATS_PASS"

#NATS monitoring service can be accessed via port 8222 on the following DNS name from within your cluster:

#    nats-release.nats-fe65cb5835.svc.cluster.local

#You can create a Golang pod to be used as a NATS client:

#rf-nats.rf-nats-abd05cb1d0.svc.cluster.local

kubectl run nats-release-client --restart='Never' --env="NATS_USER=$NATS_USER" --env="NATS_PASS=$NATS_PASS" --image docker.io/bitnami/golang --namespace "${NAMESPACE}" --command -- sleep infinity
kubectl wait pods nats-release-client -n "${NAMESPACE}" --for=condition=ready --timeout=10m
#kubectl exec --tty -i nats-release-client --namespace "${NAMESPACE}" -- bash
echo "GO111MODULE=off go get github.com/nats-io/nats.go
cd \$GOPATH/src/github.com/nats-io/nats.go/examples/nats-pub && go install && cd
cd \$GOPATH/src/github.com/nats-io/nats.go/examples/nats-echo && go install && cd
nats-echo -s nats://$NATS_USER:$NATS_PASS@${HELM_RELEASE}.${NAMESPACE}.svc.cluster.local:4222 SomeSubject &
nats-pub -s nats://$NATS_USER:$NATS_PASS@${HELM_RELEASE}.${NAMESPACE}.svc.cluster.local:4222 -reply Hi SomeSubject 'Hi everyone'" > $SCRIPTPATH/commands.sh

chmod +x $SCRIPTPATH/commands.sh
POD_NAME="nats-release-client"
kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/commands.sh "${POD_NAME}":/tmp/common_commands.sh

kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- bash -c "/tmp/common_commands.sh"





#kubectl run nats-release-client --restart='Never' --env="NATS_USER=$NATS_USER" --env="NATS_PASS=$NATS_PASS" --image docker.io/bitnami/golang --namespace "${NAMESPACE}" --command -- sleep infinity
#kubectl wait pods nats-release-client -n "${NAMESPACE}" --for=condition=ready --timeout=10m
#kubectl exec --tty -i nats-release-client --namespace "${NAMESPACE}" -- bash
#GO111MODULE=off go get github.com/nats-io/nats.go
#cd $GOPATH/src/github.com/nats-io/nats.go/examples/nats-pub && go install && cd
#cd $GOPATH/src/github.com/nats-io/nats.go/examples/nats-echo && go install && cd
#nats-echo -s nats://$NATS_USER:$NATS_PASS@nats-release.nats-${NAMESPACE}.svc.cluster.local:4222 SomeSubject
#nats-pub -s nats://$NATS_USER:$NATS_PASS@nats-release.nats-${NAMESPACE}.svc.cluster.local:4222 -reply Hi SomeSubject "Hi everyone"



    # log pods
    kubectl -n "${NAMESPACE}" get pods
    kubectl -n "${NAMESPACE}" get svc

    # delte cluster
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

    # create docker container
    docker run --rm -d --network="${NAMESPACE}" \
        --name "${NAMESPACE}" "$IMAGE_REPOSITORY":latest
    report_pulls "${IMAGE_REPOSITORY}"

    # sleep for few seconds
    sleep 30

    # clean up docker container
    docker kill "${NAMESPACE}"

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
