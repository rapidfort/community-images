# Generated by Selenium IDE
# pylint: skip-file

import pytest
import time
import json
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities


class TestTestadmin():
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

    def test_testadmin(self, params):
        self.driver.get(
            "http://{}:{}/".format(
                params["server"],
                params["port"]))  # pylint: disable=consider-using-f-string
        self.driver.set_window_size(1200, 1286)
        self.driver.find_element(By.ID, "username").send_keys("rf-test")
        self.driver.find_element(
            By.ID, "password").send_keys("rf_password123!")
        self.driver.find_element(By.CSS_SELECTOR, ".btn-primary").click()
        element = self.driver.find_element(By.LINK_TEXT, "Admin")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.LINK_TEXT, "Variables").click()
        element = self.driver.find_element(By.LINK_TEXT, "Admin")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.LINK_TEXT, "Configurations").click()
        element = self.driver.find_element(By.LINK_TEXT, "Admin")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.LINK_TEXT, "Connections").click()
        element = self.driver.find_element(By.LINK_TEXT, "Admin")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.LINK_TEXT, "Plugins").click()
        element = self.driver.find_element(By.LINK_TEXT, "Admin")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.LINK_TEXT, "Providers").click()
        element = self.driver.find_element(By.LINK_TEXT, "Admin")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.LINK_TEXT, "Pools").click()
        element = self.driver.find_element(By.LINK_TEXT, "Admin")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.LINK_TEXT, "XComs").click()
        self.driver.close()
