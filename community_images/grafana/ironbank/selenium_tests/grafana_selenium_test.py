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
        # 4 | click | id=current-password |  | 
        self.driver.find_element(By.ID, "current-password").click()
        # 5 | type | id=current-password | admin | 
        self.driver.find_element(By.ID, "current-password").send_keys("admin")
        # 6 | click | css=.css-8csoim-button > .css-1mhnkuh |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-8csoim-button > .css-1mhnkuh").click()
        # 7 | click | css=.css-oq8fy1-button > .css-1mhnkuh |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-oq8fy1-button > .css-1mhnkuh").click()
        # 8 | click | css=.css-hj6vlq |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-hj6vlq").click()
        # 9 | click | css=.css-fv3lde:nth-child(7) .css-1xnfi89 |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-fv3lde:nth-child(7) .css-1xnfi89").click()
        # 10 | click | css=.css-1y9dsbx-button |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-1y9dsbx-button").click()
        # 11 | click | linkText=Data sources |  | 
        self.driver.find_element(By.LINK_TEXT, "Data sources").click()
        # 12 | click | xpath=//span[contains(.,'Add data source')] |  | 
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Add data source\')]").click()

        self.driver.implicitly_wait(10)
        # 17 | click | xpath=//button[contains(.,'Prometheus')] |  | 
        self.driver.find_element(By.XPATH, "//button[contains(.,\'Prometheus\')]").click()
        # 18 | click | css=.css-y1sxu8 |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-y1sxu8").click()
        # 19 | type | css=.width-20:nth-child(1) | http://10.10.0.165:9090 | 
        self.driver.find_element(By.CSS_SELECTOR, ".width-20:nth-child(1)").send_keys("http://localhost:9090")
        # 20 | click | css=.css-z53gi5-button > .css-1mhnkuh |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-z53gi5-button > .css-1mhnkuh").click()
        
        ### Dashboards setup
        # 1 | open | /datasources/edit/<hex>/dashboards |  | 
        self.driver.get(
            "http://localhost:{}/datasources/edit/{}/dashboards".format(
                params['port'],
                self.driver.current_url[39:]))
        # 2 | setWindowSize | 727x785 |  | 
        self.driver.set_window_size(727, 785)
        # 3 | click | css=tr:nth-child(2) .css-1mhnkuh |  | 
        self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(2) .css-1mhnkuh").click()
        # 4 | click | linkText=Prometheus 2.0 Stats |  | 
        self.driver.find_element(By.LINK_TEXT, "Prometheus 2.0 Stats").click()
        self.driver.implicitly_wait(10)
        # 5 | runScript | window.scrollTo(0,0) |  | 
        self.driver.execute_script("window.scrollTo(0,0)")

        ### Alert manager
        # 1 | open | /connections/your-connections/datasources/new |  | 
        self.driver.get(
            "http://localhost:{}/connections/your-connections/datasources/new".format(
                params['port']))
        # 2 | setWindowSize | 727x785 |  | 
        self.driver.set_window_size(727, 785)
        # 3 | click | css=.css-1mlczho-input-input |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-1mlczho-input-input").click()
        # 4 | type | css=.css-1mlczho-input-input | alert | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-1mlczho-input-input").send_keys("alert")
        # 5 | click | css=.css-1cqw476 |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-1cqw476").click()
        # 6 | mouseDown | xpath=//div[@id='reactRoot']/div/main/div[2]/div[3]/div/div[2]/div/div/div/div[3]/form/div[3]/div/div/div/div/div/div/div[2] |  | 
        element = self.driver.find_element(By.XPATH, "//div[@id=\'reactRoot\']/div/main/div[2]/div[3]/div/div[2]/div/div/div/div[3]/form/div[3]/div/div/div/div/div/div/div[2]")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).click_and_hold().perform()
        # 7 | click | css=#react-select-2-option-2 .css-1gncicp-grafana-select-option-description |  | 
        self.driver.find_element(By.CSS_SELECTOR, "#react-select-2-option-2 .css-1gncicp-grafana-select-option-description").click()
        # 8 | click | css=.css-y1sxu8 |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-y1sxu8").click()
        # 9 | type | css=.gf-form-input:nth-child(1) | http://10.10.0.165:9093 | 
        self.driver.find_element(By.CSS_SELECTOR, ".gf-form-input:nth-child(1)").send_keys("http://localhost:9093")
        # 10 | click | css=.css-z53gi5-button > .css-1mhnkuh |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-z53gi5-button > .css-1mhnkuh").click()

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
        # 11 | click | css=.css-1mhnkuh |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-1mhnkuh").click()
        # 12 | click | css=.css-1fwxvu6 |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-1fwxvu6").click()
        self.driver.implicitly_wait(5)
        
        ### New User login
        self.driver.get(
            "http://localhost:{}/logout".format(
                params['port']))
        # 1 | click | name=user |  | 
        self.driver.find_element(By.NAME, "user").click()
        # 2 | type | name=user | new-user | 
        self.driver.find_element(By.NAME, "user").send_keys("new-user")
        # 3 | click | id=current-password |  | 
        self.driver.find_element(By.ID, "current-password").click()
        # 4 | type | id=current-password | newuser | 
        self.driver.find_element(By.ID, "current-password").send_keys("newuser")
        # 5 | click | css=.css-8csoim-button > .css-1mhnkuh |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-8csoim-button > .css-1mhnkuh").click()
        # 6 | click | css=.css-1fwxvu6 |  | 
        self.driver.find_element(By.CSS_SELECTOR, ".css-1fwxvu6").click()
