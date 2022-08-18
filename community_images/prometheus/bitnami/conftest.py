"""The conftest file for running selenium test."""
# conftest.py
import pytest #pylint: disable=import-error

def pytest_addoption(parser):
    """The function to add options"""
    parser.addoption("--prom_server", action="store", help="prometheus server")
    parser.addoption("--port", action="store", help="port for prometheus container")

@pytest.fixture
def params(request):
    """the params"""
    config_params = {}
    config_params['prom_server'] = request.config.getoption('--prom_server')
    config_params['port'] = request.config.getoption('--port')
    if config_params['prom_server'] is None or config_params['port'] is None:
        pytest.skip()
    return config_params
