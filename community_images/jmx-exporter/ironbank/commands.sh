#!/bin/bash

set -x
set -e

# Start the hello-world application with the java agent in the background
java -javaagent:./jmx_prometheus_javaagent-0.20.0.jar=12345:/opt/jmx_exporter/jmx-configs/java-agent-config.yaml -jar /opt/jmx_exporter/hello-world.jar

# Start the jmx_prometheus_httpserver in the background
java -jar /opt/jmx_exporter/jmx_prometheus_httpserver-0.20.0.jar 12345 /opt/jmx_exporter/jmx-configs/http-server-config.yaml || echo 0 &

