#!/bin/bash
    GO111MODULE=off go get github.com/nats-io/nats.go
    cd "$GOPATH"/src/github.com/nats-io/nats.go/examples/nats-pub && go install && cd || exit
    cd "$GOPATH"/src/github.com/nats-io/nats.go/examples/nats-echo && go install && cd || exit
    nats-echo -s nats://nats_client:uzlbJ8FN5p@rf-nats.rf-nats-2adfc4b399.svc.cluster.local:4222 SomeSubject &
    nats-pub -s nats://nats_client:uzlbJ8FN5p@rf-nats.rf-nats-2adfc4b399.svc.cluster.local:4222 -reply Hi SomeSubject 'Hi everyone'
