"""The selenium test."""
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


class TestWordpresstest1():
    """The test word press class for testing wordpress image."""

    def setup_method(self, method):  # pylint: disable=unused-argument
        """setup method."""
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument("disable-infobars")
        chrome_options.add_argument("--disable-extensions")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--no-sandbox")
        self.driver = webdriver.Chrome(options=chrome_options)  # pylint: disable=attribute-defined-outside-init
        self.driver.implicitly_wait(10)

    def teardown_method(self, method):  # pylint: disable=unused-argument
        """teardown method."""
        self.driver.quit()

    def test_wordpresstest1(self, params):
        """test wordpress."""
        # Test name: wordpress-test-1
        # Step # | name | target | value
        # 1 | open | / |
        self.driver.get("http://{}:{}/".format(params["ip_address"], params["port"]))  # pylint: disable=consider-using-f-string
        # 2 | setWindowSize | 1095x688 |
        self.driver.set_window_size(1095, 688)
        # 3 | click | linkText=Hello world! |
        self.driver.find_element(By.LINK_TEXT, "Hello world!").click()
        # 4 | click | id=comment |
        self.driver.find_element(By.ID, "comment").click()
        # 5 | type | id=comment | hello
        self.driver.find_element(By.ID, "comment").send_keys("hello")
        # 6 | click | id=author |
        self.driver.find_element(By.ID, "author").click()
        # 7 | type | id=author | hello
        self.driver.find_element(By.ID, "author").send_keys("hello")
        # 8 | type | id=email | hello@abc.com
        self.driver.find_element(By.ID, "email").send_keys("hello@abc.com")
        # 9 | type | id=url | http://hello.com
        self.driver.find_element(By.ID, "url").send_keys("http://hello.com")
        # 10 | click | id=submit |
        self.driver.find_element(By.ID, "submit").click()
        # 11 | click | linkText=User's Blog! |
        #self.driver.find_element(By.LINK_TEXT, "User\'s Blog!").click()

    def test_users(self, params):
        """Test name: simplelogin."""
        # Step # | name | target | value
        # 1 | open | /wp-login.php |
        self.driver.get("http://{}:{}/users.php".format(params["ip_address"], params["port"]))  # pylint: disable=consider-using-f-string
        # 2 | setWindowSize | 1200x828 |
        self.driver.set_window_size(1200, 828)

    # def test_addusers(self, params):
    #     """Test name: simplelogin."""
    #     # Step # | name | target | value
    #     # 1 | open | /wp-login.php |
    #     self.driver.get("http://{}:{}/wp-admin/user-new.php".format(params["ip_address"], params["port"]))  # pylint: disable=consider-using-f-string disable=line-too-long
    #     # 2 | setWindowSize | 1200x828 |
    #     self.driver.set_window_size(1200, 828)
    #     self.driver.find_element(By.ID, "user_login").send_keys("user3")
    #     # 10 | type | id=email | user3
    #     self.driver.find_element(By.ID, "email").send_keys("user3")
    #     # 11 | type | id=email | user3@abc.com
    #     self.driver.find_element(By.ID, "email").send_keys("user3@abc.com")
    #     # 12 | type | id=first_name | user3
    #     self.driver.find_element(By.ID, "first_name").send_keys("user3")
    #     # 13 | type | id=last_name | user3
    #     self.driver.find_element(By.ID, "last_name").send_keys("user3")
    #     # 14 | type | id=url | user3
    #     self.driver.find_element(By.ID, "url").send_keys("user3")
    #     # 15 | click | id=pass1 |
    #     self.driver.find_element(By.ID, "pass1").click()
    #     # 16 | type | id=pass1 | simplepassword
    #     self.driver.find_element(By.ID, "pass1").send_keys("simplepassword")
    #     # 17 | click | name=pw_weak |
    #     self.driver.find_element(By.NAME, "pw_weak").click()
    #     # 18 | click | id=createusersub |
    #     self.driver.find_element(By.ID, "createusersub").click()

    # def test_options_general(self, params):
    #     """Test name: simplelogin."""
    #     # Step # | name | target | value
    #     # 1 | open | /wp-login.php |
    #     self.driver.get("http://{}:{}/wp-admin/options-general.php".format(params["ip_address"], params["port"]))  # pylint: disable=consider-using-f-string disable=line-too-long
    #     # 2 | setWindowSize | 1200x828 |
    #     self.driver.set_window_size(1200, 828)
    #     # 21 | click | id=start_of_week |
    #     self.driver.find_element(By.ID, "start_of_week").click()
    #     # 22 | select | id=start_of_week | label=Tuesday
    #     dropdown = self.driver.find_element(By.ID, "start_of_week")
    #     dropdown.find_element(By.XPATH, "//option[. = 'Tuesday']").click()
    #     # 23 | click | id=submit |
    #     self.driver.find_element(By.ID, "submit").click()

    def test_simplelogin(self, params):
        """Test name: simplelogin."""
        # Step # | name | target | value
        # 1 | open | /wp-login.php |
        self.driver.get("http://{}:{}/wp-login.php".format(params["ip_address"], params["port"]))  # pylint: disable=consider-using-f-string
        # 2 | setWindowSize | 1200x828 |
        self.driver.set_window_size(1200, 828)
        # 3 | type | id=user_login | user
        self.driver.find_element(By.ID, "user_login").send_keys("user")
        # 4 | type | id=user_pass | bitnami
        self.driver.find_element(By.ID, "user_pass").send_keys("bitnami")
        # 5 | click | id=wp-submit |
        self.driver.find_element(By.ID, "wp-submit").click()
