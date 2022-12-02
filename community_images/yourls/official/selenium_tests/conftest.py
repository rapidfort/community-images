"""The conftest file for running selenium test."""
# pylint: skip-file

# conftest.py
import pytest  # pylint: disable=import-error


def pytest_addoption(parser):
    """The function to add options"""
    parser.addoption("--server", action="store", help="wordpress server")
    parser.addoption("--port", action="store",
                     help="port on host linked to yourls container")


@pytest.fixture
def params(request):
    """the params"""
    config_params = {}
    config_params['server'] = request.config.getoption('--server')
    config_params['port'] = request.config.getoption('--port')
    if config_params['server'] is None or config_params['port'] is None:
        pytest.skip()
    return config_params
