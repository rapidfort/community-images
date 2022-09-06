"""The flask application"""
#!/usr/bin/env python3

from flask import Flask, Response  # pylint: disable=import-error
import prometheus_client  # pylint: disable=import-error
from helpers.middleware import setup_metrics

CONTENT_TYPE_LATEST = str('text/plain; version=0.0.4; charset=utf-8')


app = Flask(__name__)
setup_metrics(app)


@app.route('/test/')
def test():
    """The test endpoint"""
    return 'rest'


@app.route('/test1/')
def test1():
    """The test1 endpoint"""
    1 / 0  # pylint: disable=pointless-statement
    return 'rest'


@app.errorhandler(500)
def handle_500(error):
    """The error handler"""
    return str(error), 500


@app.route('/metrics')
def metrics():
    """The metrics endpoint"""
    return Response(
        prometheus_client.generate_latest(),
        mimetype=CONTENT_TYPE_LATEST)


if __name__ == '__main__':
    app.run()
