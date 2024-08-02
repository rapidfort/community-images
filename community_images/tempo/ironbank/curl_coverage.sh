#!/bin/bash

set -ex

# Get job
curl 'http://localhost:3000/api/datasources/uid/P8E80F9AEF21F6940/resources/labels?start=1710170946625000000&end=1710174546625000000' \
  -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: grafana_session=cb165b7a0f4407c27f028d0efa932118; grafana_session_expiry=1710149906' \
  -H 'Referer: http://localhost:3000/explore?schemaVersion=1&panes=%7B%22Hpo%22%3A%7B%22datasource%22%3A%22P8E80F9AEF21F6940%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22P8E80F9AEF21F6940%22%7D%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-1h%22%2C%22to%22%3A%22now%22%7D%7D%7D&orgId=1' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'x-grafana-org-id: 1' \
  -H 'x-plugin-id: loki' \
  --compressed \
  --insecure

# Get job names
curl 'http://localhost:3000/api/datasources/uid/P8E80F9AEF21F6940/resources/label/job/values?start=1710170946625000000&end=1710174546625000000' \
  -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: grafana_session=cb165b7a0f4407c27f028d0efa932118; grafana_session_expiry=1710149906' \
  -H 'Referer: http://localhost:3000/explore?schemaVersion=1&panes=%7B%22Hpo%22%3A%7B%22datasource%22%3A%22P8E80F9AEF21F6940%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22P8E80F9AEF21F6940%22%7D%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-1h%22%2C%22to%22%3A%22now%22%7D%7D%7D&orgId=1' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'x-grafana-org-id: 1' \
  -H 'x-plugin-id: loki' \
  --compressed \
  --insecure

# Others
curl 'http://localhost:3000/api/ds/query?ds_type=loki&requestId=loki-data-samples_1' \
  -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: grafana_session=cb165b7a0f4407c27f028d0efa932118; grafana_session_expiry=1710149906' \
  -H 'Origin: http://localhost:3000' \
  -H 'Referer: http://localhost:3000/explore?schemaVersion=1&panes=%7B%22Hpo%22%3A%7B%22datasource%22%3A%22P8E80F9AEF21F6940%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22P8E80F9AEF21F6940%22%7D%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-1h%22%2C%22to%22%3A%22now%22%7D%7D%7D&orgId=1' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'content-type: application/json' \
  -H 'x-grafana-org-id: 1' \
  -H 'x-plugin-id: loki' \
  -H 'x-query-group-id: a5349a44-e214-4bb8-b71f-46337b851504' \
  --data-raw '{"queries":[{"expr":"{job=\"varlogs\"} |= ``","queryType":"range","refId":"loki-data-samples","maxLines":10,"supportingQueryType":"dataSample","legendFormat":"","datasource":{"type":"loki","uid":"P8E80F9AEF21F6940"},"datasourceId":1,"intervalMs":3600000}],"from":"1710170972412","to":"1710174572412"}' \
  --compressed \
  --insecure

  curl 'http://localhost:3000/api/datasources/uid/P8E80F9AEF21F6940/resources/index/stats?query=%7Bjob%3D%22varlogs%22%7D&start=1710170972412000000&end=1710174572412000000' \
    -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
    -H 'Connection: keep-alive' \
    -H 'Cookie: grafana_session=cb165b7a0f4407c27f028d0efa932118; grafana_session_expiry=1710149906' \
    -H 'Referer: http://localhost:3000/explore?schemaVersion=1&panes=%7B%22Hpo%22%3A%7B%22datasource%22%3A%22P8E80F9AEF21F6940%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22P8E80F9AEF21F6940%22%7D%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-1h%22%2C%22to%22%3A%22now%22%7D%7D%7D&orgId=1' \
    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    -H 'accept: application/json, text/plain, */*' \
        -H 'x-grafana-org-id: 1' \
    -H 'x-plugin-id: loki' \
    --compressed \
    --insecure

# shellcheck disable=SC2016
curl 'http://localhost:3000/api/ds/query?ds_type=loki&requestId=loki-data-samples_1' \
  -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: grafana_session=cb165b7a0f4407c27f028d0efa932118; grafana_session_expiry=1710149906' \
  -H 'Origin: http://localhost:3000' \
  -H 'Referer: http://localhost:3000/explore?schemaVersion=1&panes=%7B%22Hpo%22%3A%7B%22datasource%22%3A%22P8E80F9AEF21F6940%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22P8E80F9AEF21F6940%22%7D%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-1h%22%2C%22to%22%3A%22now%22%7D%7D%7D&orgId=1' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'content-type: application/json' \
  -H 'x-grafana-org-id: 1' \
  -H 'x-plugin-id: loki' \
  -H 'x-query-group-id: bda44874-2e68-4978-b39c-60b15b304428' \
  --data-raw '{"queries":[{"expr":"{job=\"varlogs\"} |= `status`","queryType":"range","refId":"loki-data-samples","maxLines":10,"supportingQueryType":"dataSample","legendFormat":"","datasource":{"type":"loki","uid":"P8E80F9AEF21F6940"},"datasourceId":1,"intervalMs":3600000}],"from":"1710170980534","to":"1710174580534"}' \
  --compressed \
  --insecure

curl 'http://localhost:3000/api/datasources/uid/P8E80F9AEF21F6940/resources/index/stats?query=%7Bjob%3D%22varlogs%22%7D&start=1710170980534000000&end=1710174580534000000' \
  -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: grafana_session=cb165b7a0f4407c27f028d0efa932118; grafana_session_expiry=1710149906' \
  -H 'Referer: http://localhost:3000/explore?schemaVersion=1&panes=%7B%22Hpo%22%3A%7B%22datasource%22%3A%22P8E80F9AEF21F6940%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22P8E80F9AEF21F6940%22%7D%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-1h%22%2C%22to%22%3A%22now%22%7D%7D%7D&orgId=1' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'x-grafana-org-id: 1' \
  -H 'x-plugin-id: loki' \
  --compressed \
  --insecure

curl 'http://localhost:3000/api/datasources/uid/P8E80F9AEF21F6940/resources/index/stats?query=%7Bjob%3D%22varlogs%22%7D&start=1710170983789000000&end=1710174583789000000' \
  -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: grafana_session=cb165b7a0f4407c27f028d0efa932118; grafana_session_expiry=1710149906' \
  -H 'Referer: http://localhost:3000/explore?schemaVersion=1&panes=%7B%22Hpo%22%3A%7B%22datasource%22%3A%22P8E80F9AEF21F6940%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22P8E80F9AEF21F6940%22%7D%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-1h%22%2C%22to%22%3A%22now%22%7D%7D%7D&orgId=1' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'x-grafana-org-id: 1' \
  -H 'x-plugin-id: loki' \
  --compressed \
  --insecure

curl 'http://localhost:3000/api/datasources/uid/P8E80F9AEF21F6940/resources/index/stats?query=%7Bjob%3D%22varlogs%22%7D&start=1710170988440000000&end=1710174588440000000' \
  -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: grafana_session=cb165b7a0f4407c27f028d0efa932118; grafana_session_expiry=1710149906' \
  -H 'Referer: http://localhost:3000/explore?schemaVersion=1&panes=%7B%22Hpo%22%3A%7B%22datasource%22%3A%22P8E80F9AEF21F6940%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22P8E80F9AEF21F6940%22%7D%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-1h%22%2C%22to%22%3A%22now%22%7D%7D%7D&orgId=1' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'x-grafana-org-id: 1' \
  -H 'x-plugin-id: loki' \
  --compressed \
  --insecure

# shellcheck disable=SC2016
curl 'http://localhost:3000/api/query-history' \
  -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: grafana_session=cb165b7a0f4407c27f028d0efa932118; grafana_session_expiry=1710149906' \
  -H 'Origin: http://localhost:3000' \
  -H 'Referer: http://localhost:3000/explore?schemaVersion=1&panes=%7B%22Hpo%22%3A%7B%22datasource%22%3A%22P8E80F9AEF21F6940%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22P8E80F9AEF21F6940%22%7D%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-1h%22%2C%22to%22%3A%22now%22%7D%7D%7D&orgId=1' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'content-type: application/json' \
  -H 'x-grafana-org-id: 1' \
  --data-raw '{"dataSourceUid":"P8E80F9AEF21F6940","queries":[{"refId":"A","expr":"rate({job=\"varlogs\"} |= `status` [1m])","queryType":"range","datasource":{"type":"loki","uid":"P8E80F9AEF21F6940"},"editorMode":"builder"}]}' \
  --compressed \
  --insecure

# shellcheck disable=SC2016
curl 'http://localhost:3000/api/ds/query?ds_type=loki&requestId=explore_Hpo_1' \
  -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: grafana_session=cb165b7a0f4407c27f028d0efa932118; grafana_session_expiry=1710149906' \
  -H 'Origin: http://localhost:3000' \
  -H 'Referer: http://localhost:3000/explore?schemaVersion=1&panes=%7B%22Hpo%22%3A%7B%22datasource%22%3A%22P8E80F9AEF21F6940%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22P8E80F9AEF21F6940%22%7D%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-1h%22%2C%22to%22%3A%22now%22%7D%7D%7D&orgId=1' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'content-type: application/json' \
  -H 'x-grafana-org-id: 1' \
  -H 'x-panel-id: undefined' \
  -H 'x-plugin-id: loki' \
  -H 'x-query-group-id: 1d434e6d-f1d7-4891-a9b4-05afbd9d8607' \
  --data-raw '{"queries":[{"refId":"A","expr":"rate({job=\"varlogs\"} |= `status` [1m])","queryType":"range","datasource":{"type":"loki","uid":"P8E80F9AEF21F6940"},"editorMode":"builder","legendFormat":"","datasourceId":1,"intervalMs":5000,"maxDataPoints":801}],"from":"1710170990000","to":"1710174595000"}' \
  --compressed \
  --insecure

# shellcheck disable=SC2016
curl 'http://localhost:3000/api/ds/query?ds_type=loki&requestId=explore_Hpo_logs_sample_0_1' \
  -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: grafana_session=cb165b7a0f4407c27f028d0efa932118; grafana_session_expiry=1710149906' \
  -H 'Origin: http://localhost:3000' \
  -H 'Referer: http://localhost:3000/explore?schemaVersion=1&panes=%7B%22Hpo%22:%7B%22datasource%22:%22P8E80F9AEF21F6940%22,%22queries%22:%5B%7B%22refId%22:%22A%22,%22expr%22:%22rate%28%7Bjob%3D%5C%22varlogs%5C%22%7D%20%7C%3D%20%60status%60%20%5B1m%5D%29%22,%22queryType%22:%22range%22,%22datasource%22:%7B%22type%22:%22loki%22,%22uid%22:%22P8E80F9AEF21F6940%22%7D,%22editorMode%22:%22builder%22%7D%5D,%22range%22:%7B%22from%22:%22now-1h%22,%22to%22:%22now%22%7D%7D%7D&orgId=1' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'content-type: application/json' \
  -H 'x-grafana-org-id: 1' \
  -H 'x-panel-id: undefined' \
  -H 'x-plugin-id: loki' \
  -H 'x-query-group-id: 9222045c-cad9-4349-9369-5efbee4e8857' \
  --data-raw '{"queries":[{"refId":"log-sample-A","expr":"{job=\"varlogs\"} |= `status`","queryType":"range","datasource":{"type":"loki","uid":"P8E80F9AEF21F6940"},"editorMode":"builder","maxLines":100,"legendFormat":"","datasourceId":1,"intervalMs":5000,"maxDataPoints":801}],"from":"1710170991422","to":"1710174591422"}' \
  --compressed \
  --insecure

