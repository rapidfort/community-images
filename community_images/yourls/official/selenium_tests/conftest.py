"""The conftest file for running selenium test."""
# pylint: skip-file

# conftest.py
import pytest  # pylint: disable=import-error


def pytest_addoption(parser):
    """The function to add options"""
    parser.addoption("--port", action="store",
                     help="port of host linked to Yourls container")


@pytest.fixture
def params(request):
    """the params"""
    config_params = {}
    config_params['port'] = request.config.getoption('--port')
    if config_params['port'] is None:
        pytest.skip()
    return config_params
