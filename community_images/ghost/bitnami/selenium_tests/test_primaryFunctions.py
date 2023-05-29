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

class TestPrimaryFunctions():
  def setup_method(self, method):
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
  
  def teardown_method(self, method):
    self.driver.quit()
  
  def test_primaryFunctions(self, params):
    self.driver.get("http://localhost:{}/".format(params["port"]))
    self.driver.set_window_size(1846, 1053)
    self.driver.find_element(By.LINK_TEXT, "About").click()
    self.driver.get("http://localhost:{}/ghost".format(params["port"]))
    self.driver.find_element(By.ID, "identification").click()
    self.driver.find_element(By.ID, "identification").send_keys("user@example.com")
    self.driver.find_element(By.ID, "password").click()
    self.driver.find_element(By.ID, "password").send_keys("bitnami123")
    self.driver.find_element(By.ID, "password").send_keys(Keys.ENTER)
    time.sleep(2)
    self.driver.get("http://localhost:{}/ghost/#/members".format(params["port"]))
    time.sleep(2)
    self.driver.find_element(By.XPATH, "//span[contains(.,\'Add yourself as a member to test\')]").click()
    time.sleep(2)
    self.driver.get("http://localhost:{}/ghost/#/editor/post".format(params["port"]))
    self.driver.find_element(By.XPATH, "//textarea").send_keys("Sample RF")
    time.sleep(1)
    element = self.driver.find_element(By.CSS_SELECTOR, ".koenig-editor__editor")
    self.driver.execute_script("if(arguments[0].contentEditable === 'true') {arguments[0].innerText = '<p data-koenig-dnd-droppable=\"true\">Hello</p><p data-koenig-dnd-droppable=\"true\"><br></p>'}", element)
    time.sleep(2)
    self.driver.find_element(By.XPATH, "//span[contains(.,\'Publish\')]").click()
    time.sleep(2)
    self.driver.find_element(By.XPATH, "//span[contains(.,\'Continue, final review →\')]").click()
    time.sleep(2)
    self.driver.find_element(By.XPATH, "//span[contains(.,\'Publish post, right now\')]").click()
    time.sleep(2)
    self.driver.find_element(By.CSS_SELECTOR, ".gh-post-bookmark-title").click()
    time.sleep(2)
    self.driver.get("http://localhost:{}/ghost/#/settings".format(params["port"]))
    time.sleep(2)
    self.driver.get("http://localhost:{}/ghost/#/settings/design".format(params["port"]))
    time.sleep(2)
    self.driver.get("http://localhost:{}/ghost/#/settings/analytics".format(params["port"]))
    self.driver.close()
  
