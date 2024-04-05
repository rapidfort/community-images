#!/bin/bash


for (( i = 0; i < 10; i++ )); do

	sleep 5
	kubectl	wait pods rf-cockroachdb-ib-0 -n ${NAMESPACE} --for=condition=ready --timeout=20m
	
	if [[ $? == 0 ]]; then
		exit 0
	fi
done

exit 1
