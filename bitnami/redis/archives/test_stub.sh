HELM_RELEASE=stub-run-release
NAMESPACE=ci-dev

REDIS_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE}-redis -o jsonpath="{.data.redis-password}" | base64 --decode)
#exec into container
kubectl -n ${NAMESPACE} exec -it ${HELM_RELEASE}-redis-master-0 -- /bin/bash -c "redis-cli -a ${REDIS_PASSWORD} EVAL \"return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}\" 2 key1 key2 first second"
