# Generated by Selenium IDE
import pytest
import time
import json
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities


class TestEnablealldags():
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

  def test_enablealldags(self):
    self.driver.get("http://{}:{}/".format(params["server"], params["port"]))  # pylint: disable=consider-using-f-string
    self.driver.set_window_size(1440, 790)
    self.driver.find_element(By.ID, "username").send_keys("rf-test")
    self.driver.find_element(By.ID, "password").send_keys("rf_password123!")
    self.driver.find_element(By.CSS_SELECTOR, ".btn-primary").click()
    element = self.driver.find_element(By.CSS_SELECTOR, ".active:nth-child(2) .material-icons")
    actions = ActionChains(self.driver)
    actions.move_to_element(element).perform()
    element = self.driver.find_element(By.CSS_SELECTOR, "body")
    actions = ActionChains(self.driver)
    actions.move_to_element(element, 0, 0).perform()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(1) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(2) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(3) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(4) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(5) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(6) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(7) > td:nth-child(1)").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(7) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(8) .switch").click()
    self.driver.execute_script("window.scrollTo(0,624)")
    self.driver.execute_script("window.scrollTo(0,567)")
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(9) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(10) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(11) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(12) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(13) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(14) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(15) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(16) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(17) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(18) .switch").click()
    self.driver.execute_script("window.scrollTo(0,895)")
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(19) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(20) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(21) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(22) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(23) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(24) .switch").click()
    element = self.driver.find_element(By.LINK_TEXT, "‹")
    actions = ActionChains(self.driver)
    actions.move_to_element(element).perform()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(25) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(26) .switch").click()
    self.driver.find_element(By.CSS_SELECTOR, "tr:nth-child(27) .switch").click()
    element = self.driver.find_element(By.LINK_TEXT, "Active 0")
    actions = ActionChains(self.driver)
    actions.move_to_element(element).perform()
    self.driver.find_element(By.LINK_TEXT, "Active 0").click()
    self.driver.find_element(By.LINK_TEXT, "Paused 0").click()
    self.driver.find_element(By.LINK_TEXT, "exit_to_appLog Out").click()
    self.driver.find_element(By.CSS_SELECTOR, "body").click()
    self.driver.close()
