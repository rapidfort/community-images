FROM golang:latest

RUN go install github.com/influxdata/inch/cmd/inch@latest

ADD ./entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
