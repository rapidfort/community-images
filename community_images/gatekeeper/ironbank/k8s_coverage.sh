#!/bin/bash

# Enable debugging and exit on error
set -x
set -e

# Get the script path
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Read JSON parameters from the first argument
JSON_PARAMS="$1"

# Read the JSON content
JSON=$(cat "$JSON_PARAMS")

echo "Json params for k8s coverage = $JSON"

# Extract the namespace name from the JSON parameters
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")

# Apply Gatekeeper templates and constraints
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/basic/templates/k8srequiredlabels_template.yaml
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/basic/constraints/all_ns_must_have_gatekeeper.yaml

# List current constraints
kubectl get constraints

# Apply namespace constraint template
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

# Apply pod constraint template
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

# Create a ConfigMap for gatekeeper audit with specified namespace
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: gatekeeper-audit
  namespace: "${NAMESPACE}"
data:
  auditInterval: "60"
EOF

# List current constraints again
kubectl get constraint

# Wait for the audit to complete
sleep 60

# Retrieve the details of the pod label constraint
kubectl get K8sRequiredLabels.constraints.gatekeeper.sh require-labels -o yaml

# Apply SyncSet for namespace and pod resources
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

# Delete the SyncSet
kubectl delete syncset.syncset.gatekeeper.sh syncset-1

# Apply configuration for gatekeeper sync with specified namespace
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

# Retrieve the gatekeeper configuration details
kubectl get config.config.gatekeeper.sh/config -n "${NAMESPACE}" -o yaml

# Patch the gatekeeper controller manager to enable debug logging
kubectl -n "${NAMESPACE}" patch deployment gatekeeper-controller-manager \
--type=json -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--log-level=debug"}]'

# Apply a custom constraint template to deny namespace creation
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

# Apply various pod security policies
kubectl apply -f "${SCRIPTPATH}"/pod-security-policy/allow_privileged_escalation.yml
kubectl apply -f "${SCRIPTPATH}"/pod-security-policy/capabilities.yml
kubectl apply -f "${SCRIPTPATH}"/pod-security-policy/read_only_root_filesystem.yml
kubectl apply -f "${SCRIPTPATH}"/pod-security-policy/seccomp.yml
kubectl apply -f "${SCRIPTPATH}"/pod-security-policy/selinux.yml
kubectl apply -f "${SCRIPTPATH}"/pod-security-policy/users.yml

# Clean up the applied pod security policies
kubectl delete -f "${SCRIPTPATH}"/pod-security-policy/allow_privileged_escalation.yml
kubectl delete -f "${SCRIPTPATH}"/pod-security-policy/capabilities.yml
kubectl delete -f "${SCRIPTPATH}"/pod-security-policy/read_only_root_filesystem.yml
kubectl delete -f "${SCRIPTPATH}"/pod-security-policy/seccomp.yml
kubectl delete -f "${SCRIPTPATH}"/pod-security-policy/selinux.yml
kubectl delete -f "${SCRIPTPATH}"/pod-security-policy/users.yml

# Delete the custom constraint template and related constraints
kubectl delete constrainttemplate k8sdenynamespace
kubectl delete constraint require-labels || echo 0
kubectl delete configmap gatekeeper-audit -n "${NAMESPACE}"

# Remove Gatekeeper constraints and templates
kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/basic/constraints/all_ns_must_have_gatekeeper.yaml || echo 0
kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/basic/templates/k8srequiredlabels_template.yaml || echo 0

# Delete the Gatekeeper CRDs
kubectl delete crd -l gatekeeper.sh/system=yes
