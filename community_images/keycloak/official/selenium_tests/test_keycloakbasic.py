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


class TestYourlsuitest():
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
  
    def test_yourlsuitest(self, params):
        # Navigating to Initial Installation Page
        self.driver.get("http://localhost:{}/".format(params["port"]))
        self.driver.set_window_size(1674, 787)
        self.driver.find_element(By.ID, "username").send_keys("admin")
        self.driver.find_element(By.ID, "password").send_keys("admin")
        self.driver.find_element(By.XPATH, "//input[@id=\'kc-login\']").click()
        self.driver.find_element(By.ID, "nav-item-clients").click()
        self.driver.find_element(By.LINK_TEXT, "Create client").click()
        self.driver.find_element(By.ID, "clientId").click()
        self.driver.find_element(By.ID, "clientId").send_keys("test")
        self.driver.find_element(By.CSS_SELECTOR, ".pf-m-primary").click()
        element = self.driver.find_element(By.CSS_SELECTOR, ".pf-m-primary")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, ".pf-m-primary").click()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, ".pf-m-primary").click()
        element = self.driver.find_element(By.CSS_SELECTOR, ".pf-m-primary")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.ID, "nav-item-client-scopes").click()
        self.driver.find_element(By.ID, "nav-item-roles").click()
        self.driver.find_element(By.LINK_TEXT, "Create role").click()
        self.driver.find_element(By.ID, "kc-name").click()
        self.driver.find_element(By.ID, "kc-name").send_keys("test-role")
        self.driver.find_element(By.CSS_SELECTOR, ".pf-m-primary").click()
        element = self.driver.find_element(By.CSS_SELECTOR, ".pf-m-primary")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, ".pf-m-primary").click()
        self.driver.find_element(By.ID, "nav-item-users").click()
        time.sleep(10)
        self.driver.find_element(By.CSS_SELECTOR, ".pf-m-primary").click()
        self.driver.find_element(By.ID, "requiredActions-actions-select-multi-typeahead-typeahead").click()
        self.driver.find_element(By.XPATH, "//button[contains(.,\'Configure OTP\')]").click()
        self.driver.find_element(By.XPATH, "//input[@id=\'requiredActions-actions-select-multi-typeahead-typeahead\']").click()
        time.sleep(10)
        self.driver.find_element(By.ID, "username").click()
        self.driver.find_element(By.ID, "username").send_keys("rapiduser")
        self.driver.find_element(By.CSS_SELECTOR, ".pf-m-primary").click()
        self.driver.find_element(By.ID, "nav-item-groups").click()
        self.driver.find_element(By.ID, "nav-item-sessions").click()
        self.driver.find_element(By.ID, "nav-item-events").click()
        self.driver.find_element(By.ID, "nav-item-realm-settings").click()
        self.driver.find_element(By.CSS_SELECTOR, ".pf-c-form__group-control .pf-c-switch__toggle").click()
        self.driver.find_element(By.ID, "nav-item-user-federation").click()
        self.driver.find_element(By.XPATH, "//div[@id=\'realm-select\']/button").click()
        self.driver.find_element(By.XPATH, "//a[contains(text(),\'Create realm')]").click()
        self.driver.find_element(By.ID, "kc-realm-name").click()
        self.driver.find_element(By.ID, "kc-realm-name").send_keys("test-realm")
        self.driver.find_element(By.CSS_SELECTOR, ".pf-m-primary").click()
        self.driver.find_element(By.XPATH, "//div[@id=\'user-dropdown\']/button").click()
