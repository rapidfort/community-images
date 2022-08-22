"""The conftest file for running selenium test."""
# conftest.py
import pytest  # pylint: disable=import-error


def pytest_addoption(parser):
    """The function to add options"""
    parser.addoption("--wordpress_server", action="store",
                     help="wordpress server")
    parser.addoption("--port", action="store",
                     help="port for wordpress container")


@pytest.fixture
def params(request):
    """the params"""
    config_params = {}
    config_params['wordpress_server'] = request.config.getoption(
        '--wordpress_server')
    config_params['port'] = request.config.getoption('--port')
    if config_params['wordpress_server'] is None or config_params['port'] is None:
        pytest.skip()
    return config_params
