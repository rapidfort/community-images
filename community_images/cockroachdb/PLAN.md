```bash
helm repo add cockroachdb https://charts.cockroachdb.com/

helm install rf-cockroachdb \
	--namespace rfns \
	cockroachdb/cockroachdb \
	--set init.provisioning.users[0].name root \
	--set init.provisioning.users[0].password root123

helm delete rf-cockroachdb -n rfns


kubectl run cockroachdb --rm -it -n rfns \
	--image=cockroachdb/cockroach \
	--restart=Never \
	-- sql --host=rf-cockroachdb-cockroachdb-public 

# kubectl run cockroachdb -n rfns --image=cockroachdb/cockroach --restart=Never -- bash -c "sleep infinity"

kubectl get secret -o yaml rf-cockroachdb-ib-client-secret -n rfns | yq '.data."ca.crt"'  | base64 -d | tee  ca.crt
kubectl get secret -o yaml rf-cockroachdb-ib-client-secret -n rfns | yq '.data."tls.crt"' | base64 -d | tee tls.crt
kubectl get secret -o yaml rf-cockroachdb-ib-client-secret -n rfns | yq '.data."tls.crt"' | base64 -d | tee tls.key

kubectl get secret -o yaml rf-cockroachdb-ib-node-secret -n rfns | yq '.data."ca.crt"'  | base64 -d | tee  ca.crt
kubectl get secret -o yaml rf-cockroachdb-ib-node-secret -n rfns | yq '.data."tls.crt"' | base64 -d | tee tls.crt
kubectl get secret -o yaml rf-cockroachdb-ib-node-secret -n rfns | yq '.data."tls.crt"' | base64 -d | tee tls.key

kubectl exec -i -n rfns pod/rf-cockroachdb-ib-1 -- bash -c "cat > cockroach-certs/root-certs/ca.crt"  < ca.crt
kubectl exec -i -n rfns pod/rf-cockroachdb-ib-1 -- bash -c "cat > cockroach-certs/root-certs/tls.crt" < tls.crt
kubectl exec -i -n rfns pod/rf-cockroachdb-ib-1 -- bash -c "cat > cockroach-certs/root-certs/tls.key" < tls.key

# kubectl exec -i -n rfns rf-cockroachdb-cockroachdb-0 -- bash -c "cat >  ca.crt" <  ca.crt
# kubectl exec -i -n rfns rf-cockroachdb-cockroachdb-0 -- bash -c "cat > tls.crt" < tls.crt
# kubectl exec -i -n rfns rf-cockroachdb-cockroachdb-0 -- bash -c "cat > tls.key" < tls.key

# kubectl exec -i -n rfns cockroachdb -- sql --host=10.96.74.48 --ssl --ssl-ca=ca.crt --ssl-cert=tls.crt --ssl-key=tls.key

curl -OOOOOOOOO https://raw.githubusercontent.com/cockroachdb/helm-charts/master/examples/client-secure.yaml

```
```yaml
# Copyright 2021 The Cockroach Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Generated, do not edit. Please edit this file instead: config/templates/client-secure-operator.yaml.in
#

apiVersion: v1
kind: Pod
metadata:
  name: cockroachdb-client-secure
spec:
  serviceAccountName: rf-cockroachdb-ib # Change to {release}
  containers:
  - name: cockroachdb-client-secure
    image: cockroachdb/cockroach:v21.1.11 # Change to cockroachdb/cockroach:{version}
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - name: client-certs
      mountPath: /cockroach/cockroach-certs/
    command:
    - sleep
    - "2147483648" # 2^31
  terminationGracePeriodSeconds: 300
  volumes:
  - name: client-certs
    projected:
        sources:
          - secret:
              name: rf-cockroachdb-ib-client-secret # Change to {release}-client-secret
              items:
                - key: ca.crt
                  path: ca.crt
                - key: tls.crt
                  path: client.root.crt
                - key: tls.key
                  path: client.root.key
        defaultMode: 256
```
```bash
kubectl create -f client-secure.yaml -n rfns

kubectl exec -it cockroachdb-client-secure -n rfns -- ./cockroach sql --certs-dir=./cockroach-certs --host=rf-cockroachdb-public
```