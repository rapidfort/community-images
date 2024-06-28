#!/bin/bash

set -x
set -e

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/basic/templates/k8srequiredlabels_template.yaml

kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/basic/constraints/all_ns_must_have_gatekeeper.yaml

kubectl get constraints

kubectl apply -f - <<EOF
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: ns-must-have-gk
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Namespace"]
  parameters:
    labels: ["gatekeeper"]
EOF

kubectl apply -f - <<EOF
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: require-labels
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    labels: ["env", "app"]
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: gatekeeper-audit
  namespace: "${NAMESPACE}"
data:
  auditInterval: "60"
EOF

kubectl get constraint

sleep 60

kubectl get K8sRequiredLabels.constraints.gatekeeper.sh require-labels -o yaml

kubectl apply -f - <<EOF
apiVersion: syncset.gatekeeper.sh/v1alpha1
kind: SyncSet
metadata:
  name: syncset-1
spec:
  gvks:
    - group: ""
      version: "v1"
      kind: "Namespace"
    - group: ""
      version: "v1"
      kind: "Pod"
EOF

kubectl delete syncset.syncset.gatekeeper.sh syncset-1

kubectl apply -f - <<EOF
apiVersion: config.gatekeeper.sh/v1alpha1
kind: Config
metadata:
  name: config
  namespace: "${NAMESPACE}"
spec:
  sync:
    syncOnly:
      - group: ""
        version: "v1"
        kind: "Namespace"
      - group: ""
        version: "v1"
        kind: "Pod"
EOF

kubectl get config.config.gatekeeper.sh/config -n "${NAMESPACE}" -o yaml

kubectl -n "${NAMESPACE}" patch deployment gatekeeper-controller-manager \
--type=json -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--log-level=debug"}]'

kubectl apply -f - <<EOF
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8sdenynamespace
spec:
  crd:
    spec:
      names:
        kind: K8sDenyNamespace
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8sdenynamespace

        violation[{"msg": msg}] {
          msg := sprintf("Namespace creation is denied: %v", [input.review])
        }
EOF

# kubectl -n "${NAMESPACE}" logs -l control-plane=controller-manager

kubectl apply -f "${SCRIPTPATH}"/pod-security-policy/allow_privileged_escalation.yml

kubectl apply -f "${SCRIPTPATH}"/pod-security-policy/capabilities.yml

kubectl apply -f "${SCRIPTPATH}"/pod-security-policy/read_only_root_filesystem.yml

kubectl apply -f "${SCRIPTPATH}"/pod-security-policy/seccomp.yml

kubectl apply -f "${SCRIPTPATH}"/pod-security-policy/selinux.yml

kubectl apply -f "${SCRIPTPATH}"/pod-security-policy/users.yml

kubectl delete -f "${SCRIPTPATH}"/pod-security-policy/allow_privileged_escalation.yml

kubectl delete -f "${SCRIPTPATH}"/pod-security-policy/capabilities.yml

kubectl delete -f "${SCRIPTPATH}"/pod-security-policy/read_only_root_filesystem.yml

kubectl delete -f "${SCRIPTPATH}"/pod-security-policy/seccomp.yml

kubectl delete -f "${SCRIPTPATH}"/pod-security-policy/selinux.yml

kubectl delete -f "${SCRIPTPATH}"/pod-security-policy/users.yml

kubectl delete constrainttemplate k8sdenynamespace
 
kubectl delete constraint require-labels ns-must-have-gk || echo 0

kubectl delete configmap gatekeeper-audit -n "${NAMESPACE}"

kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/basic/constraints/all_ns_must_have_gatekeeper.yaml || echo 0

kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/basic/templates/k8srequiredlabels_template.yaml || echo 0

kubectl delete crd -l gatekeeper.sh/system=yes