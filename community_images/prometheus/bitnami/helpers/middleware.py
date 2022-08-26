"""The middleware module"""
#!/usr/bin/env python3

import time
from flask import request  # pylint: disable=import-error
from prometheus_client import Counter, Histogram  # pylint: disable=import-error

REQUEST_COUNT = Counter(
    'request_count', 'App Request Count',
    ['app_name', 'method', 'endpoint', 'http_status']
)
REQUEST_LATENCY = Histogram('request_latency_seconds', 'Request latency',
                            ['app_name', 'endpoint']
                            )


def start_timer():
    """The start timer function"""
    request.start_time = time.time()


def stop_timer(response):
    """The stop timer function"""
    resp_time = time.time() - request.start_time
    REQUEST_LATENCY.labels('webapp', request.path).observe(resp_time)
    return response


def record_request_data(response):
    """The method to record the request metadata"""
    REQUEST_COUNT.labels('webapp', request.method, request.path,
                         response.status_code).inc()
    return response


def setup_metrics(app):
    """The method to setup the metrics"""
    app.before_request(start_timer)
    # we want stop_timer to execute first
    app.after_request(record_request_data)
    app.after_request(stop_timer)
