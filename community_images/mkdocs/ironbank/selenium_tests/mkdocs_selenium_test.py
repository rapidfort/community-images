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


class TestMkDocs():
    """The test word press class for testing wordpress image."""

    def setup_method(self):
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

    def test_mkdocs(self, params):
        """The test method"""
        self.driver.get(
            "http://{}:{}/".format(
                params["server"],
                params["port"]))  # pylint: disable=consider-using-f-string
        self.driver.set_window_size(1366, 732)

        # # Click on drop down on left pane # #
        self.driver.find_element(By.XPATH, "//label[@id=\'__nav_2_label\']/span[2]").click()
        # # Open rendered page.md # #
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Page\')]").click()
        # # Open rendered sub.md # #
        self.driver.find_element(By.XPATH, "//span[contains(.,\'Sub\')]").click()
        
        # # Search # #
        self.driver.find_element(By.NAME, "query").click()
        self.driver.find_element(By.NAME, "query").send_keys("this page")
        # # Click on search result # #
        self.driver.find_element(By.XPATH, "//h2[contains(.,\'Hidden page\')]").click()
        
        # # Click on permalink of heading to check extentions # #
        self.driver.find_element(By.XPATH, "//h3[@id=\'h2_heading\']/a").click()

        # # Write content to a sample file for coverage to watch and reload live reload # #
        f = open("reload.txt", "w")
        f.write("reload")
        f.close()

        time.sleep(10) # Wait for coverage to read the file

        # # Click after reload # #
        self.driver.find_element(By.XPATH, "//h3[@id=\'h2_heading\']/a").click()

