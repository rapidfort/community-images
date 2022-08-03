"""The conftest file for running selenium test."""
# conftest.py
import pytest #pylint: disable=import-error

def pytest_addoption(parser):
    """The function to add options"""
    parser.addoption("--ip_address", action="store", help="ip address of wordpress")
    parser.addoption("--port", action="store", help="port for wordpress container")

@pytest.fixture
def params(request):
    """the params"""
    config_params = {}
    config_params['ip_address'] = request.config.getoption('--ip_address')
    config_params['port'] = request.config.getoption('--port')
    if config_params['ip_address'] is None or config_params['port'] is None:
        pytest.skip()
    return config_params
