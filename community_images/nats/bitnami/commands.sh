#!/bin/bash
   set -e
   set -x
   GO111MODULE=off go get github.com/nats-io/nats.go
   go env -w GOPROXY=direct
   go env -w GOSUMDB=off
   # go install golang.org/x/crypto/blake2b/my.go
   # go install golang.org/x/crypto/blake2b@v0.14.0
   cd "$GOPATH"/src/github.com/nats-io/nats.go/examples/nats-pub && go get golang.org/x/crypto/blake2b@v0.14.0 && go install && cd || exit
   cd "$GOPATH"/src/github.com/nats-io/nats.go/examples/nats-echo && go install && cd || exit
   nats-echo -s nats://nats_client:Rri8PgO4St@rf-nats.nats-1hksgmwnq0.svc.cluster.local:4222 SomeSubject &
   nats-pub -s nats://nats_client:Rri8PgO4St@rf-nats.nats-1hksgmwnq0.svc.cluster.local:4222 -reply Hi SomeSubject 'Hi everyone'
