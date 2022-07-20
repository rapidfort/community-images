# conftest.py
import pytest

def pytest_addoption(parser):
    parser.addoption("--ip_address", action="store", help="ip address of wordpress")
    parser.addoption("--port", action="store", help="port for wordpress container")

@pytest.fixture
def params(request):
    params = {}
    params['ip_address'] = request.config.getoption('--ip_address')
    params['port'] = request.config.getoption('--port')
    if params['ip_address'] is None or params['port'] is None:
        pytest.skip()
    return params
