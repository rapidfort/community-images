"""The selenium test."""
# pylint: skip-file

# Generated by Selenium IDE
import json  # pylint: disable=import-error disable=unused-import
import time  # pylint: disable=import-error disable=unused-import
import pytest  # pylint: disable=import-error disable=unused-import
from selenium import webdriver  # pylint: disable=import-error
from selenium.webdriver.chrome.options import Options  # pylint: disable=import-error
from selenium.webdriver.common.by import By  # pylint: disable=import-error
from selenium.webdriver.common.action_chains import ActionChains  # pylint: disable=import-error disable=unused-import
from selenium.webdriver.support import expected_conditions  # pylint: disable=import-error disable=unused-import
from selenium.webdriver.support.wait import WebDriverWait  # pylint: disable=import-error disable=unused-import
from selenium.webdriver.common.keys import Keys  # pylint: disable=import-error disable=unused-import
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities  # pylint: disable=import-error disable=unused-import
from selenium.webdriver.support import expected_conditions as EC


class TestGrafanatest1():
    """The test word press class for testing grafana image."""

    def setup_method(self, method):  # pylint: disable=unused-argument
        """setup method."""
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument("disable-infobars")
        chrome_options.add_argument("--disable-extensions")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--no-sandbox")
        self.driver = webdriver.Chrome(
            options=chrome_options)  # pylint: disable=attribute-defined-outside-init
        self.driver.implicitly_wait(10)

    def teardown_method(self, method):  # pylint: disable=unused-argument
        """teardown method."""
        self.driver.quit()

    def test_login(self, params):
        # Test name: initialize-and-setup-prometheus
        # Step # | name | target | value |
        # 1 | open | /login |
        self.driver.get(
                "http://localhost:{}/login".format(
                    params["port"]))  # pylint: disable=consider-using-f-string
        # 2 | setWindowSize | 727x785 |  | 
        self.driver.set_window_size(727, 785)
        # 3 | type | name=user | admin | 
        self.driver.find_element(By.NAME, "user").send_keys("admin")
        # 4 | click | id=:r1: |  | 
        self.driver.find_element(By.ID, ":r1:").click()
        # 5 | type | id=:r1: | admin | 
        self.driver.find_element(By.ID, ":r1:").send_keys("admin@$123")
        # 6 | click | css=.css-1b7vft8-button > .css-1riaxdn |  | 
        self.driver.find_element(By.XPATH, "//span[contains(.,'Log in')]").click()
        # 7 | click | xpath=//span[contains(.,'Data sources')] |  |
        self.driver.find_element(By.XPATH, "//h4[contains(.,'Add your first data source')]").click()
        # 8 | click | xpath=//span[contains(.,\'Add data source\')]
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Add data source\')]").click()
        self.driver.implicitly_wait(10)
        # 9 | click | xpath=//button[contains(.,'Prometheus')] |  | 
        self.driver.find_element(By.XPATH, "//button[contains(.,\'Prometheus\')]").click()
        # 10 | click | css=#connection-url |  | 
        self.driver.find_element(By.CSS_SELECTOR, "#connection-url").click()
        # 11 | type | css=#connection-url | http://prometheus:9090 | 
        self.driver.find_element(By.CSS_SELECTOR, "#connection-url").send_keys("http://prometheus:9090")
        # 12 | click | css=.css-td06pi-button > .css-1riaxdn |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-td06pi-button > .css-1riaxdn").click()
        
        ### Dashboards setup
        self.driver.get(
            "http://localhost:{}/dashboard/new".format(
                params['port']))
        self.driver.set_window_size(1277, 733)
        # self.driver.implicitly_wait(10)
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Add visualization\')]").click()
        self.driver.find_element(By.XPATH, "//h2/button").click()
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Apply\')]").click()
        self.driver.execute_script("window.scrollTo(0,0)")
        
        ### Alert manager
        # 1 | open | /connections/your-connections/datasources/new |  | 
        self.driver.get(
            "http://localhost:{}/connections/add-new-connection".format(
                params['port']))
        # 2 | setWindowSize | 727x785 |  | 
        self.driver.set_window_size(727, 785)
        # 3 | type | xpath=//a[contains(.,'Alertmanager')] | alert | 
        self.driver.find_element(By.XPATH, "//a[contains(.,'Alertmanager')]").click()
        # 4 | click | xpath=//span[contains(.,'Add new data source')] |  | 
        self.driver.find_element(By.XPATH, "//span[contains(.,'Add new data source')]").click()
        # 5 | click | css=.css-zyjsuv-input-suffix |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-zyjsuv-input-suffix").click()
        # 6 | click | xpath=//span[contains(.,'Prometheus')]
        self.driver.find_element(By.XPATH, "//span[contains(.,'Prometheus')]").click()

        ### User management
        # 1 | open | /admin/users/create |  | 
        self.driver.get(
            "http://localhost:{}/admin/users/create".format(
                params['port']))
        # 2 | setWindowSize | 727x785 |  | 
        self.driver.set_window_size(727, 785)
        # 3 | click | id=name-input |  | 
        self.driver.find_element(By.ID, "name-input").click()
        # 4 | type | id=name-input | new user | 
        self.driver.find_element(By.ID, "name-input").send_keys("new user")
        # 5 | click | id=email-input |  | 
        self.driver.find_element(By.ID, "email-input").click()
        # 6 | type | id=email-input | new@user.com | 
        self.driver.find_element(By.ID, "email-input").send_keys("new@user.com")
        # 7 | click | id=username-input |  | 
        self.driver.find_element(By.ID, "username-input").click()
        # 8 | type | id=username-input | new-user | 
        self.driver.find_element(By.ID, "username-input").send_keys("new-user")
        # 9 | click | id=password-input |  | 
        self.driver.find_element(By.ID, "password-input").click()
        # 10 | type | id=password-input | newuser | 
        self.driver.find_element(By.ID, "password-input").send_keys("newuser")
        # 11 | click | css=.css-td06pi-button > .css-1riaxdn |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-td06pi-button > .css-1riaxdn").click()
        self.driver.implicitly_wait(5)
        
        ### New User login
        self.driver.get(
            "http://localhost:{}/logout".format(
                params['port']))
        # 1 | click | name=user |  | 
        self.driver.find_element(By.NAME, "user").click()
        # 2 | type | name=user | new-user | 
        self.driver.find_element(By.NAME, "user").send_keys("new-user")
        # 3 | click | id=:r1: |  | 
        self.driver.find_element(By.ID, ":r1:").click()
        # 4 | type | id=:r1: | newuser | 
        self.driver.find_element(By.ID, ":r1:").send_keys("newuser")
        # 5 | click | css=.css-1b7vft8-button > .css-1mhnkuh |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-1b7vft8-button").click()
