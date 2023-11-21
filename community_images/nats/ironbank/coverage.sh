#!/bin/bash

set -e
set -x

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function test_nats() {
   local NAMESPACE=$1
   local RELEASE_NAME=$2

   NATS_SERVER=$(kubectl get pod "${RELEASE_NAME}" -n "${NAMESPACE}" --template '{{.status.podIP}}')

   # NATS_USER=$(kubectl get secret --namespace "${NAMESPACE}" "${RELEASE_NAME}" -o jsonpath='{.data.*}' | base64 -d | grep -m 1 user | awk '{print $2}' | tr -d '"')
   # NATS_PASS=$(kubectl get secret --namespace "${NAMESPACE}" "${RELEASE_NAME}" -o jsonpath='{.data.*}' | base64 -d | grep -m 1 password | awk '{print $2}' | tr -d '"')
   NATS_USER=ruser
   NATS_PASS=T0pS3cr3t

   echo -e "Client credentials:\n\tUser: $NATS_USER\n\tPassword: $NATS_PASS"

   # clean up the pod with name nats-release-client first if present already
   kubectl delete pod nats-release-client --namespace "${NAMESPACE}" --ignore-not-found=true
   kubectl run nats-release-client --restart='Never' --env="NATS_USER=$NATS_USER" --env="NATS_PASS=$NATS_PASS" --image docker.io/bitnami/golang --namespace "${NAMESPACE}" --command -- sleep infinity
    # wait for nats client to come up
   kubectl wait pods nats-release-client -n "${NAMESPACE}" --for=condition=ready --timeout=10m
   echo "#!/bin/bash
   set -x
   set -e
   GO111MODULE=off go get github.com/nats-io/nats.go
   go env -w GOPROXY=http://${NATS_SERVER}:8222,direct
   go get golang.org/x/crypto/blake2b@v0.14.0
   go mod tidy
   cd \"\$GOPATH\"/src/github.com/nats-io/nats.go/examples/nats-pub && go install && cd || exit
   cd \"\$GOPATH\"/src/github.com/nats-io/nats.go/examples/nats-echo && go install && cd || exit
   nats-echo -s nats://$NATS_USER:$NATS_PASS@${NATS_SERVER}:4222 SomeSubject &
   nats-pub -s nats://$NATS_USER:$NATS_PASS@${NATS_SERVER}:4222 -reply Hi SomeSubject 'Hi everyone'" > "$SCRIPTPATH"/commands.sh
   # nats-echo -s nats://$NATS_USER:$NATS_PASS@${RELEASE_NAME}.${NAMESPACE}.svc.cluster.local:4222 SomeSubject &
   # nats-pub -s nats://$NATS_USER:$NATS_PASS@${RELEASE_NAME}.${NAMESPACE}.svc.cluster.local:4222 -reply Hi SomeSubject 'Hi everyone'" > "$SCRIPTPATH"/commands.sh

   chmod +x "$SCRIPTPATH"/commands.sh
   POD_NAME="nats-release-client"
   kubectl -n "${NAMESPACE}" cp "${SCRIPTPATH}"/commands.sh "${POD_NAME}":/tmp/common_commands.sh

   kubectl -n "${NAMESPACE}" exec -i "${POD_NAME}" -- bash -c "/tmp/common_commands.sh"

   # delete the generated commands.sh
   rm "$SCRIPTPATH"/commands.sh
}
